# Agentic Insurance Platform

An AI-powered insurance management system built with **Snowflake Cortex Agents** for analytics, premium calculation, claims processing, and risk prediction.

## Table of Contents
1. [Purpose of This Repository](#purpose-of-this-repository)
2. [Data Architecture](#data-architecture)
3. [Application Workflow](#application-workflow)
4. [Modules & Agents](#modules--agents)

---

## Purpose of This Repository

This repository contains an **Agentic Insurance Management System** designed to leverage AI agents for insurance operations. The platform integrates:

- **Snowflake Cortex Data Agents** for intelligent automation
- **Streamlit UI** for dashboard visualization and agent interactions
- **Insurance Analytics** for portfolio health and KPI tracking
- **Premium Calculation** for dynamic pricing
- **Claims Processing & Triage** using AI agents
- **Churn & Risk Prediction** engine for customer retention

### Key Components
- **Database**: Snowflake with insurance-specific schema
- **UI Framework**: Streamlit application (`Agentic_Insurance` file)
- **Data**: SQL scripts for schema creation and sample data population
- **Agents**: Cortex Data Agents for various insurance workflows

---

## Data Architecture

### Database Schema
The system uses **INSURANCE_MGMT_SYSTEM** database with 4 schemas:

#### **1. CORE Schema**
Fundamental business entities:

**AGENTS Table**
- Core agent information (Insurance Agents, Underwriters, Claims Analysts, Risk Managers)
- Fields: AGENT_ID, AGENT_NAME, ROLE, REGION, BRANCH, SPECIALIZATION, PERFORMANCE_SCORE, ACTIVE_POLICIES_COUNT

**CUSTOMERS Table**
- Customer personal and financial information
- Fields: CUSTOMER_ID, FIRST_NAME, LAST_NAME, DATE_OF_BIRTH, AGE, GENDER, EMAIL, PHONE, ADDRESS, CITY, STATE, ZIP_CODE, OCCUPATION, ANNUAL_INCOME, CREDIT_SCORE, SMOKING_STATUS, BMI

**POLICIES Table**
- Insurance policies associated with customers
- Fields: POLICY_ID, CUSTOMER_ID, AGENT_ID, POLICY_TYPE (Health/Auto/Life/Home), PLAN_TIER (Bronze/Silver/Gold/Platinum), POLICY_STATUS, START_DATE, END_DATE, PREMIUM_AMOUNT, COVERAGE_AMOUNT, DEDUCTIBLE, LOSS_RATIO, AUTO_RENEW, UNDERWRITING_SCORE

**CLAIMS Table**
- Insurance claim records
- Fields: CLAIM_ID, POLICY_ID, CUSTOMER_ID, CLAIM_DATE, REPORTED_DATE, CLAIM_TYPE, CLAIM_STATUS, CLAIM_AMOUNT, APPROVED_AMOUNT, FRAUD_FLAG, FRAUD_SCORE, FRAUD_REASON, ASSIGNED_ADJUSTER, RESOLUTION_DATE, DAYS_TO_RESOLVE, PRIORITY, ESCALATED

#### **2. PREMIUM Schema**
Premium calculation and rate management:

**PREMIUM_FACTORS Table**
- Rating factors for premium calculation
- Fields: FACTOR_ID, POLICY_TYPE, FACTOR_NAME, FACTOR_CATEGORY, FACTOR_VALUE, MULTIPLIER, BASE_RATE

**PLAN_TIERS Table**
- Pre-defined plan options for each policy type
- Fields: TIER_ID, POLICY_TYPE, PLAN_NAME, MONTHLY_PREMIUM, ANNUAL_PREMIUM, COVERAGE_LIMIT, DEDUCTIBLE, COPAY_PCT, KEY_BENEFITS, RECOMMENDED_FOR

**PREMIUM_CALCULATIONS Table**
- Records of premium calculations for quotes and policies
- Fields: CALC_ID, CUSTOMER_ID, POLICY_TYPE, PLAN_TIER, CALC_DATE, BASE_PREMIUM, AGE_FACTOR, LOCATION_FACTOR, HEALTH_FACTOR, LIFESTYLE_FACTOR, CLAIMS_HISTORY_FACTOR, FINAL_PREMIUM, DISCOUNT_APPLIED, FACTOR_BREAKDOWN

#### **3. RISK Schema**
Risk management and predictions:

**AT_RISK_POLICIES Table**
- Policies identified as at-risk for churn
- Fields: RISK_ID, POLICY_ID, CUSTOMER_ID, POLICY_TYPE, RISK_CATEGORY, RISK_SCORE, REVENUE_AT_RISK, CHURN_PROBABILITY, RISK_DRIVERS, LAST_INTERACTION_DATE, COMPLAINTS_COUNT, MISSED_PAYMENTS, RECOMMENDED_ACTION, PRIORITY

**RISK_FACTORS Table**
- Configurable risk assessment factors
- Fields: FACTOR_ID, FACTOR_NAME, FACTOR_CATEGORY, WEIGHT, THRESHOLD_LOW/MEDIUM/HIGH, APPLIES_TO

**CHURN_PREDICTIONS Table**
- Predictive models for customer churn
- Fields: PREDICTION_ID, POLICY_ID, CUSTOMER_ID, PREDICTION_DATE, CHURN_PROBABILITY, CONFIDENCE_SCORE, TOP_RISK_FACTOR, PREDICTED_CHURN_DATE, RETENTION_OFFER, OUTCOME

#### **4. ANALYTICS Schema**
Business intelligence and reporting:

**CLAIMS_KPI Table**
- Monthly claims performance metrics
- Fields: KPI_ID, MONTH_YEAR, TOTAL_CLAIMS, CLAIMS_APPROVED, CLAIMS_DENIED, CLAIMS_PENDING, APPROVAL_RATE, AVG_PROCESSING_DAYS, TOTAL_PAYOUT, FRAUD_DETECTED, CUSTOMER_SATISFACTION

**POLICY_TRENDS Table**
- Monthly policy acquisition and retention metrics
- Fields: TREND_ID, MONTH_YEAR, POLICY_TYPE, NEW_POLICIES, RENEWED_POLICIES, CANCELLED_POLICIES, ACTIVE_POLICIES, TOTAL_PREMIUM_REVENUE, RETENTION_RATE, GROWTH_RATE

**LOSS_RATIO_HISTORY Table**
- Historical loss ratio and underwriting profitability
- Fields: RECORD_ID, POLICY_TYPE, PLAN_TIER, MONTH_YEAR, PREMIUMS_EARNED, CLAIMS_PAID, LOSS_RATIO, COMBINED_RATIO, EXPENSE_RATIO

**FRAUD_ALERTS Table**
- Fraud detection and investigation records
- Fields: ALERT_ID, CLAIM_ID, POLICY_ID, CUSTOMER_ID, ALERT_DATE, FRAUD_TYPE, CONFIDENCE_SCORE, ALERT_STATUS, INVESTIGATION_NOTES, RESOLUTION, AMOUNT_SAVED

---

## Application Workflow

The system is built as a **Streamlit application** with multiple interconnected modules:

### **Module 1: Executive Analytics Dashboard**
**Purpose**: Real-time portfolio intelligence and KPI tracking

**Data Flow**:
1. Fetches KPIs from ANALYTICS schema tables (POLICY_TRENDS, CLAIMS_KPI, FRAUD_ALERTS)
2. Calculates key metrics:
   - Gross Written Premium (GWP)
   - Total Claims Paid
   - Net Underwriting Margin
   - Loss Ratio & Combined Ratio
   - Retention & Growth Rates
   - Active Policies Count
3. Displays visualizations:
   - Monthly revenue vs. claims trajectory
   - Revenue distribution by policy type
   - Loss ratio trends
   - Policy growth (new vs. cancelled)
   - Customer demographics by age bracket
4. Exports data as CSV or PDF reports

**Agents Used**: None (direct SQL queries to analytics tables)

---

### **Module 2: Dynamic Premium Calculator**
**Purpose**: Calculate personalized insurance premiums

**Data Flow**:
1. User inputs customer profile (age, location, health, claims history)
2. Cortex Agent queries PREMIUM_FACTORS and PLAN_TIERS
3. Agent calculates premium using:
   - Base rate for policy type
   - Multipliers for risk factors (age, location, health, lifestyle, claims history)
   - Discount adjustments
4. Returns quote with breakdown of factors
5. Option to create policy (inserts into POLICIES table)
6. Stores calculation record in PREMIUM_CALCULATIONS table

**Agents Used**: Premium calculation agent (Cortex Data Agent)

---

### **Module 3: Claims Processing & AI Triage**
**Purpose**: Process and assess insurance claims with fraud detection

**Data Flow**:
1. User submits claim (policy ID, claim type, amount, description)
2. System validates policy is active in POLICIES table
3. Cortex Agent analyzes claim against policy coverage
4. Agent checks for fraud indicators:
   - Fraud score calculation
   - Pattern matching against FRAUD_ALERTS
   - Duplicate claim detection
   - Suspicious behavior flags
5. Agent assesses claim status (Approved/Denied/Escalated/Pending)
6. Assigns to claims adjuster
7. Records in CLAIMS table with fraud_flag and fraud_score
8. If fraud detected, creates FRAUD_ALERTS record
9. Sends notification with assessment

**Agents Used**: Claims Processing Agent (Cortex Data Agent)

---

### **Module 4: Churn & Risk Prediction Engine**
**Purpose**: Identify at-risk policies and predict customer churn

**Data Flow**:
1. System evaluates all active policies periodically
2. Cortex Agent calculates risk score using:
   - Customer tenure and interaction history
   - Payment behavior (missed payments count)
   - Complaint history
   - Policy-specific metrics
   - Claims history frequency
3. Predictions stored in CHURN_PREDICTIONS table
4. Policies with high churn probability marked in AT_RISK_POLICIES
5. Generates recommended actions:
   - Retention offers
   - Contact recommendations
   - Premium adjustments
6. Tracks prediction outcomes

**Agents Used**: Risk Prediction Agent (Cortex Data Agent)

---

## Modules & Agents

### Architecture Overview

**Streamlit Application** (`Agentic_Insurance` file)
- 4 main modules accessible via sidebar navigation
- Integrates with Snowflake Cortex Agents
- Real-time data visualization
- Agent chat interfaces for user interaction

### Cortex Data Agents

The system uses **Snowflake Cortex Data Agents** for:

1. **Premium Calculation Agent**
   - Queries customer data and risk factors
   - Calculates premiums with factor breakdown
   - Returns personalized quotes

2. **Claims Processing Agent**
   - Validates claims against policy coverage
   - Performs fraud detection
   - Recommends approval/denial/escalation

3. **Risk Prediction Agent**
   - Evaluates churn probability
   - Identifies risk drivers
   - Generates retention strategies

4. **Analytics Agent** (in Executive Dashboard)
   - Responds to natural language questions about portfolio health
   - Analyzes trends and performance

### Agent Integration

Agents communicate via:
- `call_agent()` function in Streamlit app
- JSON request/response format
- Snowflake `SNOWFLAKE.CORTEX.DATA_AGENT_RUN()` procedure
- Thread-based conversation management

---

## Technology Stack

- **Cloud Platform**: Snowflake
- **AI Engine**: Snowflake Cortex Agents (LLM-powered)
- **Frontend**: Streamlit (Python)
- **Database**: Snowflake SQL
- **Visualization**: Streamlit charts & tables
- **Reporting**: PDF & CSV export (ReportLab)

---

## Project Files

### Core Application
- `Agentic_Insurance` - Main Streamlit application with all 4 modules

### Database & Data
- `Data/INSURANCE_MGMT_SYSTEM_DDL.sql` - Database schema definition (CORE, PREMIUM, RISK, ANALYTICS schemas)
- `Data/INSURANCE_MGMT_SYSTEM_DML_PART1.sql` - Sample data for AGENTS, CUSTOMERS, POLICIES, CLAIMS
- `Data/INSURANCE_MGMT_SYSTEM_DML_PART2.sql` - Sample data for PREMIUM schema tables
- `Data/INSURANCE_MGMT_SYSTEM_DML_PART3.sql` - Sample data for RISK & ANALYTICS schema tables

### Documentation & Artifacts
- `Artifacts/Insurance_Platform_Overview.pptx` - Visual presentation of platform architecture
- `Artifacts/Insurance_Platform_Content.docx` - Detailed platform documentation
- `Artifacts/Insurance_App_flow_simple.png` - Simplified application flow diagram
- `Artifacts/Insurance_App_flow_claude.png` - Detailed application architecture diagram

---

## Setup & Deployment

### Prerequisites
- Snowflake account with Cortex access
- Python 3.8+
- Required Python packages: streamlit, pandas, snowflake-snowpark

### Installation
1. Clone repository
2. Install dependencies
3. Set Snowflake connection parameters
4. Run SQL DDL and DML scripts to initialize database
5. Launch Streamlit app: `streamlit run Agentic_Insurance`

### Configuration
- Set Snowflake role and warehouse in sidebar
- Configure Cortex Agent FQNs for each module
- Customize premium factors and risk thresholds as needed

---

**Last Updated**: September 14, 2026  
**Version**: 1.0  
**Status**: Active Development
