/*==============================================================================*/
/*                    KÜMELEME ANALİZİ - SAS KODLARI                           */
/*                    Öğrenci Stres Verileri Analizi                           */
/*==============================================================================*/

/*------------------------------------------------------------------------------*/
/*                        1. VERİ YÜKLEME VE HAZIRLAMA                         */
/*------------------------------------------------------------------------------*/

/* Excel dosyasını SAS'a aktarma */
PROC IMPORT DATAFILE="/home/u64407848/sasuser.v94/duzenli_data_300gozlem.xlsx"
    OUT=WORK.IMPORT
    DBMS=XLSX
    REPLACE;
    GETNAMES=YES;
RUN;

/* Veri setinin ilk satırları */
PROC PRINT DATA=WORK.IMPORT(OBS=10);
RUN;

/* Veri seti hakkında bilgi */
PROC CONTENTS DATA=WORK.IMPORT;
RUN;


/*------------------------------------------------------------------------------*/
/*                        2. ÖZET İSTATİSTİKLER                                */
/*------------------------------------------------------------------------------*/

/* Tanımlayıcı istatistikler */
PROC MEANS DATA=WORK.IMPORT N MEAN STD MIN MAX;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

/* Frekans tabloları (kategorik değişkenler için) */
PROC FREQ DATA=WORK.IMPORT;
    TABLES Cinsiyet Fiziksel_Aktivite Uyku_Kalitesi Ruh_Hali Saglik_Riski_Seviyesi;
RUN;


/*------------------------------------------------------------------------------*/
/*                        3. KORELASYON ANALİZİ                                */
/*------------------------------------------------------------------------------*/

/* Pearson korelasyon matrisi */
PROC CORR DATA=WORK.IMPORT PEARSON;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;


/*------------------------------------------------------------------------------*/
/*                    4. HİYERARŞİK KÜMELEME ANALİZİ                           */
/*------------------------------------------------------------------------------*/

/* 4.1. Ward Yöntemi ile Hiyerarşik Kümeleme */
PROC CLUSTER DATA=WORK.IMPORT 
             METHOD=WARD         /* Ward yöntemi */
             OUTTREE=WARD        /* Çıktı veri seti */
             SIMPLE              /* Basit istatistikleri verir */
             RMSSTD;             /* Root-mean-square std sapma */
    ID Ogrenci_ID;               /* Gözlem kimliği */
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

/* Dendrogramı çizdirme */
PROC TREE DATA=WARD NCLUSTERS=3;
    ID Ogrenci_ID;
RUN;


/* 4.2. Diğer Hiyerarşik Kümeleme Yöntemleri */

/* Average (Ortalama bağlantı) yöntemi */
PROC CLUSTER DATA=WORK.IMPORT METHOD=AVERAGE OUTTREE=AVG_TREE;
    ID Ogrenci_ID;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

/* Complete (Tam bağlantı) yöntemi */
PROC CLUSTER DATA=WORK.IMPORT METHOD=COMPLETE OUTTREE=COMP_TREE;
    ID Ogrenci_ID;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

/* Single (Tek bağlantı) yöntemi */
PROC CLUSTER DATA=WORK.IMPORT METHOD=SINGLE OUTTREE=SING_TREE;
    ID Ogrenci_ID;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

/* Centroid (Merkez nokta) yöntemi */
PROC CLUSTER DATA=WORK.IMPORT METHOD=CENTROID OUTTREE=CENT_TREE;
    ID Ogrenci_ID;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;


/*------------------------------------------------------------------------------*/
/*                    5. AYKIRI GÖZLEM ÇIKARMA                                 */
/*------------------------------------------------------------------------------*/

/* Örnek: 25. satırın veri setinden çıkarılması */
DATA IMPORT2; 
    SET WORK.IMPORT;
    IF _N_ = 25 THEN DELETE;  /* 25. satırı sil */
RUN;

/* Birden fazla aykırı gözlem çıkarmak için */
DATA IMPORT2; 
    SET WORK.IMPORT;
    IF _N_ IN (25, 150, 200) THEN DELETE;  /* Belirtilen satırları sil */
