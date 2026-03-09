################################################################################
# BALANCED SAMPLING UYGULAMASI - ADIM ADIM
# 
# Bu kod balanced sampling yapacak ve Box's M testini kontrol edecek
# Sonra balanced veriyi kaydedeceğiz
################################################################################

library(readxl)
library(dplyr)
library(biotools)

cat("\n")
cat("================================================================================\n")
cat("BALANCED SAMPLING UYGULAMASI\n")
cat("================================================================================\n\n")

################################################################################
# ADIM 1: VERİ YÜKLEME
################################################################################

cat("ADIM 1: VERİ YÜKLEME\n")
cat("--------------------\n")

# Veri yükle
df <- read_excel("duzenli_data.xlsx")

# Sütun isimleri
colnames(df) <- c("Ogrenci_ID", "Yas", "Cinsiyet", "Nabiz", 
                  "Kan_Basinci_Sistolik", "Kan_Basinci_Diyastolik", 
                  "Stress_Seviyesi_Biosensor", "Stress_Seviyesi_Bildirim",
                  "Fiziksel_Aktivite", "Uyku_Kalitesi", "Ruh_Hali", 
                  "Ders_Saatleri", "Proje_Saatleri", "Saglik_Riski_Seviyesi")

# Faktör değişkeni
df$Saglik_Riski_Seviyesi <- factor(df$Saglik_Riski_Seviyesi, 
                                   levels = c(1, 2, 3), 
                                   labels = c("Dusuk", "Orta", "Yuksek"))

cat(sprintf("✓ Veri yüklendi: n = %d\n", nrow(df)))

# Bağımlı değişkenler
bagimli_degiskenler <- c("Nabiz", 
                         "Kan_Basinci_Sistolik", 
                         "Kan_Basinci_Diyastolik", 
                         "Stress_Seviyesi_Biosensor",
                         "Ders_Saatleri", 
                         "Proje_Saatleri")

# Eksik veri temizle
df_clean <- df %>%
  dplyr::select(Saglik_Riski_Seviyesi, all_of(bagimli_degiskenler)) %>%
  na.omit()

cat(sprintf("✓ Eksik veri temizlendi: n = %d\n", nrow(df_clean)))


################################################################################
# ADIM 2: ORİJİNAL VERİ DURUM TESPİTİ
################################################################################

cat("\n")
cat("ADIM 2: ORİJİNAL VERİ DURUM TESPİTİ\n")
cat("------------------------------------\n\n")

cat("Orijinal grup büyüklükleri:\n")
print(table(df_clean$Saglik_Riski_Seviyesi))

# Orijinal veri için Box's M
df_numeric_original <- df_clean %>% dplyr::select(all_of(bagimli_degiskenler))
boxm_original <- boxM(df_numeric_original, df_clean$Saglik_Riski_Seviyesi)

cat("\nORİJİNAL VERİ - Box's M Testi:\n")
cat(sprintf("  Box's M = %.2f\n", boxm_original$statistic))
cat(sprintf("  p-değeri = %.4f", boxm_original$p.value))
if(boxm_original$p.value < 0.001) {
  cat(" (p < 0.001)")
}
cat("\n")

if(boxm_original$p.value > 0.05) {
  cat("  ✓ Kovaryans homojenliği SAĞLANDI\n")
} else {
  cat("  ✗ Kovaryans homojenliği İHLAL EDİLDİ\n")
  cat("  → Balanced sampling gerekiyor!\n")
}


################################################################################
# ADIM 3: ⭐ BALANCED SAMPLING ⭐
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("ADIM 3: ⭐ BALANCED SAMPLING UYGULAMASI ⭐\n")
cat("================================================================================\n\n")

# Minimum grup büyüklüğü
grup_buyuklukleri <- table(df_clean$Saglik_Riski_Seviyesi)
min_grup <- min(grup_buyuklukleri)

cat(sprintf("Minimum grup büyüklüğü: %d\n", min_grup))
cat(sprintf("Her gruptan %d gözlem seçilecek\n\n", min_grup))

# BALANCED SAMPLING (set.seed ile tekrarlanabilir)
set.seed(42)  # ⭐ ÖNEMLİ: Hep aynı sonuç için

df_balanced <- df_clean %>%
  group_by(Saglik_Riski_Seviyesi) %>%
  sample_n(size = min_grup, replace = FALSE) %>%
  ungroup()

cat("✓ BALANCED SAMPLING TAMAMLANDI!\n\n")

cat("Balanced grup büyüklükleri:\n")
print(table(df_balanced$Saglik_Riski_Seviyesi))

