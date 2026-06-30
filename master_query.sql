--Data Cleaning
--merubah bahasa ceko ke inggris dan merubah format date yang salah

CREATE VIEW `czech-500907.Datalake.v_account_clean` AS
SELECT
  account_id,
  district_id,
  CASE
    WHEN frequency = 'POPLATEK MESICNE' THEN 'Monthly'
    WHEN frequency = 'POPLATEK PO OBRATU' THEN 'After Transaction'
    WHEN frequency = 'POPLATEK TYDNE' THEN 'Weekly'
    ELSE 'Unknown'
  END AS frequency_cleaned,

  PARSE_DATE('%y%m%d', CAST(date AS STRING)) AS account_created_date
FROM `czech-500907.Datalake.account`;

--Mengubah kolom birth_number menjadi gender dan tanggal lahir
-- Ada 6 angka pada kolom ini 2 angka didepan tahun lahir, 2 angka di tengah bulan/gender (Bila bulan > 50 makan wanita), dan 2 angka di akhir tanggal

CREATE VIEW `czech-500907.Datalake.v_client_clean` AS
SELECT
  client_id,
  district_id,
  CASE
    WHEN CAST(SUBSTRING(CAST(birth_number AS STRING), 3, 2) AS INT)>50 THEN 'Female'
    ELSE 'Male'
  END AS gender,

  CONCAT(
    '19', SUBSTRING(CAST(birth_number AS STRING), 1, 2), '-',

    CASE
      WHEN CAST(SUBSTRING(CAST(birth_number AS STRING), 3, 2) AS INT) > 50
      THEN CAST(SUBSTRING(CAST(birth_number AS STRING), 3, 2) AS INT) - 50
      ELSE CAST(SUBSTRING(CAST(birth_number AS STRING), 3, 2) AS INT)
    END, '-',
    SUBSTRING(CAST(birth_number AS STRING), 5, 2)
  ) AS date_of_birth
FROM `czech-500907.Datalake.client`;

--Membersihkan tabel trans

CREATE TABLE `czech-500907.Datalake.trans_clean` AS
SELECT
  trans_id,
  account_id,

  PARSE_DATE('%y%m%d', CAST(date AS STRING)) AS transaction_date,

  CASE
    WHEN type = 'PRIJEM' THEN 'Credit'
    WHEN type = 'VYDAJ' THEN 'Withdrawal'
    WHEN type = 'VYBER' THEN 'Withdrawal'
    ELSE 'Unknown'
  END AS transaction_type,

  CASE 
        WHEN operation = 'VKLAD' THEN 'Cash Deposit'
        WHEN operation = 'VYBER' THEN 'Cash Withdrawal'
        WHEN operation = 'PREVOD Z UCTU' THEN 'Collection from another bank'
        WHEN operation = 'PREVOD NA UCET' THEN 'Remittance to another bank'
        WHEN operation = 'VYBER KARTOU' THEN 'Credit Card Withdrawal'
        WHEN operation = '' OR operation IS NULL THEN 'Other / Cash'
        ELSE operation
    END AS operation_cleaned,
    amount,
    balance,

    CASE 
        WHEN k_symbol = 'UROK' THEN 'Interest Credited'
        WHEN k_symbol = 'SIPO' THEN 'Household Payment'
        WHEN k_symbol = 'SLUZBY' THEN 'Service Charge'
        WHEN k_symbol = 'POJISTNE' THEN 'Insurance Payment'
        WHEN k_symbol = 'UVER' THEN 'Loan Payment'
        WHEN k_symbol = 'DUCHOD' THEN 'Old-age Pension'
        WHEN k_symbol = 'VRELOST' THEN 'Interest on Sanction'
        WHEN k_symbol = '' OR k_symbol IS NULL THEN 'Other / Unspecified'
        ELSE k_symbol
    END AS k_symbol_cleaned,

    CASE WHEN bank = '' THEN NULL ELSE bank END AS bank_partner,
    CASE WHEN account = 0 THEN NULL ELSE account END AS account_partner

FROM `czech-500907.Datalake.trans`;

--cleaning data district