RUN;

/* Aykırı gözlem çıkarıldıktan sonra tekrar kümeleme */
PROC CLUSTER DATA=IMPORT2 METHOD=WARD OUTTREE=WARD2;
    ID Ogrenci_ID;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

PROC TREE DATA=WARD2 NCLUSTERS=3;
    ID Ogrenci_ID;
RUN;


/*------------------------------------------------------------------------------*/
/*                    6. K-MEANS KÜMELEME ANALİZİ                              */
/*------------------------------------------------------------------------------*/

/* K-Means kümeleme (k=3) */
PROC FASTCLUS DATA=WORK.IMPORT 
              MAXCLUSTERS=3      /* Küme sayısı (k) */
              MAXITER=100        /* Maksimum iterasyon sayısı */
              LIST               /* Gözlemlerin küme atamalarını listele */
              DISTANCE           /* Küme merkezleri arası uzaklıkları göster */
              OUT=CLUST;         /* Çıktı veri setinin adı */
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    ID Ogrenci_ID;
RUN;

/* 
PARAMETRELER:
- MAXCLUSTERS = Küme sayısı (k)
- MAXITER = Maksimum iterasyon sayısı (varsayılan: 10)
- LIST = Gözlemlerin hangi kümeye atandığını listeler
- DISTANCE = Küme merkezleri arasındaki uzaklığı gösterir
- OUT = Küme atamalarını ve uzaklıklarını kaydeder
*/


/*------------------------------------------------------------------------------*/
/*                    7. KÜMELEME SONUÇLARININ İNCELENMESİ                     */
/*------------------------------------------------------------------------------*/

/* Küme atamalarını ve uzaklıkları görüntüleme */
PROC PRINT DATA=CLUST(OBS=20);
    VAR Ogrenci_ID CLUSTER DISTANCE;
RUN;

/* Her kümedeki gözlem sayısı */
PROC FREQ DATA=CLUST;
    TABLES CLUSTER;
RUN;

/* Kümelere göre özet istatistikler */
PROC MEANS DATA=CLUST N MEAN STD MIN MAX;
    CLASS CLUSTER;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;


/*------------------------------------------------------------------------------*/
/*                    8. ANOVA / GLM ANALİZİ                                   */
/*------------------------------------------------------------------------------*/
/* Değişkenlerin kümelemede anlamlı olup olmadığını görmek için GLM kullanılır */

/* 1. Yaş için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Yas = CLUSTER;
    MEANS CLUSTER / TUKEY;  /* Tukey post-hoc testi */
RUN;
QUIT;

/* 2. Nabız için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Nabiz = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;

/* 3. Kan Basıncı Sistolik için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Kan_Basinci_Sistolik = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;

/* 4. Kan Basıncı Diyastolik için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Kan_Basinci_Diyastolik = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;

/* 5. Stres Seviyesi (Biosensor) için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Stress_Seviyesi_Biosensor = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;

/* 6. Stres Seviyesi (Bildirim) için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Stress_Seviyesi_Bildirim = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;

/* 7. Ders Saatleri için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Ders_Saatleri = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;

/* 8. Proje Saatleri için GLM */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Proje_Saatleri = CLUSTER;
    MEANS CLUSTER / TUKEY;
RUN;
QUIT;


/* Tüm değişkenler için tek seferde MANOVA */
PROC GLM DATA=CLUST;
    CLASS CLUSTER;
    MODEL Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
          Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
          Ders_Saatleri Proje_Saatleri = CLUSTER;
    MANOVA H=CLUSTER / PRINTE PRINTH;
RUN;
QUIT;


/*------------------------------------------------------------------------------*/
/*                    9. GÖRSELLEŞTİRMELER                                     */
/*------------------------------------------------------------------------------*/

/* 9.1. Boxplot Grafikleri */

