--Menghitung NPL & Total Kerugian
SELECT
  status_description,
  is_default,
  COUNT(loan_id) AS total_nasabah,
  ROUND(SUM(loan_amount), 2) AS total_uang_dipinjamkan,
  ROUND(COUNT(loan_id) * 100.0 / SUM(COUNT(loan_id)) OVER(), 2) AS persentase_nasabah_persen
FROM `czech-500907.Datalake.master_credit_risk`
GROUP BY 
    status_description, 
    is_default
ORDER BY 
    is_default DESC;

--Membandingkan Saldo Nasabah Macet vs. Lancar

SELECT
  CASE
    WHEN is_default = 1 THEN 'Macet (Default)'
    ELSE 'Lancar (Good)'
  END AS profil_kredit,

  COUNT(loan_id) AS jumlah_nasabah,
  ROUND(AVG(avg_balance), 2) AS rata_rata_saldo_mengendap,
  ROUND(AVG(min_balance), 2) AS rata_rata_saldo_terendah,
  ROUND(AVG(total_transaction_count), 0) AS rata_rata_jumlah_transaksi
FROM `czech-500907.Datalake.master_credit_risk`
GROUP BY
  profil_kredit;

--Analisis Demografi: Siapa yang Paling Sering Macet? (Gender & Umur)

SELECT
  gender,
  CASE
    WHEN EXTRACT(YEAR FROM loan_date) - EXTRACT(YEAR FROM CAST(date_of_birth AS DATE)) <= 30 THEN 'Youth (<= 30)'
    WHEN EXTRACT(YEAR FROM loan_date) - EXTRACT(YEAR FROM CAST(date_of_birth AS DATE)) BETWEEN 31 AND 45 THEN 'Adult (31-45)'
    WHEN EXTRACT(YEAR FROM loan_date) - EXTRACT(YEAR FROM CAST(date_of_birth AS DATE)) BETWEEN 46 AND 60 THEN 'Senior (46-60)'
    ELSE 'Elderly (> 60)'
  END AS kelompok_umur,

  COUNT(loan_id) AS total_pinjaman,
    SUM(is_default) AS jumlah_macet,
    ROUND(SUM(is_default) * 100.0 / COUNT(loan_id), 2) AS persentase_macet_persen
FROM `czech-500907.Datalake.master_credit_risk`
GROUP BY 
    gender, 
    kelompok_umur
ORDER BY 
    persentase_macet_persen DESC;

--Analisis Makroekonomi: Pengaruh Tingkat Pengangguran Daerah

SELECT 
    CASE 
        WHEN district_unemployment_rate >= 5.0 THEN 'Tinggi (>= 5%)'
        WHEN district_unemployment_rate BETWEEN 3.0 AND 4.99 THEN 'Sedang (3% - 4.9%)'
        ELSE 'Rendah (< 3%)'
    END AS tingkat_pengangguran_daerah,
    
    COUNT(loan_id) AS total_nasabah,
    ROUND(AVG(loan_amount), 2) AS rata_rata_nominal_pinjaman,
    ROUND(SUM(is_default) * 100.0 / COUNT(loan_id), 2) AS rasio_kredit_macet_persen
FROM `czech-500907.Datalake.master_credit_risk`
GROUP BY 
    tingkat_pengangguran_daerah
ORDER BY 
    rasio_kredit_macet_persen DESC;

--Analisis Beban Tenor (Lama Pinjaman)
SELECT 
    loan_duration_months AS tenor_bulan,
    COUNT(loan_id) AS total_pinjaman,
    ROUND(AVG(monthly_payment), 2) AS rata_rata_cicilan_bulanan,
    SUM(is_default) AS jumlah_macet,
    ROUND(SUM(is_default) * 100.0 / COUNT(loan_id), 2) AS tingkat_kemacetan_persen
FROM `czech-500907.Datalake.master_credit_risk`
GROUP BY 
    loan_duration_months
ORDER BY 
    loan_duration_months ASC;
