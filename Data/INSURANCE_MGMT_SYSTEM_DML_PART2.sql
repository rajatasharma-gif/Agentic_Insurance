-- ============================================================================
-- INSURANCE MANAGEMENT SYSTEM - DML Part 2: Premium & Risk Tables
-- Database: INSURANCE_MGMT_SYSTEM
-- Run AFTER: INSURANCE_MGMT_SYSTEM_DML_PART1.sql
-- ============================================================================


-- ############################################################################
-- PLAN_TIERS (16 rows - 4 types x 4 tiers)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.PREMIUM.PLAN_TIERS
(TIER_ID, POLICY_TYPE, PLAN_NAME, MONTHLY_PREMIUM, ANNUAL_PREMIUM, COVERAGE_LIMIT, DEDUCTIBLE, COPAY_PCT, KEY_BENEFITS, RECOMMENDED_FOR)
VALUES
('TIER-001','Health','Bronze',250.00,2750.00,100000.00,5000.00,40,'Basic hospitalization, limited outpatient, generic Rx','Young healthy individuals'),
('TIER-002','Health','Silver',450.00,4950.00,250000.00,2500.00,30,'Full hospitalization, outpatient, brand Rx, preventive care','Families, moderate health needs'),
('TIER-003','Health','Gold',700.00,7700.00,500000.00,1000.00,20,'Comprehensive coverage, specialist access, dental, vision','Comprehensive coverage seekers'),
('TIER-004','Health','Platinum',1100.00,12100.00,1000000.00,500.00,10,'All-inclusive, concierge medicine, global coverage','Executive, premium service'),
('TIER-005','Auto','Bronze',80.00,880.00,50000.00,2000.00,0,'Liability only, basic collision','Budget-conscious, older vehicles'),
('TIER-006','Auto','Silver',150.00,1650.00,150000.00,1000.00,0,'Liability + collision + comprehensive','Standard drivers, newer vehicles'),
('TIER-007','Auto','Gold',250.00,2750.00,300000.00,500.00,0,'Full coverage + rental + roadside','Multiple vehicles, families'),
('TIER-008','Auto','Platinum',400.00,4400.00,500000.00,250.00,0,'All coverage + gap + custom parts + diminished value','Luxury/sports car owners'),
('TIER-009','Life','Bronze',30.00,330.00,100000.00,0.00,0,'Term 10yr, basic death benefit','Young adults, budget option'),
('TIER-010','Life','Silver',75.00,825.00,250000.00,0.00,0,'Term 20yr, death + disability waiver','Growing families'),
('TIER-011','Life','Gold',150.00,1650.00,500000.00,0.00,0,'Term 30yr, death + AD&D + child rider','Established families, mortgage protection'),
('TIER-012','Life','Platinum',300.00,3300.00,1000000.00,0.00,0,'Whole life, cash value, dividends, LTC rider','Wealth preservation, estate planning'),
('TIER-013','Home','Bronze',60.00,660.00,150000.00,2500.00,0,'Dwelling + basic personal property','Condos, smaller homes'),
('TIER-014','Home','Silver',120.00,1320.00,350000.00,1500.00,0,'Dwelling + property + liability + ALE','Average single-family homes'),
('TIER-015','Home','Gold',200.00,2200.00,600000.00,1000.00,0,'Enhanced dwelling + scheduled items + water backup','Higher-value homes'),
('TIER-016','Home','Platinum',350.00,3850.00,1000000.00,500.00,0,'Guaranteed replacement + all perils + identity theft','Luxury homes, high-net-worth');


