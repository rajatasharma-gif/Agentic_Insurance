
import streamlit as st
import pandas as pd
import json
import re
from snowflake.snowpark.context import get_active_session

# --- PAGE CONFIGURATION ---
st.set_page_config(
    page_title="AI Insurance Control Center",
    page_icon="🛡️",
    layout="wide"
)

session = get_active_session()

# ==============================================================================
# SHARED UTILITIES
# ==============================================================================

def format_currency(amount):
    if amount is None or pd.isna(amount):
        return "$0.00"
    val = float(amount)
    if abs(val) >= 1e9:
        return f"${val / 1e9:,.2f}B"
    elif abs(val) >= 1e6:
        return f"${val / 1e6:,.2f}M"
    elif abs(val) >= 1e3:
        return f"${val / 1e3:,.2f}K"
    else:
        return f"${val:,.2f}"


def sanitize_id(value):
    """Validate that a value looks like a safe identifier (alphanumeric + hyphens/underscores)."""
    if not re.match(r'^[A-Za-z0-9_\-]+$', str(value)):
        raise ValueError(f"Invalid identifier: {value}")
    return str(value)


def escape_sql_string(value):
    """Escape single quotes for SQL string literals."""
    return str(value).replace("'", "''")


def call_agent(agent_fqn, messages, thread_id=None):
    """Call a Cortex Agent via DATA_AGENT_RUN and return the text response."""
    msg_list = []
    for m in messages:
        msg_list.append({
            "role": m["role"],
            "content": [{"type": "text", "text": m["content"]}]
        })

    request_body = {"messages": msg_list, "stream": False}
    if thread_id is not None:
        request_body["thread_id"] = thread_id
        request_body["parent_message_id"] = 0

    request_json = json.dumps(request_body).replace("'", "\\'")

    sql = f"""
        SELECT TRY_PARSE_JSON(
            SNOWFLAKE.CORTEX.DATA_AGENT_RUN(
                '{agent_fqn}',
                $${json.dumps(request_body)}$$,
                TRUE
            )
        ) AS RESP
    """
    result = session.sql(sql).to_pandas()
    resp = result["RESP"].iloc[0]

    if isinstance(resp, str):
        resp = json.loads(resp)

    text_parts = []
    if resp and "content" in resp:
        for block in resp["content"]:
            if block.get("type") == "text":
                text_parts.append(block["text"])

    thread = resp.get("metadata", {}).get("thread_id") if resp else None
    return "\n".join(text_parts) if text_parts else "No response from agent.", thread


def render_agent_chat(agent_key, agent_fqn, agent_label, sample_questions):
    """Render a chat panel for a Cortex Agent with session state."""
    state_key = f"agent_messages_{agent_key}"
    thread_key = f"agent_thread_{agent_key}"

    if state_key not in st.session_state:
        st.session_state[state_key] = []
    if thread_key not in st.session_state:
        st.session_state[thread_key] = None

    with st.expander(f"🤖 Ask {agent_label}", expanded=False):
        st.caption(f"Chat with the **{agent_label}** to get AI-powered insights.")

        # Sample question chips
        sq_cols = st.columns(len(sample_questions))
        for i, q in enumerate(sample_questions):
            if sq_cols[i].button(q, key=f"{agent_key}_sq_{i}", use_container_width=True):
                st.session_state[state_key].append({"role": "user", "content": q})
                with st.spinner("Agent is thinking..."):
                    answer, tid = call_agent(
                        agent_fqn,
                        st.session_state[state_key],
                        st.session_state[thread_key]
                    )
                st.session_state[state_key].append({"role": "assistant", "content": answer})
                if tid:
                    st.session_state[thread_key] = tid
                st.rerun()

        # Display conversation history
        for msg in st.session_state[state_key]:
            with st.chat_message(msg["role"]):
                st.markdown(msg["content"])

        # Chat input
        user_input = st.text_input(
            "Ask a question...",
            key=f"{agent_key}_input",
            placeholder=f"e.g. {sample_questions[0] if sample_questions else 'Ask anything...'}"
        )
        if st.button("Send", key=f"{agent_key}_send") and user_input:
            st.session_state[state_key].append({"role": "user", "content": user_input})
            with st.spinner("Agent is thinking..."):
                answer, tid = call_agent(
                    agent_fqn,
                    st.session_state[state_key],
                    st.session_state[thread_key]
                )
            st.session_state[state_key].append({"role": "assistant", "content": answer})
            if tid:
                st.session_state[thread_key] = tid
            st.rerun()

        if st.session_state[state_key]:
            if st.button("Clear conversation", key=f"{agent_key}_clear"):
                st.session_state[state_key] = []
                st.session_state[thread_key] = None
                st.rerun()


