/* Excel dosyasını SAS'a aktarma */
proc import datafile="/home/u64407848/sasuser.v94/duzenli_data.xlsx"
    out=OGRENCI_DATA
    dbms=xlsx
    replace;
    getnames=yes;
run;

/* Betimsel istatistikler */
proc means data=OGRENCI_DATA n mean std min max;
    var Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Ders_Saatleri Proje_Saatleri;
run;

/* Bağımsız değişkenlerin frekans tabloları */
proc freq data=OGRENCI_DATA;
    tables Uyku_Kalitesi Ruh_Hali;
run;

/* Var-Cov matrisi homojenliği testi (Box's M Test) */
proc discrim data=OGRENCI_DATA pool=test;
    var Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Ders_Saatleri Proje_Saatleri;
    class Uyku_Kalitesi;
run;

/* Tek yönlü MANOVA - Uyku_Kalitesi */
proc glm data=OGRENCI_DATA;
    class Uyku_Kalitesi;
    model Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
          Ders_Saatleri Proje_Saatleri = Uyku_Kalitesi / SS3;
    manova h=Uyku_Kalitesi / printe printh;
    means Uyku_Kalitesi / tukey hovtest=levene;
run;

/* Çift yönlü MANOVA - Uyku_Kalitesi ve Ruh_Hali (Etkileşimli) */
proc glm data=OGRENCI_DATA;
    class Uyku_Kalitesi Ruh_Hali;
    model Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
          Ders_Saatleri Proje_Saatleri = Uyku_Kalitesi Ruh_Hali Uyku_Kalitesi*Ruh_Hali / SS3;
    manova h=Uyku_Kalitesi Ruh_Hali Uyku_Kalitesi*Ruh_Hali / printe printh;
    means Uyku_Kalitesi Ruh_Hali / tukey;
    lsmeans Uyku_Kalitesi*Ruh_Hali / adjust=tukey pdiff;
run;

/* Ek: Etki büyüklüğü (Partial Eta Squared) için */
proc glm data=OGRENCI_DATA;
    class Uyku_Kalitesi Ruh_Hali;
    model Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
          Ders_Saatleri Proje_Saatleri = Uyku_Kalitesi Ruh_Hali Uyku_Kalitesi*Ruh_Hali / SS3;
    manova h=Uyku_Kalitesi Ruh_Hali Uyku_Kalitesi*Ruh_Hali;
    ods output MANOVAStatistics=manova_stats;
run;

/* Etkileşim grafiklerini oluşturmak için ortalamalar */
proc means data=OGRENCI_DATA noprint;
    class Uyku_Kalitesi Ruh_Hali;
    var Nabiz Kan_Basinci_Sistolik Kan_Basinci_Diyastolik 
        Ders_Saatleri Proje_Saatleri;
    output out=ortalamalar mean=;
run;

/* Etkileşim grafiği */
proc sgplot data=ortalamalar;
    series x=Uyku_Kalitesi y=Nabiz / group=Ruh_Hali markers;
    title "Uyku Kalitesi ve Ruh Hali Etkileşimi - Nabız";
    xaxis label="Uyku Kalitesi";
    yaxis label="Ortalama Nabız";
run;

proc sgplot data=ortalamalar;
    series x=Uyku_Kalitesi y=Kan_Basinci_Sistolik / group=Ruh_Hali markers;
    title "Uyku Kalitesi ve Ruh Hali Etkileşimi - Sistolik Kan Basıncı";
    xaxis label="Uyku Kalitesi";
    yaxis label="Ortalama Sistolik KB";
run;

proc sgplot data=ortalamalar;
    series x=Uyku_Kalitesi y=Kan_Basinci_Diyastolik / group=Ruh_Hali markers;
    title "Uyku Kalitesi ve Ruh Hali Etkileşimi - Diyastolik Kan Basıncı";
    xaxis label="Uyku Kalitesi";
    yaxis label="Ortalama Diyastolik KB";
run;

proc sgplot data=ortalamalar;
    series x=Uyku_Kalitesi y=Ders_Saatleri / group=Ruh_Hali markers;
    title "Uyku Kalitesi ve Ruh Hali Etkileşimi - Ders Saatleri";
    xaxis label="Uyku Kalitesi";
    yaxis label="Ortalama Ders Saatleri";
run;

proc sgplot data=ortalamalar;
    series x=Uyku_Kalitesi y=Proje_Saatleri / group=Ruh_Hali markers;
    title "Uyku Kalitesi ve Ruh Hali Etkileşimi - Proje Saatleri";
    xaxis label="Uyku Kalitesi";
    yaxis label="Ortalama Proje Saatleri";
run;