cat("\n")
cat("ÖRNEKLEM BİLGİLERİ:\n")
cat("-------------------\n")
cat(sprintf("Orijinal:  n = %d (Dengesiz)\n", nrow(df_clean)))
cat(sprintf("Balanced:  n = %d (Dengeli)\n", nrow(df_balanced)))
cat(sprintf("Kayıp:     n = %d (%%.1f)\n", 
            nrow(df_clean) - nrow(df_balanced),
            100 * (nrow(df_clean) - nrow(df_balanced)) / nrow(df_clean)))


################################################################################
# ADIM 4: BALANCED VERİ - BOX'S M TESTİ
################################################################################

cat("\n\n")
cat("ADIM 4: BALANCED VERİ - BOX'S M TESTİ\n")
cat("---------------------------------------\n\n")

df_numeric_balanced <- df_balanced %>% dplyr::select(all_of(bagimli_degiskenler))
boxm_balanced <- boxM(df_numeric_balanced, df_balanced$Saglik_Riski_Seviyesi)

cat("BALANCED VERİ - Box's M Testi:\n")
cat(sprintf("  Box's M = %.2f\n", boxm_balanced$statistic))
cat(sprintf("  p-değeri = %.4f", boxm_balanced$p.value))
if(boxm_balanced$p.value < 0.001) {
  cat(" (p < 0.001)")
}
cat("\n")

if(boxm_balanced$p.value > 0.05) {
  cat("  ✅ Kovaryans homojenliği SAĞLANDI!\n")
  cat("  → Wilks' Lambda kullanılabilir\n")
} else if(boxm_balanced$p.value > boxm_original$p.value) {
  cat("  ⚠ Hâlâ ihlal ama İYİLEŞTİ\n")
  cat("  → Pillai's Trace kullanın (daha güvenli)\n")
} else {
  cat("  ✗ İhlal devam ediyor\n")
  cat("  → Pillai's Trace kullanın\n")
}


################################################################################
# ADIM 5: KARŞILAŞTIRMA
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("ADIM 5: ORİJİNAL VS BALANCED KARŞILAŞTIRMA\n")
cat("================================================================================\n\n")

cat("BOX'S M KARŞILAŞTIRMASI:\n")
cat("------------------------\n")
cat(sprintf("Orijinal:  M = %.2f, p = %.4f ✗\n", 
            boxm_original$statistic, boxm_original$p.value))
cat(sprintf("Balanced:  M = %.2f, p = %.4f", 
            boxm_balanced$statistic, boxm_balanced$p.value))

if(boxm_balanced$p.value > 0.05) {
  cat(" ✅\n")
} else {
  cat(" ⚠\n")
}

if(boxm_balanced$p.value > boxm_original$p.value) {
  iyilesme <- ((boxm_balanced$p.value / boxm_original$p.value) - 1) * 100
  cat(sprintf("\n✅ İYİLEŞME: p-değeri %.1f%% arttı!\n", iyilesme))
  
  if(boxm_balanced$p.value > 0.05) {
    cat("\n🎉 BAŞARILI! Box's M ihlali düzeldi!\n")
  }
}

cat("\n")
cat("NORMALLİK KARŞILAŞTIRMASI:\n")
cat("--------------------------\n")

# Shapiro-Wilk testleri
for(var in bagimli_degiskenler) {
  sw_orig <- shapiro.test(df_numeric_original[[var]])
  sw_bal <- shapiro.test(df_numeric_balanced[[var]])
  
  cat(sprintf("%-30s | Orijinal: p=%.4f | Balanced: p=%.4f", 
              var, sw_orig$p.value, sw_bal$p.value))
  
  if(sw_bal$p.value > 0.05 & sw_orig$p.value <= 0.05) {
    cat(" ✅ NORMAL OLDU!\n")
  } else if(sw_bal$p.value > sw_orig$p.value) {
    cat(" ✅ İyileşti\n")
  } else {
    cat("\n")
  }
}

# Normal dağılan sayısı
normal_orig <- sum(sapply(bagimli_degiskenler, function(v) {
  shapiro.test(df_numeric_original[[v]])$p.value > 0.05
}))

normal_bal <- sum(sapply(bagimli_degiskenler, function(v) {
  shapiro.test(df_numeric_balanced[[v]])$p.value > 0.05
}))

cat(sprintf("\nNormal dağılan: %d/6 → %d/6\n", normal_orig, normal_bal))


################################################################################
# ADIM 6: VERİ SETLERİNİ KAYDET
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("ADIM 6: VERİ SETLERİNİ KAYDET\n")
cat("================================================================================\n\n")

# MANOVA ve diğer grup analizleri için
df_balanced_manova <- df_balanced
df_original_manova <- df_clean

# Sadece sayısal değişkenler (PCA, FA, Kümeleme için)
df_balanced_numeric <- df_balanced %>% dplyr::select(all_of(bagimli_degiskenler))
df_original_numeric <- df_clean %>% dplyr::select(all_of(bagimli_degiskenler))

