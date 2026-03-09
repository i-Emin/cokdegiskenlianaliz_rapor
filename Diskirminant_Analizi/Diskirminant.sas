/* ============================================================
   DİSKRİMİNANT ANALİZİ
   Hedef Değişken: Saglik_Riski_Seviyesi
   Bağımsız Değişkenler: Stress_Seviyesi_Biosensor, 
                         Stress_Seviyesi_Bildirim,
                         Ders_Saatleri, Proje_Saatleri
   ============================================================ */

/* VERİ IMPORT İŞLEMİ */
proc import datafile="/home/u64407848/sasuser.v94/duzenli_data.xlsx"
    out=SAGLIK_DATA
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* VERİ DAĞILIMI KONTROLÜ */
proc freq data=SAGLIK_DATA;
    tables Saglik_Riski_Seviyesi;
run;

/* ÇOKLU BAĞLANTI KONTROLÜ */
proc corr data=SAGLIK_DATA spearman;
    var Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
run;

/* NORMALLİK TESTİ */
proc univariate data=SAGLIK_DATA normal;
    var Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    histogram / normal; /* Görsel kontrol için histogram */
run;

/* DİSKRİMİNANT ANALİZİ */
proc discrim data=SAGLIK_DATA 
    can         /* Kanonik korelasyonları verir */
    simple      /* Basit istatistikler */
    pool=test;  /* Varyans homojenliği testi (Box's M) */
    class Saglik_Riski_Seviyesi;
    var Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    priors proportional;
run;

/* ADIMSAL DİSKRİMİNANT ANALİZİ */
proc stepdisc method=stepwise data=SAGLIK_DATA;
    class Saglik_Riski_Seviyesi;
    var Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
run;

/* ============================================================
   NOTLAR:
   
   1. HEDEF DEĞİŞKEN: Saglik_Riski_Seviyesi (CLASS değişkeni)
   
   2. BAĞIMSIZ DEĞİŞKENLER:
      - Stress_Seviyesi_Biosensor
      - Stress_Seviyesi_Bildirim
      - Ders_Saatleri
      - Proje_Saatleri
   
   3. ÖNEMLI ÇIKTILAR:
      - Box's M Test: Kovaryans matrislerinin homojenliği
      - Wilks' Lambda: Grup ayrımının istatistiksel anlamlılığı
      - Canonical Correlation: Kanonik korelasyonlar
      - Classification Summary: Doğru sınıflandırma oranı
      - Error Rate: Hata oranı
   
   4. YORUMLAMA:
      - Düşük Wilks' Lambda → İyi grup ayrımı
      - Yüksek Canonical Correlation → Güçlü diskriminant fonksiyonu
      - Yüksek doğru sınıflandırma oranı → İyi model performansı
   ============================================================ */