-- ############################################################################
-- PREMIUM_FACTORS (80 rows - Rating factors by type)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.PREMIUM.PREMIUM_FACTORS
(FACTOR_ID, POLICY_TYPE, FACTOR_NAME, FACTOR_CATEGORY, FACTOR_VALUE, MULTIPLIER, BASE_RATE, DESCRIPTION, EFFECTIVE_DATE, ACTIVE_FLAG)
VALUES
('PF-001','Health','Age 18-25','Age','18-25',0.85,250.00,'Young adult discount','2024-01-01',TRUE),
('PF-002','Health','Age 26-35','Age','26-35',1.00,250.00,'Standard base rate','2024-01-01',TRUE),
('PF-003','Health','Age 36-45','Age','36-45',1.20,250.00,'Moderate age increase','2024-01-01',TRUE),
('PF-004','Health','Age 46-55','Age','46-55',1.50,250.00,'Higher risk age bracket','2024-01-01',TRUE),
('PF-005','Health','Age 56-65','Age','56-65',1.85,250.00,'Pre-retirement bracket','2024-01-01',TRUE),
('PF-006','Health','Age 65+','Age','65+',2.20,250.00,'Senior rate','2024-01-01',TRUE),
('PF-007','Health','Non-Smoker','Lifestyle','Non-Smoker',1.00,0.00,'No lifestyle surcharge','2024-01-01',TRUE),
('PF-008','Health','Smoker','Lifestyle','Smoker',1.50,0.00,'Tobacco use surcharge','2024-01-01',TRUE),
('PF-009','Health','BMI Normal','Health','BMI 18-25',1.00,0.00,'Normal BMI','2024-01-01',TRUE),
('PF-010','Health','BMI Overweight','Health','BMI 25-30',1.10,0.00,'Overweight factor','2024-01-01',TRUE),
('PF-011','Health','BMI Obese','Health','BMI 30+',1.30,0.00,'Obesity factor','2024-01-01',TRUE),
('PF-012','Health','Urban','Location','Urban',1.15,0.00,'Urban area surcharge','2024-01-01',TRUE),
('PF-013','Health','Suburban','Location','Suburban',1.00,0.00,'Standard suburban rate','2024-01-01',TRUE),
('PF-014','Health','Rural','Location','Rural',1.05,0.00,'Rural access factor','2024-01-01',TRUE),
('PF-015','Health','No Claims','Claims History','0 claims',0.90,0.00,'Claims-free discount','2024-01-01',TRUE),
('PF-016','Health','1-2 Claims','Claims History','1-2 claims',1.10,0.00,'Low claims history','2024-01-01',TRUE),
('PF-017','Health','3+ Claims','Claims History','3+ claims',1.40,0.00,'High claims surcharge','2024-01-01',TRUE),
('PF-018','Health','Family Plan','Coverage','Family',1.80,0.00,'Family coverage multiplier','2024-01-01',TRUE),
('PF-019','Health','Individual','Coverage','Individual',1.00,0.00,'Individual coverage','2024-01-01',TRUE),
('PF-020','Health','Couple','Coverage','Couple',1.45,0.00,'Couple coverage','2024-01-01',TRUE),
('PF-021','Auto','Age 16-25','Age','16-25',1.75,80.00,'Young driver surcharge','2024-01-01',TRUE),
('PF-022','Auto','Age 26-35','Age','26-35',1.10,80.00,'Standard young adult','2024-01-01',TRUE),
('PF-023','Auto','Age 36-50','Age','36-50',1.00,80.00,'Prime driver rate','2024-01-01',TRUE),
('PF-024','Auto','Age 51-65','Age','51-65',1.05,80.00,'Mature driver','2024-01-01',TRUE),
('PF-025','Auto','Age 65+','Age','65+',1.25,80.00,'Senior driver factor','2024-01-01',TRUE),
('PF-026','Auto','Clean Record','Driving History','Clean',0.85,0.00,'Safe driver discount','2024-01-01',TRUE),
('PF-027','Auto','1 Violation','Driving History','1 violation',1.15,0.00,'Minor violation surcharge','2024-01-01',TRUE),
('PF-028','Auto','2+ Violations','Driving History','2+ violations',1.50,0.00,'Multiple violations','2024-01-01',TRUE),
('PF-029','Auto','DUI History','Driving History','DUI',2.50,0.00,'DUI surcharge','2024-01-01',TRUE),
('PF-030','Auto','New Vehicle','Vehicle Age','0-2 years',1.20,0.00,'New vehicle rate','2024-01-01',TRUE),
('PF-031','Auto','Mid Vehicle','Vehicle Age','3-7 years',1.00,0.00,'Standard vehicle','2024-01-01',TRUE),
('PF-032','Auto','Old Vehicle','Vehicle Age','8+ years',0.85,0.00,'Older vehicle discount','2024-01-01',TRUE),
('PF-033','Auto','Sedan','Vehicle Type','Sedan',1.00,0.00,'Standard sedan rate','2024-01-01',TRUE),
('PF-034','Auto','SUV','Vehicle Type','SUV',1.10,0.00,'SUV factor','2024-01-01',TRUE),
('PF-035','Auto','Sports Car','Vehicle Type','Sports',1.45,0.00,'Sports car surcharge','2024-01-01',TRUE),
('PF-036','Auto','Truck','Vehicle Type','Truck',1.15,0.00,'Truck factor','2024-01-01',TRUE),
('PF-037','Auto','Urban','Location','Urban',1.30,0.00,'Urban driving surcharge','2024-01-01',TRUE),
('PF-038','Auto','Suburban','Location','Suburban',1.00,0.00,'Suburban standard','2024-01-01',TRUE),
('PF-039','Auto','Rural','Location','Rural',0.90,0.00,'Rural discount','2024-01-01',TRUE),
('PF-040','Auto','High Mileage','Usage','15K+ miles',1.20,0.00,'High mileage surcharge','2024-01-01',TRUE),
('PF-041','Life','Age 18-30','Age','18-30',0.70,30.00,'Young adult rate','2024-01-01',TRUE),
('PF-042','Life','Age 31-40','Age','31-40',1.00,30.00,'Standard rate','2024-01-01',TRUE),
('PF-043','Life','Age 41-50','Age','41-50',1.50,30.00,'Middle age factor','2024-01-01',TRUE),
('PF-044','Life','Age 51-60','Age','51-60',2.20,30.00,'Pre-senior factor','2024-01-01',TRUE),
('PF-045','Life','Age 61-70','Age','61-70',3.50,30.00,'Senior factor','2024-01-01',TRUE),
('PF-046','Life','Non-Smoker','Lifestyle','Non-Smoker',1.00,0.00,'Standard health','2024-01-01',TRUE),
('PF-047','Life','Smoker','Lifestyle','Smoker',2.00,0.00,'Tobacco surcharge','2024-01-01',TRUE),
('PF-048','Life','Excellent Health','Health','Excellent',0.80,0.00,'Preferred plus rate','2024-01-01',TRUE),
('PF-049','Life','Good Health','Health','Good',1.00,0.00,'Standard rate','2024-01-01',TRUE),
('PF-050','Life','Fair Health','Health','Fair',1.40,0.00,'Substandard rate','2024-01-01',TRUE),
('PF-051','Life','Poor Health','Health','Poor',2.00,0.00,'High risk rate','2024-01-01',TRUE),
('PF-052','Life','No Family Hx','Family History','None',1.00,0.00,'No family history issues','2024-01-01',TRUE),
('PF-053','Life','Heart Disease Hx','Family History','Heart Disease',1.30,0.00,'Cardiac family history','2024-01-01',TRUE),
('PF-054','Life','Cancer Hx','Family History','Cancer',1.25,0.00,'Cancer family history','2024-01-01',TRUE),
('PF-055','Life','Desk Job','Occupation','Low Risk',1.00,0.00,'Standard occupation','2024-01-01',TRUE),
('PF-056','Life','Manual Labor','Occupation','Medium Risk',1.20,0.00,'Physical labor factor','2024-01-01',TRUE),
('PF-057','Life','Hazardous Job','Occupation','High Risk',1.75,0.00,'Hazardous occupation','2024-01-01',TRUE),
('PF-058','Life','$100K Coverage','Coverage Amount','$100K',1.00,0.00,'Base coverage amount','2024-01-01',TRUE),
('PF-059','Life','$500K Coverage','Coverage Amount','$500K',4.50,0.00,'Mid coverage','2024-01-01',TRUE),
('PF-060','Life','$1M Coverage','Coverage Amount','$1M',8.50,0.00,'High coverage','2024-01-01',TRUE),
('PF-061','Home','Home Value Low','Property Value','Under $200K',0.80,60.00,'Lower value home','2024-01-01',TRUE),
('PF-062','Home','Home Value Mid','Property Value','$200K-$500K',1.00,60.00,'Standard value home','2024-01-01',TRUE),
('PF-063','Home','Home Value High','Property Value','$500K-$1M',1.50,60.00,'Higher value home','2024-01-01',TRUE),
('PF-064','Home','Home Value Luxury','Property Value','$1M+',2.20,60.00,'Luxury home','2024-01-01',TRUE),
('PF-065','Home','New Construction','Property Age','0-5 years',0.85,0.00,'New build discount','2024-01-01',TRUE),
('PF-066','Home','Modern Home','Property Age','6-20 years',1.00,0.00,'Standard age','2024-01-01',TRUE),
('PF-067','Home','Older Home','Property Age','21-50 years',1.20,0.00,'Older home surcharge','2024-01-01',TRUE),
('PF-068','Home','Historic Home','Property Age','50+ years',1.45,0.00,'Historic/aging factor','2024-01-01',TRUE),
('PF-069','Home','Low Risk Zone','Location Risk','Zone 1',0.90,0.00,'Low risk area','2024-01-01',TRUE),
('PF-070','Home','Medium Risk Zone','Location Risk','Zone 2',1.00,0.00,'Standard risk area','2024-01-01',TRUE),
('PF-071','Home','High Risk Zone','Location Risk','Zone 3',1.35,0.00,'High risk (flood/fire)','2024-01-01',TRUE),
('PF-072','Home','Coastal Zone','Location Risk','Zone 4',1.60,0.00,'Coastal/hurricane zone','2024-01-01',TRUE),
('PF-073','Home','Security System','Safety Features','Alarm',0.90,0.00,'Security discount','2024-01-01',TRUE),
('PF-074','Home','No Security','Safety Features','None',1.00,0.00,'No safety discount','2024-01-01',TRUE),
('PF-075','Home','Fire Sprinklers','Safety Features','Sprinklers',0.85,0.00,'Fire protection discount','2024-01-01',TRUE),
('PF-076','Home','Frame Construction','Construction','Wood Frame',1.10,0.00,'Wood frame surcharge','2024-01-01',TRUE),
('PF-077','Home','Brick Construction','Construction','Brick',1.00,0.00,'Standard brick','2024-01-01',TRUE),
('PF-078','Home','Concrete Construction','Construction','Concrete',0.90,0.00,'Fire-resistant discount','2024-01-01',TRUE),
('PF-079','Home','No Claims 3yr','Claims History','0 claims 3yr',0.85,0.00,'Claims-free discount','2024-01-01',TRUE),
('PF-080','Home','Claims History','Claims History','1+ claims 3yr',1.25,0.00,'Prior claims surcharge','2024-01-01',TRUE);


