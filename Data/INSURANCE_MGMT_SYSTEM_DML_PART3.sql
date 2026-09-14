-- ============================================================================
-- INSURANCE MANAGEMENT SYSTEM - DML Part 3: Analytics & Risk Factors
-- Database: INSURANCE_MGMT_SYSTEM
-- Run AFTER: INSURANCE_MGMT_SYSTEM_DML_PART2.sql
-- ============================================================================


-- ############################################################################
-- RISK_FACTORS (40 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.RISK.RISK_FACTORS
(FACTOR_ID, FACTOR_NAME, FACTOR_CATEGORY, WEIGHT, THRESHOLD_LOW, THRESHOLD_MEDIUM, THRESHOLD_HIGH, DESCRIPTION, APPLIES_TO, ACTIVE_FLAG)
VALUES
('RF-001','Payment History','Financial',0.25,0.0,0.3,0.6,'Number of missed/late payments in 12 months','All',TRUE),
('RF-002','Claims Frequency','Behavioral',0.20,0.0,0.25,0.5,'Claims submitted per year','All',TRUE),
('RF-003','Customer Tenure','Loyalty',0.10,0.0,0.2,0.4,'Years as customer (inverse: shorter = riskier)','All',TRUE),
('RF-004','Engagement Score','Behavioral',0.15,0.0,0.3,0.6,'Portal logins, app usage, communication responses','All',TRUE),
('RF-005','Premium Increase Response','Financial',0.10,0.0,0.2,0.5,'Response to last premium increase','All',TRUE),
('RF-006','Complaint History','Satisfaction',0.10,0.0,0.3,0.6,'Unresolved complaints in 12 months','All',TRUE),
('RF-007','Competitor Activity','Market',0.05,0.0,0.2,0.4,'Evidence of competitor quote shopping','All',TRUE),
('RF-008','Life Event','Demographic',0.05,0.0,0.15,0.3,'Recent life changes (divorce, job loss, move)','All',TRUE),
('RF-009','Age of Vehicle','Vehicle',0.15,0.0,0.2,0.5,'Older vehicles more likely to drop coverage','Auto',TRUE),
('RF-010','Driving Record Change','Behavioral',0.20,0.0,0.25,0.5,'Recent violations or accidents','Auto',TRUE),
('RF-011','Mileage Increase','Usage',0.10,0.0,0.2,0.4,'Significant mileage increase','Auto',TRUE),
('RF-012','Coverage Reduction Request','Financial',0.15,0.0,0.3,0.6,'Customer requested lower coverage','Auto',TRUE),
('RF-013','Health Status Change','Medical',0.20,0.0,0.3,0.6,'Significant health event or diagnosis','Health',TRUE),
('RF-014','Prescription Changes','Medical',0.10,0.0,0.2,0.4,'Major changes in medication','Health',TRUE),
('RF-015','Network Satisfaction','Service',0.15,0.0,0.25,0.5,'Access to preferred providers','Health',TRUE),
('RF-016','Utilization Rate','Usage',0.15,0.0,0.3,0.6,'Frequency of healthcare visits','Health',TRUE),
('RF-017','Deductible Met','Financial',0.10,0.0,0.2,0.4,'Whether deductible was met this year','Health',TRUE),
('RF-018','Beneficiary Change','Life Event',0.10,0.0,0.15,0.3,'Recent beneficiary modification','Life',TRUE),
('RF-019','Income Change','Financial',0.15,0.0,0.3,0.5,'Significant income decrease','Life',TRUE),
('RF-020','Policy Loan Activity','Financial',0.20,0.0,0.25,0.5,'Loans taken against cash value','Life',TRUE),
('RF-021','Term Expiration','Policy',0.25,0.0,0.3,0.7,'Approaching term end without renewal','Life',TRUE),
('RF-022','Property Value Change','Property',0.15,0.0,0.2,0.4,'Significant change in home value','Home',TRUE),
('RF-023','Renovation Activity','Property',0.10,0.0,0.15,0.3,'Major renovations not reported','Home',TRUE),
('RF-024','Neighborhood Risk Change','Location',0.15,0.0,0.25,0.5,'Area crime/weather risk increase','Home',TRUE),
('RF-025','Claim Denial Impact','Satisfaction',0.20,0.0,0.3,0.6,'Recent claim denial and response','Home',TRUE),
('RF-026','Multi-Policy Discount','Loyalty',0.10,0.0,0.2,0.4,'Bundled policy at risk of unbundling','All',TRUE),
('RF-027','Auto-Pay Status','Financial',0.08,0.0,0.15,0.3,'Removed auto-pay recently','All',TRUE),
('RF-028','Communication Opt-Out','Engagement',0.07,0.0,0.15,0.3,'Opted out of communications','All',TRUE),
('RF-029','Survey Score','Satisfaction',0.12,0.0,0.25,0.5,'NPS or CSAT below threshold','All',TRUE),
('RF-030','Referral Activity','Loyalty',0.05,0.0,0.1,0.2,'No referrals in 2+ years','All',TRUE),
('RF-031','Digital Engagement','Behavioral',0.08,0.0,0.2,0.4,'App/portal usage decline','All',TRUE),
('RF-032','Call Center Frequency','Service',0.10,0.0,0.25,0.5,'Increased support calls','All',TRUE),
('RF-033','Payment Method Change','Financial',0.07,0.0,0.15,0.3,'Changed from auto to manual pay','All',TRUE),
('RF-034','Quote Comparison','Market',0.12,0.0,0.25,0.5,'Requested competitor comparisons','All',TRUE),
('RF-035','Renewal Delay','Policy',0.15,0.0,0.3,0.6,'Late or delayed renewal response','All',TRUE),
('RF-036','Coverage Gaps','Policy',0.10,0.0,0.2,0.4,'Periods without coverage','All',TRUE),
('RF-037','Agent Relationship','Service',0.08,0.0,0.15,0.3,'Agent change or dissatisfaction','All',TRUE),
('RF-038','Price Sensitivity Index','Financial',0.15,0.0,0.3,0.6,'Historical price sensitivity score','All',TRUE),
('RF-039','Loyalty Program Status','Loyalty',0.05,0.0,0.1,0.2,'Not enrolled in loyalty program','All',TRUE),
('RF-040','Social Sentiment','External',0.03,0.0,0.1,0.2,'Negative social media mentions','All',TRUE);


-- ############################################################################
-- CLAIMS_KPI (24 months)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.ANALYTICS.CLAIMS_KPI
(KPI_ID, MONTH_YEAR, TOTAL_CLAIMS, CLAIMS_APPROVED, CLAIMS_DENIED, CLAIMS_PENDING, CLAIMS_ESCALATED, APPROVAL_RATE, AVG_PROCESSING_DAYS, AVG_CLAIM_AMOUNT, TOTAL_PAYOUT, FRAUD_DETECTED, CUSTOMER_SATISFACTION)
SELECT 
    'KPI-' || LPAD(SEQ4()::VARCHAR, 3, '0'),
    DATEADD(MONTH, -SEQ4(), DATE_TRUNC('MONTH', CURRENT_DATE())),
    UNIFORM(30, 50, RANDOM()),
    UNIFORM(15, 30, RANDOM()),
    UNIFORM(3, 10, RANDOM()),
    UNIFORM(5, 15, RANDOM()),
    UNIFORM(2, 8, RANDOM()),
    ROUND(UNIFORM(55.0, 78.0, RANDOM())::FLOAT, 1),
    ROUND(UNIFORM(8.0, 25.0, RANDOM())::FLOAT, 1),
    ROUND(UNIFORM(5000, 35000, RANDOM()), 2),
    ROUND(UNIFORM(150000, 600000, RANDOM()), 2),
    UNIFORM(1, 5, RANDOM()),
    ROUND(UNIFORM(3.5, 4.8, RANDOM())::FLOAT, 1)
FROM TABLE(GENERATOR(ROWCOUNT => 24));


-- ############################################################################
-- POLICY_TRENDS (36 months x types)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.ANALYTICS.POLICY_TRENDS
(TREND_ID, MONTH_YEAR, POLICY_TYPE, NEW_POLICIES, RENEWED_POLICIES, CANCELLED_POLICIES, ACTIVE_POLICIES, TOTAL_PREMIUM_REVENUE, AVG_PREMIUM, RETENTION_RATE, GROWTH_RATE)
SELECT 
    'TRD-' || LPAD(SEQ4()::VARCHAR, 3, '0'),
    DATEADD(MONTH, -FLOOR(SEQ4()/4), DATE_TRUNC('MONTH', CURRENT_DATE())),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Health' WHEN 1 THEN 'Auto' WHEN 2 THEN 'Life' ELSE 'Home' END,
    UNIFORM(5, 25, RANDOM()),
    UNIFORM(10, 40, RANDOM()),
    UNIFORM(2, 10, RANDOM()),
    UNIFORM(50, 120, RANDOM()),
    ROUND(UNIFORM(100000, 500000, RANDOM()), 2),
    ROUND(UNIFORM(2000, 8000, RANDOM()), 2),
    ROUND(UNIFORM(82.0, 96.0, RANDOM())::FLOAT, 1),
    ROUND(UNIFORM(-5.0, 15.0, RANDOM())::FLOAT, 1)
FROM TABLE(GENERATOR(ROWCOUNT => 36));


-- ############################################################################
-- LOSS_RATIO_HISTORY (48 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.ANALYTICS.LOSS_RATIO_HISTORY
(RECORD_ID, POLICY_TYPE, PLAN_TIER, MONTH_YEAR, PREMIUMS_EARNED, CLAIMS_PAID, LOSS_RATIO, COMBINED_RATIO, EXPENSE_RATIO, TREND)
SELECT 
    'LR-' || LPAD(SEQ4()::VARCHAR, 3, '0'),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Health' WHEN 1 THEN 'Auto' WHEN 2 THEN 'Life' ELSE 'Home' END,
    CASE MOD(FLOOR(SEQ4()/4), 4) WHEN 0 THEN 'Bronze' WHEN 1 THEN 'Silver' WHEN 2 THEN 'Gold' ELSE 'Platinum' END,
    DATEADD(MONTH, -FLOOR(SEQ4()/4), DATE_TRUNC('MONTH', CURRENT_DATE())),
    ROUND(UNIFORM(80000, 400000, RANDOM()), 2),
    ROUND(UNIFORM(40000, 300000, RANDOM()), 2),
    ROUND(UNIFORM(0.35, 0.85, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.75, 1.10, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.25, 0.40, RANDOM())::FLOAT, 2),
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'UP' WHEN 1 THEN 'DOWN' ELSE 'STABLE' END
FROM TABLE(GENERATOR(ROWCOUNT => 48));


-- ############################################################################
-- FRAUD_ALERTS (50 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.ANALYTICS.FRAUD_ALERTS
(ALERT_ID, CLAIM_ID, POLICY_ID, CUSTOMER_ID, ALERT_DATE, FRAUD_TYPE, CONFIDENCE_SCORE, ALERT_STATUS, INVESTIGATION_NOTES, RESOLUTION, AMOUNT_SAVED)
SELECT 
    'FRD-' || LPAD(SEQ4()::VARCHAR, 4, '0'),
    'CLM-' || LPAD(UNIFORM(0, 399, RANDOM())::VARCHAR, 5, '0'),
    'POL-' || LPAD(UNIFORM(0, 299, RANDOM())::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 249, RANDOM())::VARCHAR, 5, '0'),
    DATEADD(DAY, -UNIFORM(1, 180, RANDOM()), CURRENT_TIMESTAMP()),
    CASE MOD(SEQ4(), 7) WHEN 0 THEN 'Duplicate Claim' WHEN 1 THEN 'Staged Accident' WHEN 2 THEN 'Inflated Damages' WHEN 3 THEN 'False Identity' WHEN 4 THEN 'Pre-existing Damage' WHEN 5 THEN 'Phantom Injury' ELSE 'Arson Suspected' END,
    ROUND(UNIFORM(0.65, 0.99, RANDOM())::FLOAT, 2),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Open' WHEN 1 THEN 'Investigating' WHEN 2 THEN 'Confirmed Fraud' ELSE 'False Positive' END,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Multiple claims from same location within 30 days' WHEN 1 THEN 'Damage inconsistent with reported incident' WHEN 2 THEN 'Policy purchased 3 days before claim' WHEN 3 THEN 'Repair shop flagged for previous fraud' ELSE 'Witness statements contradictory' END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Pending' WHEN 1 THEN 'Under Investigation' WHEN 2 THEN 'Claim Denied' ELSE 'Cleared' END,
    CASE WHEN MOD(SEQ4(), 4) = 2 THEN ROUND(UNIFORM(5000, 50000, RANDOM()), 2) ELSE NULL END
FROM TABLE(GENERATOR(ROWCOUNT => 50));


-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

SELECT TABLE_SCHEMA, TABLE_NAME, ROW_COUNT
FROM INSURANCE_MGMT_SYSTEM.INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- ============================================================================
-- END OF DML PART 3
-- ============================================================================
