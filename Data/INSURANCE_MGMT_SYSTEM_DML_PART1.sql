-- ============================================================================
-- INSURANCE MANAGEMENT SYSTEM - DML Part 1: Core Tables
-- Database: INSURANCE_MGMT_SYSTEM
-- Run AFTER: INSURANCE_MGMT_SYSTEM_DDL.sql
-- ============================================================================


-- ############################################################################
-- AGENTS (25 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.CORE.AGENTS
(AGENT_ID, AGENT_NAME, ROLE, REGION, BRANCH, HIRE_DATE, SPECIALIZATION, PERFORMANCE_SCORE, ACTIVE_POLICIES_COUNT, CERTIFICATIONS, ACTIVE_FLAG)
SELECT 
    'AGT-' || LPAD(SEQ4()::VARCHAR, 4, '0'),
    CASE MOD(SEQ4(), 25)
        WHEN 0 THEN 'Sarah Johnson' WHEN 1 THEN 'Michael Chen' WHEN 2 THEN 'Emily Rodriguez'
        WHEN 3 THEN 'David Kim' WHEN 4 THEN 'Jessica Williams' WHEN 5 THEN 'Robert Taylor'
        WHEN 6 THEN 'Amanda Martinez' WHEN 7 THEN 'Christopher Lee' WHEN 8 THEN 'Michelle Brown'
        WHEN 9 THEN 'Daniel Garcia' WHEN 10 THEN 'Lauren Davis' WHEN 11 THEN 'James Wilson'
        WHEN 12 THEN 'Samantha Moore' WHEN 13 THEN 'Andrew Jackson' WHEN 14 THEN 'Rachel Thompson'
        WHEN 15 THEN 'Kevin White' WHEN 16 THEN 'Nicole Harris' WHEN 17 THEN 'Brian Clark'
        WHEN 18 THEN 'Stephanie Lewis' WHEN 19 THEN 'Thomas Robinson' WHEN 20 THEN 'Maria Santos'
        WHEN 21 THEN 'Peter Chang' WHEN 22 THEN 'Lisa Park' WHEN 23 THEN 'Mark Foster' ELSE 'Diana Ross'
    END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Insurance Agent' WHEN 1 THEN 'Underwriter' WHEN 2 THEN 'Claims Analyst' ELSE 'Risk Manager' END,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Northeast' WHEN 1 THEN 'Southeast' WHEN 2 THEN 'Midwest' WHEN 3 THEN 'Southwest' ELSE 'West' END,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'New York' WHEN 1 THEN 'Atlanta' WHEN 2 THEN 'Chicago' WHEN 3 THEN 'Dallas' ELSE 'San Francisco' END,
    DATEADD(DAY, -UNIFORM(365, 3650, RANDOM()), CURRENT_DATE()),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Health Insurance' WHEN 1 THEN 'Auto Insurance' WHEN 2 THEN 'Life Insurance' ELSE 'Home Insurance' END,
    ROUND(UNIFORM(3.0, 5.0, RANDOM())::FLOAT, 1),
    UNIFORM(10, 80, RANDOM()),
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'CPCU, CLU' WHEN 1 THEN 'CIC, ARM' ELSE 'LUTCF, FLMI' END,
    TRUE
FROM TABLE(GENERATOR(ROWCOUNT => 25));


-- ############################################################################
-- CUSTOMERS (250 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.CORE.CUSTOMERS
(CUSTOMER_ID, FIRST_NAME, LAST_NAME, DATE_OF_BIRTH, AGE, GENDER, MARITAL_STATUS, EMAIL, PHONE, ADDRESS, CITY, STATE, ZIP_CODE, OCCUPATION, ANNUAL_INCOME, CREDIT_SCORE, SMOKING_STATUS, BMI, CUSTOMER_SINCE)
SELECT 
    'CUST-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    CASE MOD(SEQ4(), 20) WHEN 0 THEN 'John' WHEN 1 THEN 'Jane' WHEN 2 THEN 'Robert' WHEN 3 THEN 'Maria' WHEN 4 THEN 'William' WHEN 5 THEN 'Linda' WHEN 6 THEN 'Richard' WHEN 7 THEN 'Patricia' WHEN 8 THEN 'Joseph' WHEN 9 THEN 'Barbara' WHEN 10 THEN 'Thomas' WHEN 11 THEN 'Elizabeth' WHEN 12 THEN 'Charles' WHEN 13 THEN 'Jennifer' WHEN 14 THEN 'Daniel' WHEN 15 THEN 'Susan' WHEN 16 THEN 'Matthew' WHEN 17 THEN 'Margaret' WHEN 18 THEN 'Anthony' ELSE 'Dorothy' END,
    CASE MOD(SEQ4(), 15) WHEN 0 THEN 'Smith' WHEN 1 THEN 'Johnson' WHEN 2 THEN 'Brown' WHEN 3 THEN 'Davis' WHEN 4 THEN 'Miller' WHEN 5 THEN 'Wilson' WHEN 6 THEN 'Moore' WHEN 7 THEN 'Taylor' WHEN 8 THEN 'Anderson' WHEN 9 THEN 'Thomas' WHEN 10 THEN 'Jackson' WHEN 11 THEN 'White' WHEN 12 THEN 'Harris' WHEN 13 THEN 'Martin' ELSE 'Garcia' END,
    DATEADD(DAY, -UNIFORM(7300, 25550, RANDOM()), CURRENT_DATE()),
    UNIFORM(20, 70, RANDOM()),
    CASE MOD(SEQ4(), 2) WHEN 0 THEN 'Male' ELSE 'Female' END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Single' WHEN 1 THEN 'Married' WHEN 2 THEN 'Divorced' ELSE 'Widowed' END,
    'customer' || SEQ4()::VARCHAR || '@email.com',
    '555-' || LPAD(UNIFORM(1000, 9999, RANDOM())::VARCHAR, 4, '0'),
    UNIFORM(100, 9999, RANDOM())::VARCHAR || ' Oak St',
    CASE MOD(SEQ4(), 10) WHEN 0 THEN 'New York' WHEN 1 THEN 'Los Angeles' WHEN 2 THEN 'Chicago' WHEN 3 THEN 'Houston' WHEN 4 THEN 'Phoenix' WHEN 5 THEN 'Philadelphia' WHEN 6 THEN 'San Antonio' WHEN 7 THEN 'San Diego' WHEN 8 THEN 'Dallas' ELSE 'Atlanta' END,
    CASE MOD(SEQ4(), 10) WHEN 0 THEN 'NY' WHEN 1 THEN 'CA' WHEN 2 THEN 'IL' WHEN 3 THEN 'TX' WHEN 4 THEN 'AZ' WHEN 5 THEN 'PA' WHEN 6 THEN 'TX' WHEN 7 THEN 'CA' WHEN 8 THEN 'TX' ELSE 'GA' END,
    LPAD(UNIFORM(10000, 99999, RANDOM())::VARCHAR, 5, '0'),
    CASE MOD(SEQ4(), 8) WHEN 0 THEN 'Engineer' WHEN 1 THEN 'Teacher' WHEN 2 THEN 'Doctor' WHEN 3 THEN 'Accountant' WHEN 4 THEN 'Manager' WHEN 5 THEN 'Sales Rep' WHEN 6 THEN 'Nurse' ELSE 'Business Owner' END,
    ROUND(UNIFORM(30000, 200000, RANDOM()), 2),
    UNIFORM(580, 850, RANDOM()),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 20 THEN 'Yes' ELSE 'No' END,
    ROUND(UNIFORM(18.0, 40.0, RANDOM())::FLOAT, 1),
    DATEADD(DAY, -UNIFORM(30, 2500, RANDOM()), CURRENT_DATE())
FROM TABLE(GENERATOR(ROWCOUNT => 250));


-- ############################################################################
-- POLICIES (300 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.CORE.POLICIES
(POLICY_ID, CUSTOMER_ID, AGENT_ID, POLICY_TYPE, PLAN_TIER, POLICY_STATUS, START_DATE, END_DATE, PREMIUM_AMOUNT, COVERAGE_AMOUNT, DEDUCTIBLE, LOSS_RATIO, PAYMENT_FREQUENCY, AUTO_RENEW, UNDERWRITING_SCORE)
SELECT 
    'POL-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 249, RANDOM())::VARCHAR, 5, '0'),
    'AGT-' || LPAD(UNIFORM(0, 24, RANDOM())::VARCHAR, 4, '0'),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Health' WHEN 1 THEN 'Auto' WHEN 2 THEN 'Life' ELSE 'Home' END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Bronze' WHEN 1 THEN 'Silver' WHEN 2 THEN 'Gold' ELSE 'Platinum' END,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Active' WHEN 1 THEN 'Active' WHEN 2 THEN 'Active' WHEN 3 THEN 'Expired' ELSE 'Cancelled' END,
    DATEADD(DAY, -UNIFORM(30, 730, RANDOM()), CURRENT_DATE()),
    DATEADD(DAY, UNIFORM(30, 365, RANDOM()), CURRENT_DATE()),
    ROUND(UNIFORM(500, 15000, RANDOM()), 2),
    ROUND(UNIFORM(50000, 1000000, RANDOM()), 2),
    ROUND(UNIFORM(250, 5000, RANDOM()), 2),
    ROUND(UNIFORM(0.15, 0.95, RANDOM())::FLOAT, 2),
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'Monthly' WHEN 1 THEN 'Quarterly' ELSE 'Annual' END,
    CASE WHEN UNIFORM(0, 1, RANDOM()) > 0.3 THEN TRUE ELSE FALSE END,
    ROUND(UNIFORM(60.0, 98.0, RANDOM())::FLOAT, 1)
FROM TABLE(GENERATOR(ROWCOUNT => 300));


-- ############################################################################
-- CLAIMS (400 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.CORE.CLAIMS
(CLAIM_ID, POLICY_ID, CUSTOMER_ID, CLAIM_DATE, REPORTED_DATE, CLAIM_TYPE, CLAIM_STATUS, CLAIM_AMOUNT, APPROVED_AMOUNT, FRAUD_FLAG, FRAUD_SCORE, FRAUD_REASON, ASSIGNED_ADJUSTER, RESOLUTION_DATE, DAYS_TO_RESOLVE, PRIORITY, ESCALATED)
SELECT 
    'CLM-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'POL-' || LPAD(UNIFORM(0, 299, RANDOM())::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 249, RANDOM())::VARCHAR, 5, '0'),
    DATEADD(DAY, -UNIFORM(1, 365, RANDOM()), CURRENT_DATE()),
    DATEADD(DAY, -UNIFORM(1, 360, RANDOM()), CURRENT_DATE()),
    CASE MOD(SEQ4(), 8) WHEN 0 THEN 'Accident' WHEN 1 THEN 'Theft' WHEN 2 THEN 'Medical Emergency' WHEN 3 THEN 'Property Damage' WHEN 4 THEN 'Liability' WHEN 5 THEN 'Natural Disaster' WHEN 6 THEN 'Fire' ELSE 'Water Damage' END,
    CASE MOD(SEQ4(), 6) WHEN 0 THEN 'Open' WHEN 1 THEN 'Under Investigation' WHEN 2 THEN 'Approved' WHEN 3 THEN 'Closed' WHEN 4 THEN 'Denied' ELSE 'Escalated' END,
    ROUND(UNIFORM(500, 75000, RANDOM()), 2),
    CASE WHEN MOD(SEQ4(), 6) IN (2, 3) THEN ROUND(UNIFORM(400, 60000, RANDOM()), 2) ELSE NULL END,
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN TRUE ELSE FALSE END,
    ROUND(UNIFORM(0.0, 1.0, RANDOM())::FLOAT, 2),
    CASE WHEN UNIFORM(0, 100, RANDOM()) < 10 THEN CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Duplicate claim submitted' WHEN 1 THEN 'Inconsistent damage report' WHEN 2 THEN 'Staged accident suspected' WHEN 3 THEN 'Inflated repair costs' ELSE 'Policy purchased after incident' END ELSE NULL END,
    CASE MOD(SEQ4(), 8) WHEN 0 THEN 'Sarah Johnson' WHEN 1 THEN 'Michael Chen' WHEN 2 THEN 'Emily Rodriguez' WHEN 3 THEN 'David Kim' WHEN 4 THEN 'Jessica Williams' WHEN 5 THEN 'Robert Taylor' WHEN 6 THEN 'Amanda Martinez' ELSE 'Christopher Lee' END,
    CASE WHEN MOD(SEQ4(), 6) IN (2, 3, 4) THEN DATEADD(DAY, -UNIFORM(1, 30, RANDOM()), CURRENT_DATE()) ELSE NULL END,
    CASE WHEN MOD(SEQ4(), 6) IN (2, 3, 4) THEN UNIFORM(1, 45, RANDOM()) ELSE NULL END,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'High' WHEN 1 THEN 'Medium' ELSE 'Low' END,
    CASE WHEN MOD(SEQ4(), 6) = 5 THEN TRUE ELSE FALSE END
FROM TABLE(GENERATOR(ROWCOUNT => 400));

-- ============================================================================
-- END OF DML PART 1
-- ============================================================================