# --- SIDEBAR NAVIGATION ---
st.sidebar.title("🛡️ Insurance Ops & AI Center")
st.sidebar.markdown("---")
page = st.sidebar.radio("Select Module:", [
    "📊 Executive Analytics",
    "🧮 Dynamic Premium Calculator",
    "⚖️ Claims Processing & AI Triage",
    "🛡️ Churn & Risk Prediction Engine"
])
st.sidebar.markdown("---")
st.sidebar.caption(f"Role: {session.sql('SELECT CURRENT_ROLE()').collect()[0][0]}")
st.sidebar.caption(f"Warehouse: {session.sql('SELECT CURRENT_WAREHOUSE()').collect()[0][0]}")


# ==============================================================================
# MODULE 1: EXECUTIVE ANALYTICS
# ==============================================================================
if page == "📊 Executive Analytics":
    st.title("📊 Executive Analytics & Portfolio Health")
    st.markdown("Real-time portfolio intelligence, underwriting loss ratios, revenue metrics, and customer demographic insights across all insurance lines.")

    # --- KPI FETCH (cache-safe: session not captured in return) ---
    @st.cache_data(ttl=300)
    def fetch_executive_kpis():
        kpi_query = """
            SELECT
                COALESCE(SUM(TOTAL_PREMIUM_REVENUE), 0) AS TOTAL_GWP,
                COALESCE(AVG(RETENTION_RATE), 0) * 100 AS AVG_RETENTION_PCT,
                COALESCE(AVG(GROWTH_RATE), 0) * 100 AS AVG_GROWTH_PCT
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.POLICY_TRENDS
        """
        claims_kpi_query = """
            SELECT
                COALESCE(SUM(TOTAL_PAYOUT), 0) AS TOTAL_PAYOUTS,
                COALESCE(SUM(TOTAL_CLAIMS), 0) AS TOTAL_CLAIMS_COUNT,
                COALESCE(AVG(APPROVAL_RATE), 0) * 100 AS APPROVAL_RATE_PCT,
                COALESCE(AVG(AVG_PROCESSING_DAYS), 0) AS AVG_SLA_DAYS
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.CLAIMS_KPI
        """
        fraud_kpi_query = """
            SELECT COALESCE(SUM(AMOUNT_SAVED), 0) AS TOTAL_FRAUD_SAVED
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.FRAUD_ALERTS
        """
        _session = get_active_session()
        gwp_df = _session.sql(kpi_query).to_pandas()
        claims_df = _session.sql(claims_kpi_query).to_pandas()
        fraud_df = _session.sql(fraud_kpi_query).to_pandas()
        return (
            gwp_df.to_dict('records')[0] if not gwp_df.empty else {},
            claims_df.to_dict('records')[0] if not claims_df.empty else {},
            fraud_df.to_dict('records')[0] if not fraud_df.empty else {}
        )

    gwp_data, claims_data, fraud_data = fetch_executive_kpis()

    if not gwp_data or not claims_data:
        st.warning("No data available in analytics tables. Please ensure POLICY_TRENDS and CLAIMS_KPI are populated.")
        st.stop()

    total_gwp = gwp_data.get('TOTAL_GWP', 0)
    total_payouts = claims_data.get('TOTAL_PAYOUTS', 0)
    net_underwriting_profit = total_gwp - total_payouts
    loss_ratio = (total_payouts / total_gwp * 100) if total_gwp > 0 else 0.0

    # --- KPI SCORECARD ---
    st.subheader("Key Portfolio Indicators")
    st.caption("Data refreshes every 5 minutes")
    m1, m2, m3, m4, m5 = st.columns(5)
    m1.metric("Gross Written Premium", format_currency(total_gwp), delta=f"{gwp_data.get('AVG_GROWTH_PCT', 0):.1f}% YoY")
    m2.metric("Total Claims Paid", format_currency(total_payouts), delta=f"-{claims_data.get('APPROVAL_RATE_PCT', 0):.1f}% Approved")
    m3.metric("Net Underwriting Margin", format_currency(net_underwriting_profit), delta=f"Loss Ratio: {loss_ratio:.1f}%")
    m4.metric("Avg Policy Retention", f"{gwp_data.get('AVG_RETENTION_PCT', 0):.1f}%")
    m5.metric("Fraud Losses Prevented", format_currency(fraud_data.get('TOTAL_FRAUD_SAVED', 0)), delta="SIU Savings")

    st.divider()

    # --- FINANCIAL TRENDS ---
    st.subheader("Portfolio Performance Analytics")
    row1_col1, row1_col2 = st.columns(2)

    with row1_col1:
        st.markdown("#### Monthly Revenue vs. Paid Claims Trajectory")
        trend_df = session.sql("""
            SELECT
                T.MONTH_YEAR,
                SUM(T.TOTAL_PREMIUM_REVENUE) AS REVENUE,
                SUM(K.TOTAL_PAYOUT) AS CLAIMS_PAID
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.POLICY_TRENDS T
            LEFT JOIN INSURANCE_MGMT_SYSTEM.ANALYTICS.CLAIMS_KPI K ON T.MONTH_YEAR = K.MONTH_YEAR
            GROUP BY T.MONTH_YEAR
            ORDER BY T.MONTH_YEAR ASC
        """).to_pandas()
        if not trend_df.empty:
            st.line_chart(trend_df, x="MONTH_YEAR", y=["REVENUE", "CLAIMS_PAID"])
        else:
            st.info("No monthly trend data available.")

    with row1_col2:
        st.markdown("#### Revenue Distribution by Policy Type")
        prod_df = session.sql("""
            SELECT
                POLICY_TYPE,
                SUM(TOTAL_PREMIUM_REVENUE) AS TOTAL_REVENUE,
                SUM(ACTIVE_POLICIES) AS ACTIVE_POLICIES_COUNT
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.POLICY_TRENDS
            GROUP BY POLICY_TYPE
            ORDER BY TOTAL_REVENUE DESC
        """).to_pandas()
        if not prod_df.empty:
            st.bar_chart(prod_df, x="POLICY_TYPE", y="TOTAL_REVENUE")
        else:
            st.info("No product mix data available.")

    st.divider()

    # --- LOSS RATIO & GROWTH ---
    st.subheader("Underwriting Health & Loss Ratio Analysis")
    row2_col1, row2_col2 = st.columns(2)

    with row2_col1:
        st.markdown("#### Loss Ratio Trend by Product & Tier")
        loss_df = session.sql("""
            SELECT
                MONTH_YEAR, POLICY_TYPE,
                AVG(LOSS_RATIO) * 100 AS AVG_LOSS_RATIO_PCT,
                AVG(COMBINED_RATIO) * 100 AS AVG_COMBINED_RATIO_PCT
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.LOSS_RATIO_HISTORY
            GROUP BY MONTH_YEAR, POLICY_TYPE
            ORDER BY MONTH_YEAR ASC
        """).to_pandas()
        if not loss_df.empty:
            st.line_chart(loss_df, x="MONTH_YEAR", y="AVG_LOSS_RATIO_PCT", color="POLICY_TYPE")
        else:
            st.info("No historical loss ratio data available.")

    with row2_col2:
        st.markdown("#### Policy Net Volume Growth (Acquired vs. Cancelled)")
        growth_df = session.sql("""
            SELECT
                MONTH_YEAR,
                SUM(NEW_POLICIES) AS NEW_POLICIES,
                SUM(CANCELLED_POLICIES) AS CANCELLED_POLICIES
            FROM INSURANCE_MGMT_SYSTEM.ANALYTICS.POLICY_TRENDS
            GROUP BY MONTH_YEAR
            ORDER BY MONTH_YEAR ASC
        """).to_pandas()
        if not growth_df.empty:
            st.area_chart(growth_df, x="MONTH_YEAR", y=["NEW_POLICIES", "CANCELLED_POLICIES"])
        else:
            st.info("No policy growth trends available.")

    st.divider()

    # --- DEMOGRAPHICS ---
    st.subheader("Policyholder Demographics & Risk Distribution")
    demo_col1, demo_col2 = st.columns(2)

    with demo_col1:
        st.markdown("#### Customer Distribution by Age Bracket")
        age_df = session.sql("""
            SELECT
                CASE
                    WHEN AGE < 25 THEN 'Under 25'
                    WHEN AGE BETWEEN 25 AND 40 THEN '25-40'
                    WHEN AGE BETWEEN 41 AND 60 THEN '41-60'
                    ELSE '60+'
                END AS AGE_GROUP,
                COUNT(CUSTOMER_ID) AS CUSTOMER_COUNT,
                AVG(ANNUAL_INCOME) AS AVG_INCOME
            FROM INSURANCE_MGMT_SYSTEM.CORE.CUSTOMERS
            GROUP BY AGE_GROUP
        """).to_pandas()
        if not age_df.empty:
            st.bar_chart(age_df, x="AGE_GROUP", y="CUSTOMER_COUNT")
        else:
            st.info("No customer demographic data found.")

    with demo_col2:
        st.markdown("#### Financial Summary Table")
        if not prod_df.empty:
            display_df = prod_df.copy()
            display_df["Formatted Revenue"] = display_df["TOTAL_REVENUE"].apply(format_currency)
            st.dataframe(
                display_df[["POLICY_TYPE", "ACTIVE_POLICIES_COUNT", "Formatted Revenue"]],
                use_container_width=True
            )

    st.divider()

    # --- EXECUTIVE INSIGHTS AGENT ---
    render_agent_chat(
        agent_key="exec",
        agent_fqn="INSURANCE_MGMT_SYSTEM.CORE.EXECUTIVE_INSIGHTS_AGENT",
        agent_label="Executive Insights Agent",
        sample_questions=[
            "Revenue by product?",
            "Loss ratio trend?",
            "Top retention rates?"
        ]
    )


