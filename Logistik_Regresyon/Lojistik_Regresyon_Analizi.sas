/*******************************************************************************/
/*                     LOJİSTİK REGRESYON ANALİZİ - SAS                       */
/*                      Öğrenci Cinsiyet Tahmini                              */
/*                                                                             */
/*                    Yazar: İbrahim Emin İpek                                */
/*                    Tarih: Aralık 2025                                      */
/*******************************************************************************/

/* Veri setini içe aktar (Excel'den) */
proc import datafile="duzenli_data.xlsx"
    out=ogrenci_data
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* Veri yapısını kontrol et */
proc contents data=ogrenci_data;
run;

proc print data=ogrenci_data(obs=10);
run;

/*******************************************************************************/
/*                  MODEL 1: ÖNERİLEN 6 DEĞİŞKENLİ MODEL                      */
/*******************************************************************************/

/* Binary Lojistik Regresyon - Model 1 */
proc logistic data=ogrenci_data;
    model Cinsiyet(ref="0") = Yas Nabiz Stress_Seviyesi_Biosensor 
                              Fiziksel_Aktivite Ruh_Hali Proje_Saatleri 
                              / expb lackfit rsquare;
    output out=outdata1 predprobs=(individual);
run;

/* Sınıflandırma Tablosu - Model 1 */
proc freq data=outdata1;
    tables _FROM_*_INTO_;
    title "Model 1: Sınıflandırma Tablosu (6 Değişken)";
run;

/*******************************************************************************/
/*                  STEPWISE DEĞİŞKEN SEÇİMİ                                  */
/*******************************************************************************/

/* Stepwise Lojistik Regresyon - Backward Elimination */
proc logistic data=ogrenci_data;
    model Cinsiyet(ref="0") = Yas Nabiz Kan_Basinci_Sistolik 
                              Kan_Basinci_Diyastolik Stress_Seviyesi_Biosensor 
                              Stress_Seviyesi_Bildirim Fiziksel_Aktivite 
                              Uyku_Kalitesi Ruh_Hali Ders_Saatleri 
                              Proje_Saatleri Saglik_Riski_Seviyesi 
                              / expb lackfit rsquare selection=backward;
    output out=outdata_stepwise predprobs=(individual);
run;

/* Sınıflandırma Tablosu - Stepwise Model */
proc freq data=outdata_stepwise;
    tables _FROM_*_INTO_;
    title "Stepwise Model: Sınıflandırma Tablosu";
run;

/*******************************************************************************/
/*                              PROGRAM SONU                                   */
/*******************************************************************************/
