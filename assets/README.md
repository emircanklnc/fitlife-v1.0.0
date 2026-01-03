# Assets Klasörü

Bu klasöre icon dosyanızı ekleyin:

## Gereksinimler

1. **app_icon.png** (1024x1024 px)
   - Ana icon dosyası
   - PNG formatında
   - Şeffaf arka plan önerilir
   - Yüksek kaliteli olmalı

## Kullanım

1. Icon dosyanızı `app_icon.png` olarak bu klasöre kaydedin
2. Terminal'de şu komutları çalıştırın:
   ```bash
   flutter pub get
   flutter pub run flutter_launcher_icons
   flutter pub run flutter_native_splash:create
   ```
3. Uygulamayı yeniden build edin:
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Notlar

- Icon dosyası 1024x1024 px olmalı
- PNG formatında olmalı
- Şeffaf arka plan önerilir (ama zorunlu değil)