# ==============================================================================
# MODULE 2: INTERACTIVE PREMIUM CALCULATOR & QUOTE GENERATOR
# ==============================================================================
elif page == "🧮 Dynamic Premium Calculator":
    st.title("🧮 Risk-Adjusted Rating & Pricing Engine")
    st.markdown("Automated underwriting calculator that collects policy-specific inputs, retrieves baseline rating metrics, and applies multi-factor pricing formulas.")

    # --- Tab layout: Calculator | Quote History ---
    calc_tab, history_tab = st.tabs(["Premium Calculator", "Quote History"])

    with calc_tab:
        st.subheader("Step 1: Select Insurance Product & Customer Profile")
        col_s1, col_s2, col_s3 = st.columns(3)
        with col_s1:
            customer_id = st.text_input("Customer ID", value="CUST-1001")
        with col_s2:
            policy_type = st.selectbox("Type of Insurance", ["HEALTH", "AUTO", "LIFE", "HOME"])
        with col_s3:
            plan_tier = st.selectbox("Plan Tier", ["BRONZE", "SILVER", "GOLD", "PLATINUM"])

        st.divider()
        st.subheader(f"Step 2: Enter Underwriting Data for {policy_type} Insurance")

        age = 35
        location_region = "LOW_RISK"
        prior_claims = 0
        discounts = 10.0
        add_factor_1 = 1.0
        add_factor_2 = 1.0
        add_factor_1_label = "N/A"
        add_factor_2_label = "N/A"

        col_a, col_b = st.columns(2)
        with col_a:
            age = st.number_input("Policyholder Age", min_value=18, max_value=100, value=35)
            location_region = st.selectbox("Location Risk Zone", ["LOW_RISK", "MEDIUM_RISK", "HIGH_RISK"])
        with col_b:
            prior_claims = st.number_input("Prior Claims Count (Past 3 Years)", min_value=0, max_value=10, value=0)
            discounts = st.number_input("Discounts Applied ($)", min_value=0.0, max_value=200.0, value=15.0)

        st.markdown("##### *Product-Specific Parameters:*")
        col_p1, col_p2 = st.columns(2)

        smoking_status = "NO"
        bmi = 24.5
        annual_mileage = 12000
        coverage_amount = 250000

        if policy_type == "HEALTH":
            with col_p1:
                smoking_status = st.selectbox("Smoking Status", ["NO", "YES"], key="health_smoke")
                bmi = st.number_input("BMI Index", min_value=15.0, max_value=50.0, value=24.5)
            with col_p2:
                has_preexisting = st.selectbox("Pre-Existing Condition?", ["NO", "YES"])
                add_factor_1_label = "Pre-Existing Condition Risk"
                add_factor_1 = 1.35 if has_preexisting == "YES" else 1.0
                network_choice = st.selectbox("Hospital Network", ["STANDARD", "PREMIUM_ALL_ACCESS"])
                add_factor_2_label = "Network Selection Multiplier"
                add_factor_2 = 1.20 if network_choice == "PREMIUM_ALL_ACCESS" else 1.0

        elif policy_type == "AUTO":
            with col_p1:
                credit_score = st.number_input("Credit Score", min_value=300, max_value=850, value=720)
                annual_mileage = st.number_input("Annual Mileage Driven", min_value=1000, max_value=50000, value=12000)
            with col_p2:
                vehicle_class = st.selectbox("Vehicle Performance Class", ["STANDARD_SEDAN", "SUV", "SPORTS_CAR"])
                add_factor_1_label = "Vehicle Performance Risk"
                add_factor_1 = 1.45 if vehicle_class == "SPORTS_CAR" else (1.10 if vehicle_class == "SUV" else 1.0)
                traffic_violations = st.number_input("Traffic Violations (Past 3 Yrs)", min_value=0, max_value=10, value=0)
                add_factor_2_label = "Violations Record"
                add_factor_2 = 1.0 + (traffic_violations * 0.15)

        elif policy_type == "LIFE":
            with col_p1:
                smoking_status = st.selectbox("Smoking Status", ["NO", "YES"], key="life_smoke")
                coverage_amount = st.number_input("Coverage Amount ($)", min_value=50000, max_value=2000000, value=250000, step=50000)
            with col_p2:
                hazardous_job = st.selectbox("Hazardous Occupation/Hobby?", ["NO", "YES"])
                add_factor_1_label = "High Hazard Occupation"
                add_factor_1 = 1.50 if hazardous_job == "YES" else 1.0
                family_history = st.selectbox("Family Critical Illness History?", ["NO", "YES"])
                add_factor_2_label = "Family Medical Risk"
                add_factor_2 = 1.25 if family_history == "YES" else 1.0

        elif policy_type == "HOME":
            with col_p1:
                property_value = st.number_input("Home Replacement Value ($)", min_value=50000, max_value=2000000, value=300000, step=25000)
                deductible_choice = st.selectbox("Deductible ($)", [500, 1000, 2500, 5000])
            with col_p2:
                construction_type = st.selectbox("Construction Material", ["MASONRY_BRICK", "WOOD_FRAME"])
                add_factor_1_label = "Construction Material Risk"
                add_factor_1 = 1.20 if construction_type == "WOOD_FRAME" else 1.0
                fire_distance = st.selectbox("Distance to Nearest Fire Hydrant/Station", ["< 5 miles", "> 5 miles"])
                add_factor_2_label = "Fire Protection Distance"
                add_factor_2 = 1.30 if fire_distance == "> 5 miles" else 1.0

        st.divider()
        st.subheader("Step 3: Execute Premium Calculation Formula")

        if st.button("⚡ Calculate Premium Quote", type="primary"):
            # Fetch base rate from DB (no SQL injection - policy_type/plan_tier are from selectbox)
            try:
                tier_df = session.sql(f"""
                    SELECT BASE_RATE
                    FROM INSURANCE_MGMT_SYSTEM.PREMIUM.PLAN_TIERS
                    WHERE POLICY_TYPE = '{escape_sql_string(policy_type)}'
                      AND PLAN_NAME = '{escape_sql_string(plan_tier)}'
                    LIMIT 1
                """).to_pandas()
                if not tier_df.empty:
                    base_rate = float(tier_df["BASE_RATE"].iloc[0])
                else:
                    st.warning("No base rate found in PLAN_TIERS for this product/tier combination. Using estimated defaults.")
                    fallback_rates = {"HEALTH": 200.0, "AUTO": 110.0, "LIFE": 75.0, "HOME": 130.0}
                    base_rate = fallback_rates.get(policy_type, 100.0)
            except Exception:
                st.warning("Could not retrieve base rate from database. Using estimated defaults.")
                fallback_rates = {"HEALTH": 200.0, "AUTO": 110.0, "LIFE": 75.0, "HOME": 130.0}
                base_rate = fallback_rates.get(policy_type, 100.0)

            tier_multiplier_map = {"BRONZE": 0.85, "SILVER": 1.00, "GOLD": 1.25, "PLATINUM": 1.50}
            tier_multiplier = tier_multiplier_map.get(plan_tier, 1.00)
            age_factor = 1.40 if age < 25 else (1.30 if age > 55 else 1.00)
            location_factor = 1.40 if location_region == "HIGH_RISK" else (1.15 if location_region == "MEDIUM_RISK" else 1.00)

            if policy_type in ["HEALTH", "LIFE"]:
                health_factor = 1.35 if (policy_type == "HEALTH" and bmi > 30) else 1.00
                lifestyle_factor = 1.50 if smoking_status == "YES" else 1.00
            else:
                health_factor = 1.00
                lifestyle_factor = 1.25 if (policy_type == "AUTO" and annual_mileage > 15000) else 1.00

            claims_history_factor = 1.0 + (prior_claims * 0.15)

            gross_calculated = (
                (base_rate * tier_multiplier)
                * age_factor * location_factor * health_factor
                * lifestyle_factor * claims_history_factor
                * add_factor_1 * add_factor_2
            )
            final_premium = max(0.0, round(gross_calculated - discounts, 2))

            st.success(f"**Final Estimated Premium: ${final_premium:,.2f} / month**")

            st.markdown("#### Formula Multiplier Breakdown")
            breakdown_df = pd.DataFrame({
                "Formula Parameter": [
                    "Base Rate", "Tier Multiplier", "Age Factor", "Location Factor",
                    "Health Factor", "Lifestyle Factor", "Claims History Factor",
                    f"Factor 1 ({add_factor_1_label})",
                    f"Factor 2 ({add_factor_2_label})",
                    "Applied Discounts"
                ],
                "Value / Multiplier": [
                    f"${base_rate:,.2f}", f"{tier_multiplier:.2f}x", f"{age_factor:.2f}x", f"{location_factor:.2f}x",
                    f"{health_factor:.2f}x", f"{lifestyle_factor:.2f}x", f"{claims_history_factor:.2f}x",
                    f"{add_factor_1:.2f}x", f"{add_factor_2:.2f}x", f"-${discounts:,.2f}"
                ]
            })
            st.table(breakdown_df)

            # Save to audit log with UUID from Snowflake (no collision risk)
            safe_customer_id = escape_sql_string(customer_id)
            session.sql(f"""
                INSERT INTO INSURANCE_MGMT_SYSTEM.PREMIUM.PREMIUM_CALCULATIONS (
                    CALC_ID, CUSTOMER_ID, POLICY_TYPE, PLAN_TIER, CALC_DATE,
                    BASE_PREMIUM, AGE_FACTOR, LOCATION_FACTOR, HEALTH_FACTOR,
                    LIFESTYLE_FACTOR, CLAIMS_HISTORY_FACTOR, FINAL_PREMIUM, DISCOUNT_APPLIED
                ) VALUES (
                    'CALC-' || REPLACE(UUID_STRING(), '-', ''),
                    '{safe_customer_id}',
                    '{escape_sql_string(policy_type)}',
                    '{escape_sql_string(plan_tier)}',
                    CURRENT_TIMESTAMP(),
                    {base_rate}, {age_factor}, {location_factor}, {health_factor},
                    {lifestyle_factor}, {claims_history_factor}, {final_premium}, {discounts}
                )
            """).collect()
            st.info("Calculation record logged to `PREMIUM.PREMIUM_CALCULATIONS`.")

    with history_tab:
        st.subheader("Recent Premium Calculations")
        st.markdown("View past premium quotes and calculations.")

        history_df = session.sql("""
            SELECT
                CALC_ID, CUSTOMER_ID, POLICY_TYPE, PLAN_TIER,
                CALC_DATE, BASE_PREMIUM, FINAL_PREMIUM, DISCOUNT_APPLIED
            FROM INSURANCE_MGMT_SYSTEM.PREMIUM.PREMIUM_CALCULATIONS
            ORDER BY CALC_DATE DESC
            LIMIT 50
        """).to_pandas()

        if not history_df.empty:
            st.dataframe(history_df, use_container_width=True)

            st.markdown("#### Premium Distribution")
            if len(history_df) > 1:
                chart_data = history_df.groupby("POLICY_TYPE")["FINAL_PREMIUM"].mean().reset_index()
                chart_data.columns = ["POLICY_TYPE", "AVG_PREMIUM"]
                st.bar_chart(chart_data, x="POLICY_TYPE", y="AVG_PREMIUM")
        else:
            st.info("No calculation history found. Run a premium calculation first.")


