# RateScout App — заметки проекта (MAP)

Карта репо приложения-компаньона к RateScout. Спека — `docs/spec/ratescout-app.usecases.md`, история — git.

## Что это (v1.1)
Приложение = **WebView страницы `https://ratescout.ru/monitor/`** (тот же сервис «проф-монитор» и дизайн, что на сайте).
Один код на Flutter → Android / Windows / macOS. Лендинг со ссылками — на **app.ratescout.ru** (в стиле сайта).
Репо: github.com/sementsul/ratescout-app (main защищён). Пуш — разовым PAT юзера (маскировать, не хранить).

## Где что
```
lib/main.dart          Flutter-обёртка: InAppWebView -> /monitor/, DOS-тема, back/reload/open-in-browser
pubspec.yaml           flutter_inappwebview + url_launcher
site/index.html        лендинг (подключает ratescout.ru/assets/styles.css, шапка/topnav/.dosborder сайта)
site/CNAME             app.ratescout.ru
.github/workflows/
  build.yml            сборка apk/windows-zip/macos-zip (flutter create в раннере) + релиз по тегу
  pages.yml            деплой site/ на GitHub Pages (домен app.ratescout.ru)
```
Платформенные папки (android/windows/macos) НЕ в репо — генерит CI (`flutter create --platforms`).

## 🧭 Решения / 🔴 грабли CI (важно — витрина ловушек webview на десктопе)
- **Стек:** приложение — webview живого /monitor/ (десктопный webview Flutter слаб, но flutter_inappwebview держит все 3).
- **Android:** flutter_inappwebview_android тянет старый `getDefaultProguardFile('proguard-android.txt')`, который
  новый AGP запрещает → **пин Flutter 3.24.5** (AGP 8.1) в android-джобе. Патч INTERNET-permission после `flutter create`.
- **Windows:** пин 3.24.5 ломал сборку («ищет Visual Studio 2019») → windows-джоба на **latest stable** (видит VS2022).
- **macOS:** flutter_inappwebview_macos требует deployment target ≥10.14 → патчим `macos/Podfile` до **11.0**;
  + network.client entitlement (иначе HTTP в sandbox не работает). ⚠️ грабли: шаг-патч падал на `mv` из-за приоритета `||/&&` — упрощён.
- **Windows:** новый MSVC на раннере даёт hard-error **STL1011** на `<experimental/coroutine>` в flutter_inappwebview_windows →
  в CI патчим `windows/CMakeLists.txt`: `add_compile_definitions(_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS)` после `project()`
  (пишем через `[IO.File]::WriteAllText`, идемпотентно; `Set-Content -NoNewline` падал в pwsh).
- Общий урок: разным платформам — разные версии Flutter; правки workflow проверять по jobs>0 и логам.
- CI: `paths-ignore: docs/**, site/**, **.md` — доки/лендинг не пересобирают приложение.

## Состояние
- ✅ Репо + защита main; лендинг app.ratescout.ru (Pages) — ждёт DNS `app`→sementsul.github.io.
- ✅ Ссылка на приложение в основном сайте (build.py, оба sblock).
- ✅ Релиз v1.0.0 (старая версия: список+конвертер).
- ⏳ v1.1 (webview монитора): гоняю CI до зелёного по всем 3 ОС; затем тег v1.1.x → релиз.
- 🔴 На человека: DNS-запись; проверка десктопного webview на реальной машине; отзыв засвеченного PAT.

## Обновления
- Добавлены: фирменная **404** (`site/404.html`) и аналитика на лендинг+404 — **Я.Метрика 111586112** + **GA G-PPN27D6JXS** (те же счётчики, что на ratescout.ru; единый кабинет).
