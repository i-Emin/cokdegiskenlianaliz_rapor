# Öğrenci Sağlık Verileri Çok Değişkenli İstatistiksel Analizi 📊

Bu depo, öğrenci sağlık verileri üzerine gerçekleştirilen kapsamlı bir çok değişkenli istatistiksel analiz projesini içermektedir. Proje kapsamında **5 farklı istatistiksel analiz** yöntemi uygulanmış ve tüm bu süreçler endüstri standardı olan **R, SPSS ve SAS** yazılımları/dilleri ile paralel olarak yürütülmüştür. 

Sürecin tamamını, istatistiksel varsayımların kontrolünü ve bulguların akademik bir dille yorumlanmasını içeren **97 sayfalık kapsamlı analiz raporu** da projeye dahildir.

## 🗂️ Gerçekleştirilen Analizler

Veri seti üzerinde uygulanan temel çok değişkenli istatistiksel yöntemler şunlardır:

0. **Keşifsel Veri Analizi ve Ön İşleme:** Verilerin analize hazır hale getirilmesi, kayıp veri ve uç değer kontrolleri.
1. **Temel Bileşenler Analizi (TBA) ve Faktör Analizi:** Boyut indirgeme ve gizli yapıların ortaya çıkarılması.
2. **MANOVA (Çok Değişkenli Varyans Analizi):** Bağımsız değişkenlerin birden fazla bağımlı değişken üzerindeki ortak etkisinin incelenmesi.
3. **Diskriminant Analizi:** Gruplar arası ayrımı en üst düzeye çıkaran fonksiyonların elde edilmesi ve sınıflandırma.
4. **Lojistik Regresyon:** Kategorik bağımlı değişkenin olasılık temelli modellenmesi.
5. **Kümeleme Analizi:** Gözlemlerin benzerliklerine göre doğal gruplara (kümelere) ayrılması.



## 🛠️ Kullanılan Teknolojiler ve Araçlar
Aynı analizler, sonuçların tutarlılığını test etmek ve farklı yazılımlardaki yetkinliği göstermek amacıyla üç farklı ortamda kodlanmıştır:
* **R:** Veri manipülasyonu, gelişmiş görselleştirme (`ggplot2` vb.) ve istatistiksel modelleme.
* **SPSS:** Çok değişkenli analizlerin arayüz tabanlı ve *Syntax* yapısıyla uygulanması.
* **SAS:** Gelişmiş veri analitiği, sağlamlık (robustness) kontrolleri ve modelleme.

## 📂 Depo Yapısı ve Gezinme

Her bir analizin klasörü içerisinde o yönteme ait R kodları, SAS script'leri ve SPSS syntax/çıktı dosyaları düzenli bir şekilde kategorize edilmiştir.

> 📦 CDA_Ogrenci_Saglik_Analizi
> ┣ 📜 README.md
> ┣ 📕 CDA_Ogrenci_Saglik_Rapor.pdf   # 97 Sayfalık Ana Proje Raporu (PDF)
> ┣ 📂 Veri_Analizi                   # Ham ve düzenlenmiş veri setleri
> ┣ 📂 TBA_ve_Faktor_Analizi          # Boyut indirgeme kod ve çıktıları
> ┣ 📂 Manova                         # Varyans analizi testleri
> ┣ 📂 Diskriminant_Analizi           # Sınıflandırma modelleme dosyaları (R, SAS, SPSS)
> ┣ 📂 Logistik_Regresyon             # Regresyon kodları
> ┗ 📂 Kumeleme                       # Kümeleme analizi dosyaları

## 📌 Proje Çıktıları ve Rapor
Projenin merkezini oluşturan `CDA_Ogrenci_Saglik_Rapor.pdf` dosyası; verilerin istatistiksel varsayımları (normallik, çoklu doğrusal bağlantı, varyansların homojenliği vb.) ne ölçüde karşıladığından başlayarak, elde edilen matematiksel modellerin yorumlanmasına kadar tüm analiz sürecini adım adım belgelemektedir. Projenin sonuçlarını detaylı incelemek için öncelikle bu PDF raporuna göz atılması tavsiye edilir.

---
**👨‍💻 Geliştirici:** İbrahim Emin İpek