# ==============================================================================
# MODULE 3: CLAIMS PROCESSING & AI TRIAGE
# ==============================================================================
elif page == "⚖️ Claims Processing & AI Triage":
    st.title("⚖️ Claims Operations & Fraud Radar")
    st.markdown("Review incoming claims, utilize AI-powered triage, and manage claim statuses in real time.")

    # --- Pagination state ---
    if "claims_page" not in st.session_state:
        st.session_state["claims_page"] = 0
    PAGE_SIZE = 20

    # --- Status filter ---
    status_filter = st.selectbox(
        "Filter by Status:",
        ["ALL", "Open", "Under Investigation", "Approved", "Denied", "Escalated"],
        index=0
    )

    where_clause = ""
    if status_filter != "ALL":
        where_clause = f"WHERE CLAIM_STATUS = '{escape_sql_string(status_filter)}'"

    # --- Fetch claims with pagination ---
    offset = st.session_state["claims_page"] * PAGE_SIZE
    claims_data = session.sql(f"""
        SELECT CLAIM_ID, CUSTOMER_ID, POLICY_ID, CLAIM_TYPE, CLAIM_AMOUNT,
               CLAIM_STATUS, FRAUD_SCORE, FRAUD_FLAG, PRIORITY, ESCALATED
        FROM INSURANCE_MGMT_SYSTEM.CORE.CLAIMS
        {where_clause}
        ORDER BY CLAIM_DATE DESC
        LIMIT {PAGE_SIZE} OFFSET {offset}
    """).to_pandas()

    total_count_df = session.sql(f"""
        SELECT COUNT(*) AS CNT FROM INSURANCE_MGMT_SYSTEM.CORE.CLAIMS {where_clause}
    """).to_pandas()
    total_count = int(total_count_df["CNT"].iloc[0])
    total_pages = max(1, (total_count + PAGE_SIZE - 1) // PAGE_SIZE)

    if claims_data.empty:
        st.info("No claims found matching the current filter.")
    else:
        st.subheader(f"Claims Queue ({total_count} total)")
        st.dataframe(claims_data, use_container_width=True)

        # Pagination controls
        pg_col1, pg_col2, pg_col3 = st.columns([1, 2, 1])
        with pg_col1:
            if st.button("← Previous", disabled=st.session_state["claims_page"] == 0):
                st.session_state["claims_page"] -= 1
                st.rerun()
        with pg_col2:
            st.caption(f"Page {st.session_state['claims_page'] + 1} of {total_pages}")
        with pg_col3:
            if st.button("Next →", disabled=st.session_state["claims_page"] >= total_pages - 1):
                st.session_state["claims_page"] += 1
                st.rerun()

        st.divider()
        st.subheader("Inspect & Action Individual Claim")

        selected_claim_id = st.selectbox("Select Claim ID to Process:", claims_data["CLAIM_ID"].unique())

        if selected_claim_id:
            claim_detail = claims_data[claims_data["CLAIM_ID"] == selected_claim_id].iloc[0]

            c1, c2, c3, c4 = st.columns(4)
            c1.metric("Claim Amount", f"${claim_detail['CLAIM_AMOUNT']:,.2f}")
            c2.metric("Fraud Risk Score", f"{claim_detail['FRAUD_SCORE']:.2f}")
            c3.metric("Current Status", claim_detail['CLAIM_STATUS'])
            c4.metric("Priority", claim_detail['PRIORITY'])

            # Action Buttons
            col_a, col_b, col_c = st.columns(3)
            safe_claim_id = sanitize_id(selected_claim_id)

            with col_a:
                if st.button("✅ Approve Claim"):
                    session.sql(f"""
                        UPDATE INSURANCE_MGMT_SYSTEM.CORE.CLAIMS
                        SET CLAIM_STATUS = 'Approved'
                        WHERE CLAIM_ID = '{safe_claim_id}'
                    """).collect()
                    st.success(f"Claim {safe_claim_id} Approved!")
                    st.rerun()

            with col_b:
                if st.button("❌ Deny Claim"):
                    session.sql(f"""
                        UPDATE INSURANCE_MGMT_SYSTEM.CORE.CLAIMS
                        SET CLAIM_STATUS = 'Denied'
                        WHERE CLAIM_ID = '{safe_claim_id}'
                    """).collect()
                    st.error(f"Claim {safe_claim_id} Denied.")
                    st.rerun()

            with col_c:
                if st.button("🚩 Flag for Escalation"):
                    session.sql(f"""
                        UPDATE INSURANCE_MGMT_SYSTEM.CORE.CLAIMS
                        SET ESCALATED = TRUE, CLAIM_STATUS = 'Escalated'
                        WHERE CLAIM_ID = '{safe_claim_id}'
                    """).collect()
                    st.warning(f"Claim {safe_claim_id} Escalated to Fraud Unit!")
                    st.rerun()

    st.divider()

    # --- CLAIMS TRIAGE AGENT ---
    render_agent_chat(
        agent_key="claims",
        agent_fqn="INSURANCE_MGMT_SYSTEM.CORE.CLAIMS_TRIAGE_AGENT",
        agent_label="Claims Triage Agent",
        sample_questions=[
            "High fraud score claims?",
            "Staged accident patterns?",
            "Pending claims over $10K?"
        ]
    )


# ==============================================================================
# MODULE 4: RISK & CHURN PREDICTION WORKBENCH
# ==============================================================================
elif page == "🛡️ Churn & Risk Prediction Engine":
    st.title("🛡️ Proactive Policy Retention & Churn Prediction")
    st.markdown("Identify high-churn-risk policies, analyze risk drivers, and execute retention strategies powered by AI.")

    # --- Churn Summary KPIs ---
    churn_summary = session.sql("""
        SELECT
            COUNT(*) AS TOTAL_AT_RISK,
            SUM(REVENUE_AT_RISK) AS TOTAL_REVENUE_AT_RISK,
            AVG(CHURN_PROBABILITY) AS AVG_CHURN_PROB,
            SUM(CASE WHEN PRIORITY = 'Critical' THEN 1 ELSE 0 END) AS CRITICAL_COUNT
        FROM INSURANCE_MGMT_SYSTEM.RISK.AT_RISK_POLICIES
    """).to_pandas()

    if not churn_summary.empty and churn_summary.iloc[0]["TOTAL_AT_RISK"] > 0:
        row = churn_summary.iloc[0]
        k1, k2, k3, k4 = st.columns(4)
        k1.metric("At-Risk Policies", f"{int(row['TOTAL_AT_RISK'])}")
        k2.metric("Revenue at Risk", format_currency(row['TOTAL_REVENUE_AT_RISK']))
        k3.metric("Avg Churn Probability", f"{row['AVG_CHURN_PROB'] * 100:.1f}%")
        k4.metric("Critical Priority", f"{int(row['CRITICAL_COUNT'])}")
    else:
        st.info("No at-risk policies detected.")

    st.divider()

    # --- Risk Distribution Charts ---
    chart_col1, chart_col2 = st.columns(2)

    with chart_col1:
        st.markdown("#### Churn Risk by Policy Type")
        risk_by_type = session.sql("""
            SELECT POLICY_TYPE, RISK_CATEGORY, COUNT(*) AS POLICY_COUNT
            FROM INSURANCE_MGMT_SYSTEM.RISK.AT_RISK_POLICIES
            GROUP BY POLICY_TYPE, RISK_CATEGORY
            ORDER BY POLICY_COUNT DESC
        """).to_pandas()
        if not risk_by_type.empty:
            st.bar_chart(risk_by_type, x="POLICY_TYPE", y="POLICY_COUNT", color="RISK_CATEGORY")
        else:
            st.info("No risk distribution data.")

    with chart_col2:
        st.markdown("#### Top Risk Factors Driving Churn")
        risk_factors = session.sql("""
            SELECT TOP_RISK_FACTOR, COUNT(*) AS FREQUENCY, AVG(CHURN_PROBABILITY) AS AVG_PROB
            FROM INSURANCE_MGMT_SYSTEM.RISK.CHURN_PREDICTIONS
            GROUP BY TOP_RISK_FACTOR
            ORDER BY FREQUENCY DESC
            LIMIT 10
        """).to_pandas()
        if not risk_factors.empty:
            st.bar_chart(risk_factors, x="TOP_RISK_FACTOR", y="FREQUENCY")
        else:
            st.info("No risk factor data.")

    st.divider()

    # --- Top At-Risk Policies Table ---
    st.subheader("Top At-Risk Policies")
    at_risk_df = session.sql("""
        SELECT
            a.POLICY_ID, a.CUSTOMER_ID, a.POLICY_TYPE, a.RISK_CATEGORY,
            a.CHURN_PROBABILITY, a.REVENUE_AT_RISK, a.RECOMMENDED_ACTION,
            a.DAYS_SINCE_CONTACT, a.MISSED_PAYMENTS, a.PRIORITY
        FROM INSURANCE_MGMT_SYSTEM.RISK.AT_RISK_POLICIES a
        ORDER BY a.CHURN_PROBABILITY DESC
        LIMIT 20
    """).to_pandas()

    if not at_risk_df.empty:
        st.dataframe(at_risk_df, use_container_width=True)
    else:
        st.info("No high-risk churn policies detected.")

    st.divider()

    # --- Retention Outcomes ---
    st.subheader("Retention Offer Outcomes")
    outcomes_df = session.sql("""
        SELECT
            RETENTION_OFFER,
            OUTCOME,
            COUNT(*) AS COUNT,
            AVG(CHURN_PROBABILITY) AS AVG_CHURN_PROB
        FROM INSURANCE_MGMT_SYSTEM.RISK.CHURN_PREDICTIONS
        WHERE OUTCOME IS NOT NULL
        GROUP BY RETENTION_OFFER, OUTCOME
        ORDER BY COUNT DESC
    """).to_pandas()

    if not outcomes_df.empty:
        st.dataframe(outcomes_df, use_container_width=True)
    else:
        st.info("No retention outcome data yet.")

    st.divider()

    # --- RETENTION AGENT ---
    render_agent_chat(
        agent_key="retention",
        agent_fqn="INSURANCE_MGMT_SYSTEM.RISK.RETENTION_AGENT",
        agent_label="Retention Agent",
        sample_questions=[
            "Highest churn risk?",
            "Top risk factors?",
            "Best retention offers?"
        ]
    )