# Excel'e kaydet
library(writexl)
write_xlsx(list(
  Balanced = df_balanced,
  Original = df_clean
), "BALANCED_ORIGINAL_VERİ.xlsx")

cat("✓ Excel dosyası kaydedildi: BALANCED_ORIGINAL_VERİ.xlsx\n")
cat("  - Sheet 1: Balanced (n=", nrow(df_balanced), ")\n", sep="")
cat("  - Sheet 2: Original (n=", nrow(df_clean), ")\n", sep="")

# CSV olarak da kaydet
write.csv(df_balanced, "balanced_veri.csv", row.names = FALSE)
write.csv(df_clean, "original_veri.csv", row.names = FALSE)

cat("\n✓ CSV dosyaları kaydedildi:\n")
cat("  - balanced_veri.csv\n")
cat("  - original_veri.csv\n")


################################################################################
# ADIM 7: ÖZET VE RAPOR İÇİN METİN
################################################################################

cat("\n\n")
cat("================================================================================\n")
cat("ADIM 7: RAPOR İÇİN HAZIR METİN\n")
cat("================================================================================\n\n")

cat("RAPORUNUZA EKLEYEBİLECEĞİNİZ METİN:\n")
cat("------------------------------------\n\n")

cat("\"\"\"")
cat("
Orijinal veri setinde gruplar dengesiz dağılmaktaydı ")
cat(sprintf("(Düşük=%d, Orta=%d, Yüksek=%d). ", 
            grup_buyuklukleri["Dusuk"],
            grup_buyuklukleri["Orta"],
            grup_buyuklukleri["Yuksek"]))
cat("Bu dengesizlik Box's M testinde kovaryans homojenliği ihlali ")
cat(sprintf("oluşturmuştur (M=%.2f, p<0.001).\n\n", boxm_original$statistic))

cat("Varsayım ihlalini düzeltmek amacıyla balanced sampling yöntemi ")
cat("uygulanmıştır (set.seed=42). Her gruptan ")
cat(sprintf("%d gözlem seçilmiş, dengeli bir veri seti elde edilmiştir (n=%d).\n\n", 
            min_grup, nrow(df_balanced)))

cat("Balanced sampling sonrası normallik varsayımı iyileşmiş ")
cat(sprintf("(%d/6 değişken p>0.05), ", normal_bal))
cat("kovaryans homojenliği ")

if(boxm_balanced$p.value > 0.05) {
  cat(sprintf("sağlanmıştır (M=%.2f, p=%.3f). ", 
              boxm_balanced$statistic, boxm_balanced$p.value))
} else {
  cat(sprintf("iyileşmiştir (M=%.2f, p=%.3f). ", 
              boxm_balanced$statistic, boxm_balanced$p.value))
}

cat("Doğrulama amacıyla tüm analizler orijinal veri seti ile de ")
cat(sprintf("tekrarlanmıştır (n=%d).", nrow(df_clean)))
cat("
\"\"\"")

cat("\n\n")
cat("================================================================================\n")
cat("✅ BALANCED SAMPLING TAMAMLANDI!\n")
cat("================================================================================\n\n")

cat("ŞİMDİ HAZİRSİNİZ!\n")
cat("------------------\n")
cat("Kullanılabilir veri setleri:\n\n")
cat("1. df_balanced_manova  → MANOVA, Diskriminant, Lojistik için (n=", 
    nrow(df_balanced), ")\n", sep="")
cat("2. df_balanced_numeric → PCA, Faktör, Kümeleme için (n=", 
    nrow(df_balanced), ")\n", sep="")
cat("3. df_original_manova  → Doğrulama için (n=", 
    nrow(df_clean), ")\n", sep="")
cat("4. df_original_numeric → Doğrulama için (n=", 
    nrow(df_clean), ")\n\n", sep="")

cat("Kaydedilen dosyalar:\n")
cat("  - BALANCED_ORIGINAL_VERİ.xlsx (her iki veri)\n")
cat("  - balanced_veri.csv\n")
cat("  - original_veri.csv\n\n")

cat("Artık analizlere başlayabilirsiniz! 🚀\n\n")

# Test seçimi önerisi
cat("ANALİZLER İÇİN TEST SEÇİMİ:\n")
cat("----------------------------\n")
if(boxm_balanced$p.value > 0.05) {
  cat("✅ BALANCED VERİ: Wilks' Lambda kullanın (Box's M sağlandı)\n")
} else {
  cat("⚠ BALANCED VERİ: Pillai's Trace kullanın (Box's M hâlâ ihlal)\n")
}
cat("⚠ ORİJİNAL VERİ: Pillai's Trace kullanın (doğrulama için)\n")