/* Yaş - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Yas / CATEGORY=CLUSTER;
    TITLE "Yaş - Kümelere Göre Boxplot";
RUN;

/* Nabız - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Nabiz / CATEGORY=CLUSTER;
    TITLE "Nabız - Kümelere Göre Boxplot";
RUN;

/* Kan Basıncı Sistolik - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Kan_Basinci_Sistolik / CATEGORY=CLUSTER;
    TITLE "Kan Basıncı (Sistolik) - Kümelere Göre Boxplot";
RUN;

/* Kan Basıncı Diyastolik - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Kan_Basinci_Diyastolik / CATEGORY=CLUSTER;
    TITLE "Kan Basıncı (Diyastolik) - Kümelere Göre Boxplot";
RUN;

/* Stres Seviyesi (Biosensor) - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Stress_Seviyesi_Biosensor / CATEGORY=CLUSTER;
    TITLE "Stres Seviyesi (Biosensor) - Kümelere Göre Boxplot";
RUN;

/* Stres Seviyesi (Bildirim) - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Stress_Seviyesi_Bildirim / CATEGORY=CLUSTER;
    TITLE "Stres Seviyesi (Bildirim) - Kümelere Göre Boxplot";
RUN;

/* Ders Saatleri - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Ders_Saatleri / CATEGORY=CLUSTER;
    TITLE "Ders Saatleri - Kümelere Göre Boxplot";
RUN;

/* Proje Saatleri - Boxplot */
PROC SGPLOT DATA=CLUST;
    VBOX Proje_Saatleri / CATEGORY=CLUSTER;
    TITLE "Proje Saatleri - Kümelere Göre Boxplot";
RUN;


/* 9.2. Panel Grafik (Birden fazla boxplot yan yana) */
PROC SGPANEL DATA=CLUST;
    PANELBY CLUSTER / ROWS=1;
    VBOX Yas Nabiz Stress_Seviyesi_Biosensor;
    TITLE "Seçilmiş Değişkenler - Kümelere Göre";
RUN;


/* 9.3. Scatter Plot Matrix */
PROC SGSCATTER DATA=CLUST;
    MATRIX Yas Nabiz Stress_Seviyesi_Biosensor Ders_Saatleri 
           / GROUP=CLUSTER;
    TITLE "Değişkenler Arası İlişki - Scatter Plot Matrix";
RUN;


/* 9.4. Histogram (Kümelere göre) */
PROC SGPLOT DATA=CLUST;
    HISTOGRAM Yas / GROUP=CLUSTER TRANSPARENCY=0.5;
    DENSITY Yas / TYPE=KERNEL GROUP=CLUSTER;
    TITLE "Yaş Dağılımı - Kümelere Göre";
RUN;


/*------------------------------------------------------------------------------*/
/*                    10. SONUÇLARIN KAYDEDILMESI                              */
/*------------------------------------------------------------------------------*/

/* Kümeleme sonuçlarını CSV olarak kaydetme */
PROC EXPORT DATA=CLUST
    OUTFILE="kumeleme_sonuclari.csv"
    DBMS=CSV
    REPLACE;
RUN;

/* Küme ortalamalarını hesaplama ve kaydetme */
PROC MEANS DATA=CLUST NOPRINT;
    CLASS CLUSTER;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    OUTPUT OUT=kume_ortalamalar MEAN=;
RUN;

PROC EXPORT DATA=kume_ortalamalar
    OUTFILE="kume_ortalamalar.csv"
    DBMS=CSV
    REPLACE;
RUN;

/* Sonuçları kalıcı SAS veri seti olarak kaydetme */
LIBNAME mylib "C:/SAS_Veriler";  /* Kendi yolunuzu yazın */

DATA mylib.kumeleme_sonuc;
    SET CLUST;
RUN;


/*------------------------------------------------------------------------------*/
/*                    11. EK ANALIZLER                                         */
/*------------------------------------------------------------------------------*/

/* 11.1. Küme Profil Tablosu */
PROC TABULATE DATA=CLUST;
    CLASS CLUSTER;
    VAR Yas Nabiz Kan_Basinci_Sistolik Stress_Seviyesi_Biosensor Ders_Saatleri;
    TABLE CLUSTER,
          (Yas Nabiz Kan_Basinci_Sistolik Stress_Seviyesi_Biosensor Ders_Saatleri)
          * (N MEAN STD MIN MAX);
