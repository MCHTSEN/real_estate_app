# 🏠 Emlak Uygulaması - Roadmap.md

## ✅ Başlangıç Aşaması
- [ ] Paketler ekle (`flutter_riverpod`, `image_picker`,`firebase_core`, `firebase_auth`, `cloud_firestore`, vs.)
- [ ] Firebase kurulumu (auth, firestore, storage)

---

## 👤 Authentication (Giriş / Kayıt)
- [ ] Firebase Auth entegrasyonu
- [ ] E-mail & Şifre ile giriş / kayıt ekranları
- [ ] Form validasyonları (email, şifre)
- [ ] Şifre göster/gizle özelliği
- [ ] Giriş sonrası yönlendirme (GoRouter ile)

---

## 📸 İlan Yükleme Modülü
- [ ] "İlan Yükle" ekranı tasarımı
- [ ] Satılık / Kiralık seçimi
- [ ] İlan görseli ekleme (galeri/kamera)
- [ ] Oda sayısı, m², açıklama alanları
- [ ] Lokasyon seçimi (şehir, ilçe, mahalle - dropdown)
- [ ] Kullanıcıdan gelen bilgiler: isim, tel, uid ile eşle
- [ ] Firestore'a ilan kaydetme
- [ ] Firebase Storage'a fotoğraf yükleme
- [ ] Başarılı gönderim sonrası snackbar ve yönlendirme

---

## 🏡 İlanları Listeleme
- [ ] Ana sayfa: tüm ilanları listele (satılık + kiralık)
- [ ] Satılık ilanlar sekmesi
- [ ] Kiralık ilanlar sekmesi
- [ ] Firestore'dan ilanları çekme (real-time stream veya pagination)
- [ ] İlan kart tasarımı (resim, fiyat, m², lokasyon, kısa açıklama)

---

## 🔍 İlan Filtreleme
- [ ] Filtreleme butonu (FAB veya AppBar)
- [ ] Kriterler: satılık/kiralık, min/max fiyat, m², oda sayısı, şehir/ilçe
- [ ] Firestore query builder ile filtreli veri çekme
- [ ] Filtre temizleme butonu

---

## 🧑‍💼 Kullanıcı Profili
- [ ] Profil ekranı (ad, e-posta, tel)
- [ ] Kullanıcının eklediği ilanları listele
- [ ] Çıkış yapma butonu

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