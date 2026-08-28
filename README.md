# RateScout — приложение (Android · Windows · macOS)

Неофициальное кросс-платформенное приложение для [RateScout](https://ratescout.ru): профессиональный монитор курсов (страница /monitor/ сайта) в приложении. Один код на Flutter → 3 платформы.

Сайт-лендинг со ссылками на скачивание: **https://app.ratescout.ru**
Скачать: [Releases](https://github.com/sementsul/ratescout-app/releases).

## Как устроено
- `lib/main.dart` — Flutter-обёртка: `InAppWebView` открывает https://ratescout.ru/monitor/ (тот же сервис и дизайн, что на сайте).
- Платформенные папки (`android/ios/windows/macos`) НЕ хранятся в репо — их генерирует CI (`flutter create`).
- `.github/workflows/build.yml` — сборка APK / Windows-zip / macOS-zip на соответствующих раннерах; релиз по тегу `v*`.
- `.github/workflows/pages.yml` + `site/` — лендинг на GitHub Pages (домен app.ratescout.ru).

## Сборка (локально, нужен Flutter SDK)
    flutter create . --platforms=android,windows,macos --project-name ratescout_app --org ru.ratescout
    flutter pub get
    flutter build apk --release        # Android
    flutter build windows --release    # Windows
    flutter build macos --release      # macOS

## Заметки
- macOS/Android: CI добавляет сетевые разрешения (network.client / INTERNET) после `flutter create`.
- macOS-сборка не подписана (ПКМ → «Открыть»). Android APK подписан debug-ключом (ставится вне Play).

Лицензия: MIT. Данные: BestChange.