RUN;


/* 11.2. Çapraz Tablo (Küme ile diğer kategorik değişkenler) */
PROC FREQ DATA=CLUST;
    TABLES CLUSTER * Cinsiyet / CHISQ;
    TABLES CLUSTER * Saglik_Riski_Seviyesi / CHISQ;
RUN;


/* 11.3. Diskriminant Analizi (Kümelerin ne kadar iyi ayrıldığını kontrol eder) */
PROC DISCRIM DATA=CLUST POOL=YES CROSSVALIDATE;
    CLASS CLUSTER;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;


/*------------------------------------------------------------------------------*/
/*                    12. FARKLI KÜME SAYILARI İLE DENEME                     */
/*------------------------------------------------------------------------------*/

/* k=2 ile K-Means */
PROC FASTCLUS DATA=WORK.IMPORT MAXCLUSTERS=2 MAXITER=100 OUT=CLUST2;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    ID Ogrenci_ID;
RUN;

/* k=4 ile K-Means */
PROC FASTCLUS DATA=WORK.IMPORT MAXCLUSTERS=4 MAXITER=100 OUT=CLUST4;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    ID Ogrenci_ID;
RUN;

/* k=5 ile K-Means */
PROC FASTCLUS DATA=WORK.IMPORT MAXCLUSTERS=5 MAXITER=100 OUT=CLUST5;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    ID Ogrenci_ID;
RUN;


/*------------------------------------------------------------------------------*/
/*                    13. STANDARTLAŞTIRMA (İsteğe Bağlı)                     */
/*------------------------------------------------------------------------------*/

/* Değişkenleri standardize etmek için */
PROC STANDARD DATA=WORK.IMPORT MEAN=0 STD=1 OUT=IMPORT_STD;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
RUN;

/* Standartlaştırılmış veri ile K-Means */
PROC FASTCLUS DATA=IMPORT_STD MAXCLUSTERS=3 MAXITER=100 OUT=CLUST_STD;
    VAR Yas Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Stress_Seviyesi_Biosensor Stress_Seviyesi_Bildirim 
        Ders_Saatleri Proje_Saatleri;
    ID Ogrenci_ID;
RUN;


/*==============================================================================*/
/*                              NOTLAR                                          */
/*==============================================================================*/

/*
1. PROC CLUSTER YÖNTEMLER:
   - WARD (Ward'ın minimum varyans yöntemi) - En çok kullanılan
   - AVERAGE (Ortalama bağlantı)
   - COMPLETE (Tam bağlantı)
   - SINGLE (Tek bağlantı)
   - CENTROID (Merkez nokta yöntemi)

2. PROC FASTCLUS PARAMETRELERİ:
   - MAXCLUSTERS = Küme sayısı
   - MAXITER = Maksimum iterasyon
   - LIST = Detaylı liste çıktısı
   - DISTANCE = Uzaklık bilgisi
   - OUT = Çıktı veri seti
   - SEED = Başlangıç değerleri (özel başlangıç için)

3. POST-HOC TESTLERİ (PROC GLM):
   - TUKEY (Tukey HSD)
   - SCHEFFE (Scheffe testi)
   - DUNCAN (Duncan çoklu aralık testi)
   - SNK (Student-Newman-Keuls)
   - BON (Bonferroni)

4. ÖNERILER:
   - Farklı yöntemlerle sonuçları karşılaştırın
   - Aykırı değerleri kontrol edin
   - Değişkenleri standardize etmeyi düşünün (farklı ölçeklerdeyse)
   - Optimal küme sayısını dendrogram ve istatistiklerle belirleyin
   - GLM ile kümelerin anlamlılığını test edin

5. RAPORLAMA:
   - ODS kullanarak çıktıları PDF/RTF olarak kaydedin
   - Grafikleri yüksek çözünürlükte kaydedin
   - Küme profillerini tablolar halinde sunun
*/


/*==============================================================================*/
/*                              SON                                             */
/*==============================================================================*/
