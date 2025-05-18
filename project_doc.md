# Real Estate App Dokümantasyonu

## İçindekiler
1. [Proje Genel Bakış](#proje-genel-bakış)
2. [Teknoloji Yığını](#teknoloji-yığını)
3. [Proje Yapısı](#proje-yapısı)
4. [Temel Özellikler](#temel-özellikler)
5. [Kurulum](#kurulum)
6. [Firebase Yapılandırması](#firebase-yapılandırması)

## Proje Genel Bakış
Real Estate App, modern emlak alım-satım ve kiralama işlemlerini kolaylaştırmak için geliştirilmiş bir mobil uygulamadır. Uygulama, Flutter framework'ü kullanılarak geliştirilmiş olup, iOS ve Android platformlarında çalışabilmektedir.

## Teknoloji Yığını
- **Flutter SDK**: >=3.27.2
- **Durum Yönetimi**: flutter_riverpod (^2.4.9)
- **Backend Servisleri**: Firebase
  - Firebase Authentication
  - Cloud Firestore
  - Firebase Storage
- **Routing**: go_router (^13.0.1)
- **Görüntü İşleme**: 
  - image_picker (^1.0.7)
  - cached_network_image (^3.3.1)
- **UI Bileşenleri**:
  - flutter_carousel_widget (^2.2.0)
  - smooth_page_indicator (^1.1.0)
- **Diğer Araçlar**:
  - intl (^0.20.2)
  - url_launcher (^6.2.4)

## Proje Yapısı
Proje, temiz mimari prensiplerine uygun olarak yapılandırılmıştır:

```
lib/
├── core/           # Temel utility sınıfları ve sabitler
├── features/       # Özellik bazlı modüller
├── router/         # Uygulama routing yapılandırması
├── main.dart       # Uygulama giriş noktası
└── firebase_options.dart  # Firebase yapılandırması
```

## Temel Özellikler
1. **Kullanıcı Yönetimi**
   - Kayıt olma
   - Giriş yapma
   - Profil yönetimi

2. **Emlak İşlemleri**
   - İlan oluşturma
   - İlan arama
   - İlan detaylarını görüntüleme
   - Favorilere ekleme

3. **Medya Yönetimi**
   - Fotoğraf yükleme
   - Fotoğraf önbelleğe alma
   - Carousel görüntüleyici

4. **İletişim Özellikleri**
   - İlan sahibi ile iletişim
   - URL açma
   - Telefon araması yapma

## Kurulum
1. Flutter SDK'yı yükleyin
2. Projeyi klonlayın
3. Bağımlılıkları yükleyin:
   ```bash
   flutter pub get
   ```
4. Firebase yapılandırmasını ayarlayın
5. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```

## Firebase Yapılandırması
Uygulama Firebase hizmetlerini kullanmaktadır. Kurulum için:

1. Firebase Console'dan yeni bir proje oluşturun
2. iOS ve Android platformları için yapılandırma dosyalarını ekleyin
3. Firebase Authentication'ı etkinleştirin
4. Cloud Firestore veritabanını oluşturun
5. Storage servisini etkinleştirin

### Firestore Koleksiyon Yapısı
- **users**: Kullanıcı profilleri
- **listings**: Emlak ilanları
- **favorites**: Favori ilanlar

### Storage Yapısı
- **/listings**: İlan fotoğrafları
- **/profiles**: Profil fotoğrafları

## Güvenlik ve İzinler
- Uygulama, gerekli izinleri kullanıcıdan talep eder (kamera, galeri, konum vb.)
- Firebase güvenlik kuralları ile veri erişimi kontrol edilir
- Kullanıcı kimlik doğrulaması Firebase Authentication ile sağlanır

## Performans Optimizasyonu
- Görüntüler için önbellek kullanımı
- Lazy loading implementasyonu
- Firebase sorgu optimizasyonu

## Hata Yönetimi
- Firebase işlemleri için hata yakalama
- Kullanıcı dostu hata mesajları
- Ağ bağlantısı kontrolü

## Geliştirici Notları
- Yeni özellik eklerken features/ dizini altında yeni bir modül oluşturun
- Temiz kod prensiplerine uyun
- Değişikliklerden önce testleri çalıştırın
- Firebase güvenlik kurallarını güncellerken dikkatli olun

## Versiyonlama
Proje semantic versiyonlama kullanmaktadır:
- Mevcut Versiyon: 1.0.0+1 