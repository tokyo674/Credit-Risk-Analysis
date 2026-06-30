# Banking Portfolio Intelligence: Transforming Raw Transactions into Actionable NPL Mitigation Strategies
End-to-end data analytics project mapping default risk.
#### [click Here to See the Dashboard](https://datastudio.google.com/reporting/f90ec42c-8c1d-457a-8040-3980b3331927)
## Executive Summary
Proyek ini diinisiasi untuk memitigasi risiko kerugian bank akibat tingginya rasio Non-Performing Loan (NPL) yang menyentuh angka 11.1% dari total portofolio senilai 103.3 Juta CZK, sebuah kendala yang berakar dari terfragmentasinya data transaksi dan demografi nasabah (data silos). Sebagai solusi strategis, saya membangun end-to-end data pipeline menggunakan SQL untuk mengintegrasikan data mentah tersebut menjadi Single Source of Truth (SSoT), yang kemudian ditransformasikan menjadi executive dashboard interaktif. Pemodelan ini berhasil mengungkap titik kebocoran utama portofolio, di mana nasabah dengan eksposur pinjaman besar (>211K CZK) mencetak default rate kritis sebesar 20%, diperparah oleh anomali geografis di wilayah West Bohemia yang mencatatkan NPL tertinggi hingga 15.79%. Berdasarkan data-driven insights tersebut, rekomendasi lanjutan (next steps) yang diajukan kepada jajaran manajemen adalah implementasi restrukturisasi Loan-to-Value (LTV) sebesar 20% khusus di zona merah, serta pengetatan syarat jaminan (collateral) untuk high-tier loans guna mengamankan likuiditas dan menekan angka gagal bayar di masa depan.

### Business Problem
Ancaman kegagalan sistemik akibat tingginya rasio Non-Performing Loan (NPL) bank yang menyentuh angka 11.1% jauh melampaui batas aman industri. Dengan total eksposur dana mencapai 103.3 Juta CZK, penumpukan kredit macet ini berpotensi membekukan likuiditas dan memicu teguran regulasi. Sayangnya, jajaran manajemen terjebak dalam blind spot operasional akibat data transaksi dan profil demografi nasabah yang masih terfragmentasi (data silos). Kondisi ini memaksa bank merespons risiko secara reaktif dan buta arah. Oleh karena itu, inisiatif ini dieksekusi bukan sekadar untuk merakit dashboard pelaporan, melainkan untuk mengubah ekosistem bank menjadi institusi data-driven yang mampu memprediksi titik kebocoran kredit, memutus rantai risiko gagal bayar sebelum terjadi, dan mengamankan stabilitas profitabilitas jangka panjang.
### Methodology
1. Data Gathering & Integration: Mengintegrasikan data mentah (raw data) untuk memutus masalah data silos.
2. Data Manipulation & Transformation: Melakukan pembersihan data, penggabungan relasional (multi-table JOINs), serta optimalisasi kueri menggunakan Common Table Expressions (CTE) dan Window Functions guna membangun Single Source of Truth (SSoT).
3. Risk & Demographic Segmentation: Menerapkan logika kondisional (data binning) guna menganalisis sensitivitas gagal bayar.
4. Cohort & Vintage Analysis: Menganalisis pergeseran kualitas kredit dari tahun ke tahun berdasarkan angkatan regulasi pinjaman untuk mengidentifikasi lonjakan risiko default secara sistemik.
5. Insight Extraction & Strategic Formulation: Melakukan evaluasi kesenjangan (gap analysis) antara metrik portofolio aktual bank dengan standar sehat industri guna merumuskan rekomendasi manajemen yang terukur dan berdampak pada bisnis.
### Skills
1. Database Management:SQL (Advanced).
2. Data Engineering: Data Cleansing, Schema Design, Relational Modeling, Query Optimization.
3. Data Analytics: Vintage Analysis, Credit Risk Analytics, Segment Analysis, Cohort Analytics.
4. Data Storytelling & BI: Executive Dashboarding
### Results & Business Recommendation:
Berdasarkan pemodelan dan analisis data yang telah saya lakukan, teridentifikasi beberapa titik kebocoran utama pada portofolio kredit bank yang memicu tingginya risiko gagal bayar. Secara keseluruhan, rasio Non-Performing Loan (NPL) bank berada di angka kritis 11.1% dari total penyaluran kredit sebesar 103,3 Juta CZK, yang mengindikasikan adanya kelemahan mendasar pada proses screening awal nasabah. Risiko ini ternyata sangat terpusat pada segmen plafon besar, di mana pinjaman di atas 211K CZK mencatatkan default rate hingga 20% dimana itu hampir empat kali lipat lebih berisiko dibandingkan pinjaman bernominal kecil di bawah 67K CZK. Selain sensitivitas plafon, ditemukan juga ketimpangan kualitas kredit berbasis wilayah. West Bohemia terekam sebagai zona merah penyumbang kerugian terbesar dengan tingkat NPL mencapai 15.79%, kondisi yang sangat kontras jika dibandingkan dengan wilayah Ibu Kota (Prague) yang tergolong sehat di angka 8.33% dan wilayah North Bohemia yang hanya 1.64%. Masalah struktural ini semakin diperparah oleh adanya degradasi kualitas pada angkatan pinjaman tahun 1997, yang ditandai dengan lonjakan signifikan pada proporsi nasabah berstatus Running - Default.
### 
Untuk menekan angka default dan mengamankan profitabilitas kas, berikut adalah rekomendasi taktis yang dapat diimplementasikan oleh manajemen:

1. Penyesuaian LTV Berbasis Geografis (Geo-Specific De-risking)
Menurunkan batas Loan-to-Value (LTV) maksimal sebesar 20% khusus untuk pengajuan kredit baru di wilayah zona merah seperti West Bohamia. Strategi ini membatasi eksposur bank terhadap risiko ekonomi lokal tanpa harus menghentikan penyaluran kredit sepenuhnya.

2. Restrukturisasi Syarat Plafon Besar
Memperketat proses underwriting dengan mewajibkan tambahan jaminan (collateral) likuid untuk setiap pengajuan pinjaman di atas ambang batas 211K CZK, mengingat segmen inilah yang menjadi penyumbang risiko kerugian terbesar.

3. Implementasi Early Warning System (EWS)
Memanfaatkan metrik fluktuasi rata-rata saldo bulanan (yang telah dipetakan dalam Single Source of Truth) sebagai indikator peringatan dini. Jika saldo nasabah aktif turun drastis di bawah ambang batas tertentu, sistem akan memberikan alert otomatis kepada tim Collection untuk melakukan intervensi sebelum nasabah benar-benar masuk ke fase default.
### Next Steps
1. Pipeline Automation: Mengotomatisasi alur data di Google BigQuery agar pembaruan metrik di dashboard berjalan real-time tanpa intervensi manual.

2. RFM Model Integration: Mengembangkan segmentasi nasabah menggunakan model RFM (Recency, Frequency, Monetary) untuk melacak pola historis pembayaran dan keterlambatan secara lebih granular.

3. Predictive Credit Scoring: Memanfaatkan dataset Single Source of Truth yang sudah divalidasi ini sebagai fondasi Machine Learning untuk memprediksi probabilitas gagal bayar sejak awal pengajuan kredit.