CREATE OR REPLACE VIEW `czech-500907.Datalake.district_clean` AS
SELECT 
    A1 AS district_id,
    A2 AS district_name,
    A3 AS region,
    A4 AS num_inhabitants,                  -- Jumlah penduduk
    A5 AS num_municipalities_under_499,     -- Jml desa penduduk < 499
    A6 AS num_municipalities_500_1999,      -- Jml desa penduduk 500-1999
    A7 AS num_municipalities_2000_9999,      -- Jml desa penduduk 2000-9999
    A8 AS num_municipalities_over_10000,    -- Jml kota penduduk > 10000
    A9 AS num_cities,                       -- Jumlah kota pembantu
    A10 AS urban_inhabitants_ratio,         -- Rasio penduduk yang tinggal di kota (%)
    A11 AS average_salary,                  -- Rata-rata gaji penduduk
    
    CASE WHEN A12 = '?' THEN NULL ELSE CAST(A12 AS DECIMAL) END AS unemployment_rate_95,
    CAST(A13 AS DECIMAL) AS unemployment_rate_96,
    
    A14 AS num_entrepreneurs_per_1000,
    
    CASE WHEN A15 = '?' THEN NULL ELSE CAST(A15 AS INT) END AS committed_crimes_95,
    CAST(A16 AS INT) AS committed_crimes_96

FROM `czech-500907.Datalake.district`;

--cleaning table loan

CREATE TABLE `czech-500907.Datalake.loan_clean` AS
SELECT
  loan_id,
  account_id,
  PARSE_DATE('%y%m%d', CAST(date AS STRING)) AS loan_date,

  amount AS loan_amount,
  duration AS loan_duration_months,
  payments AS monthly_payment,

  CASE
    WHEN status = 'A' THEN 'Finished - Good'
    WHEN status = 'B' THEN 'Finished - Default'
    WHEN status = 'C' THEN 'Running - Good'
    WHEN status = 'D' THEN 'Running - Default'
  END AS status_description,

  CASE
    WHEN status IN ('B', 'D') THEN 1
    ELSE 0
  END AS is_default

FROM `czech-500907.Datalake.loan`;

--cleaning data card

CREATE TABLE `czech-500907.Datalake.card_clean` AS 
SELECT
  card_id,
  disp_id,
  type AS card_type,

  PARSE_DATE('%y%m%d', SUBSTR(CAST(issued AS STRING), 1, 6)) AS issued_date
FROM `czech-500907.Datalake.card`;



CREATE TABLE `czech-500907.Datalake.master_credit_risk` as

WITH trans_summary AS (
  SELECT
    account_id,
    ROUND(AVG(balance), 2) AS avg_balance,
    ROUND(MIN(balance), 2) AS min_balance,
    COUNT(trans_id) AS total_transaction_count,
    ROUND(SUM(CASE WHEN transaction_type = 'Credit' THEN amount ELSE 0 END), 2) AS total_money_in,
    ROUND(SUM(CASE WHEN transaction_type = 'Withdrawal' THEN amount ELSE 0 END), 2) AS total_money_out,
  FROM `czech-500907.Datalake.trans_clean`
  GROUP BY account_id
),

client_owner AS (
  SELECT
    d.account_id,
    c.client_id,
    c.gender,
    c.date_of_birth
  FROM `czech-500907.Datalake.disp` d
  JOIN `czech-500907.Datalake.v_client_clean` c ON d.client_id = c.client_id
  WHERE d.type = 'OWNER'
)

SELECT 
    l.loan_id,
    l.account_id,
    l.loan_date,
    l.loan_amount,
    l.loan_duration_months,
    l.monthly_payment,
    l.status_description,
    l.is_default, -- Target variabel kita (1 = macet, 0 = lancar)
    
    co.client_id,
    co.gender,
    co.date_of_birth,
    
    a.frequency_cleaned AS account_statement_frequency,
    a.account_created_date,
    dist.district_name,
    dist.region,
    dist.average_salary AS district_avg_salary,
    dist.unemployment_rate_96 AS district_unemployment_rate,
    
    ts.avg_balance,
    ts.min_balance,
    ts.total_transaction_count,
    ts.total_money_in,
    ts.total_money_out

FROM `czech-500907.Datalake.loan_clean` l
JOIN `czech-500907.Datalake.v_account_clean` a ON l.account_id = a.account_id
JOIN client_owner co ON l.account_id = co.account_id
JOIN `czech-500907.Datalake.district_clean` dist ON a.district_id = dist.district_id
LEFT JOIN trans_summary ts ON l.account_id = ts.account_id;