-- ############################################################################
-- PREMIUM_CALCULATIONS (500 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.PREMIUM.PREMIUM_CALCULATIONS
(CALC_ID, CUSTOMER_ID, POLICY_TYPE, PLAN_TIER, CALC_DATE, BASE_PREMIUM, AGE_FACTOR, LOCATION_FACTOR, HEALTH_FACTOR, LIFESTYLE_FACTOR, CLAIMS_HISTORY_FACTOR, FINAL_PREMIUM, DISCOUNT_APPLIED, FACTOR_BREAKDOWN)
SELECT 
    'CALC-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 249, RANDOM())::VARCHAR, 5, '0'),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Health' WHEN 1 THEN 'Auto' WHEN 2 THEN 'Life' ELSE 'Home' END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Bronze' WHEN 1 THEN 'Silver' WHEN 2 THEN 'Gold' ELSE 'Platinum' END,
    DATEADD(DAY, -UNIFORM(1, 180, RANDOM()), CURRENT_TIMESTAMP()),
    ROUND(UNIFORM(200, 1200, RANDOM()), 2),
    ROUND(UNIFORM(0.70, 2.20, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.85, 1.60, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.80, 1.50, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.85, 2.00, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.85, 1.50, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(300, 15000, RANDOM()), 2),
    ROUND(UNIFORM(0, 500, RANDOM()), 2),
    'Age: ' || ROUND(UNIFORM(0.70, 2.20, RANDOM())::FLOAT, 2)::VARCHAR || 'x | Location: ' || ROUND(UNIFORM(0.85, 1.60, RANDOM())::FLOAT, 2)::VARCHAR || 'x | Health: ' || ROUND(UNIFORM(0.80, 1.50, RANDOM())::FLOAT, 2)::VARCHAR || 'x'
FROM TABLE(GENERATOR(ROWCOUNT => 500));


-- ############################################################################
-- AT_RISK_POLICIES (165 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.RISK.AT_RISK_POLICIES
(RISK_ID, POLICY_ID, CUSTOMER_ID, POLICY_TYPE, RISK_CATEGORY, RISK_SCORE, REVENUE_AT_RISK, CHURN_PROBABILITY, RISK_DRIVERS, LAST_INTERACTION_DATE, DAYS_SINCE_CONTACT, COMPLAINTS_COUNT, MISSED_PAYMENTS, RECOMMENDED_ACTION, PRIORITY, IDENTIFIED_DATE)
SELECT 
    'RISK-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'POL-' || LPAD(UNIFORM(0, 299, RANDOM())::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 249, RANDOM())::VARCHAR, 5, '0'),
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Health' WHEN 1 THEN 'Auto' WHEN 2 THEN 'Life' ELSE 'Home' END,
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Payment Default' WHEN 1 THEN 'High Claims Frequency' WHEN 2 THEN 'Customer Complaint' WHEN 3 THEN 'Policy Lapse Risk' ELSE 'Competitive Switch' END,
    ROUND(UNIFORM(0.55, 0.98, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(1500, 7500, RANDOM()), 2),
    ROUND(UNIFORM(0.4, 0.95, RANDOM())::FLOAT, 2),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN 'Missed 2+ payments, declining engagement' WHEN 1 THEN '3+ claims in 6 months, high utilization' WHEN 2 THEN 'Unresolved complaint, negative survey' WHEN 3 THEN 'No renewal confirmation, shopping competitors' ELSE 'Competitor quote received, price sensitivity' END,
    DATEADD(DAY, -UNIFORM(15, 120, RANDOM()), CURRENT_DATE()),
    UNIFORM(15, 120, RANDOM()),
    UNIFORM(0, 8, RANDOM()),
    UNIFORM(0, 4, RANDOM()),
    CASE MOD(SEQ4(), 6) WHEN 0 THEN 'Immediate outreach by retention team' WHEN 1 THEN 'Offer premium discount for renewal' WHEN 2 THEN 'Escalate to account manager' WHEN 3 THEN 'Send policy benefits reminder' WHEN 4 THEN 'Schedule claims review meeting' ELSE 'Initiate loyalty program enrollment' END,
    CASE MOD(SEQ4(), 3) WHEN 0 THEN 'Critical' WHEN 1 THEN 'High' ELSE 'Medium' END,
    DATEADD(DAY, -UNIFORM(1, 60, RANDOM()), CURRENT_DATE())
FROM TABLE(GENERATOR(ROWCOUNT => 165));


-- ############################################################################
-- CHURN_PREDICTIONS (300 rows)
-- ############################################################################

INSERT INTO INSURANCE_MGMT_SYSTEM.RISK.CHURN_PREDICTIONS
(PREDICTION_ID, POLICY_ID, CUSTOMER_ID, PREDICTION_DATE, CHURN_PROBABILITY, CONFIDENCE_SCORE, TOP_RISK_FACTOR, SECOND_RISK_FACTOR, PREDICTED_CHURN_DATE, RETENTION_OFFER, OUTCOME)
SELECT 
    'PRED-' || LPAD(SEQ4()::VARCHAR, 5, '0'),
    'POL-' || LPAD(UNIFORM(0, 299, RANDOM())::VARCHAR, 5, '0'),
    'CUST-' || LPAD(UNIFORM(0, 249, RANDOM())::VARCHAR, 5, '0'),
    DATEADD(DAY, -UNIFORM(1, 90, RANDOM()), CURRENT_DATE()),
    ROUND(UNIFORM(0.10, 0.95, RANDOM())::FLOAT, 2),
    ROUND(UNIFORM(0.60, 0.98, RANDOM())::FLOAT, 2),
    CASE MOD(SEQ4(), 8) WHEN 0 THEN 'Payment History' WHEN 1 THEN 'Claims Frequency' WHEN 2 THEN 'Low Engagement' WHEN 3 THEN 'Price Sensitivity' WHEN 4 THEN 'Competitor Activity' WHEN 5 THEN 'Complaint History' WHEN 6 THEN 'Policy Expiration' ELSE 'Coverage Reduction' END,
    CASE MOD(SEQ4(), 6) WHEN 0 THEN 'Low Engagement' WHEN 1 THEN 'Payment Issues' WHEN 2 THEN 'Price Sensitivity' WHEN 3 THEN 'Service Issues' WHEN 4 THEN 'Life Event' ELSE 'Market Competition' END,
    DATEADD(DAY, UNIFORM(15, 180, RANDOM()), CURRENT_DATE()),
    CASE MOD(SEQ4(), 5) WHEN 0 THEN '10% premium discount' WHEN 1 THEN 'Loyalty points bonus' WHEN 2 THEN 'Free coverage upgrade' WHEN 3 THEN 'Dedicated agent assignment' ELSE 'Bundle discount offer' END,
    CASE MOD(SEQ4(), 4) WHEN 0 THEN 'Retained' WHEN 1 THEN 'Churned' WHEN 2 THEN 'Pending' ELSE 'Retained' END
FROM TABLE(GENERATOR(ROWCOUNT => 300));

-- ============================================================================
-- END OF DML PART 2
-- ============================================================================
