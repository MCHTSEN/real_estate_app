# 🏠 Emlak Uygulaması - Roadmap.md

## ✅ Başlangıç Aşaması
- [x] Paketler ekle (`flutter_riverpod`, `image_picker`,`firebase_core`, `firebase_auth`, `cloud_firestore`, vs.)
- [x] Firebase kurulumu (auth, firestore, storage)

---

## 👤 Authentication (Giriş / Kayıt)
- [x] Firebase Auth entegrasyonu
- [x] E-mail & Şifre ile giriş / kayıt ekranları
- [x] Form validasyonları (email, şifre)
- [x] Şifre göster/gizle özelliği
- [x] Giriş sonrası yönlendirme (GoRouter ile)

---

## 📸 İlan Yükleme Modülü
- [x] "İlan Yükle" ekranı tasarımı
- [x] Satılık / Kiralık seçimi
- [x] İlan görseli ekleme (galeri/kamera)
- [x] Oda sayısı, m², açıklama alanları
- [x] Lokasyon seçimi (şehir, ilçe, mahalle - dropdown)
- [x] Kullanıcıdan gelen bilgiler: isim, tel, uid ile eşle
- [x] Firestore'a ilan kaydetme
- [x] Firebase Storage'a fotoğraf yükleme
- [x] Başarılı gönderim sonrası snackbar ve yönlendirme

---

## 🏡 İlanları Listeleme
- [x] Ana sayfa: tüm ilanları listele (satılık + kiralık)
- [x] Satılık ilanlar sekmesi
- [x] Kiralık ilanlar sekmesi
- [x] Firestore'dan ilanları çekme (real-time stream veya pagination)
- [x] İlan kart tasarımı (resim, fiyat, m², lokasyon, kısa açıklama)

---

## 🔍 İlan Filtreleme
- [ ] Filtreleme butonu (FAB veya AppBar)
- [ ] Kriterler: satılık/kiralık, min/max fiyat, m², oda sayısı, şehir/ilçe
- [ ] Firestore query builder ile filtreli veri çekme
- [ ] Filtre temizleme butonu

---

## 🧑‍💼 Kullanıcı Profili
- [x] Profil ekranı (ad, e-posta, tel)
- [x] Kullanıcının eklediği ilanları listele
- [x] Çıkış yapma butonu

---

## 🧪 Test ve Stabilite
- [ ] Form validasyonları testleri
- [ ] Firestore veri akış kontrolü
- [ ] Navigasyon senaryoları testi
- [ ] Flutter doctor ve build kontrolleri

---

## 🚀 Yayınlama & Son İşlemler
- [ ] App Icon ve Splash Screen
- [ ] Debug loglarını temizleme
- [ ] Release build oluşturma
- [ ] Android ve iOS için test etme
- [ ] Cursorda proje açıklaması ve sunumu

---

## 📌 Ekstra (Opsiyonel Geliştirmeler)
- [ ] Harita üzerinden ilan konumu gösterme (Google Maps)
- [ ] Favorilere ekleme
- [ ] Chat özelliği (ilana mesaj atma)
- [ ] İlanlara yorum yapma