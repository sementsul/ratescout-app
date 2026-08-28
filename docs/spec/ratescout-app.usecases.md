# RateScout App — юзер-кейсы (живой список)

Статусы: ✅ проверено · 🟡 собрано/задеплоено, ждёт ручной приёмки · 🔴 нужна проверка на устройстве · ❌ не работает.

Архитектура (v1.1): приложение = **WebView страницы `/monitor/`** — тот же сервис и дизайн, что на сайте
(«работать как сервис /monitor/» + «дизайн как у сайта» выполняются буквально). Лендинг — в стиле сайта (его же styles.css).

## UC-1. Профессиональный монитор в приложении — 🔴
**Предусловие:** есть интернет; приложение запущено (Android/Windows/macOS).
**Шаги/ожидаемо:** при старте `InAppWebView` грузит `https://ratescout.ru/monitor/` → доступен полный функционал
монитора (все валюты на одной шкале, база, линии/свечи, выбор валют, %/лог/корреляции/экспорт — как на сайте).
Пока грузится — тонкий прогресс-бар в DOS-палитре (#111/#55ffff).
**РАДИУС:** `lib/main.dart` (InAppWebView), `pubspec.yaml` (flutter_inappwebview). СОСЕДИ: UC-2 (навигация), UC-4 (сборка).
**Статус:** 🔴 webview на десктопе (Windows/WebView2, macOS/WKWebView) не проверен на устройстве — обязательная приёмка.

## UC-2. Навигация: назад / обновить / открыть в браузере — 🔴
**Шаги/ожидаемо:** аппаратная «Назад» (Android) → `goBack()` по истории webview, иначе выход (`PopScope`);
кнопка ⟳ — `reload()`; кнопка 🌐 — открыть `/monitor/` во внешнем браузере (`url_launcher`).
**РАДИУС:** `_MonitorPageState` (PopScope/reload/_openInBrowser). РОЛИ: пользователь.

## UC-3. Дизайн как у сайта — 🟡
**Ожидаемо:** контент внутри webview = сам сайт (1-в-1). Обвязка приложения (AppBar/фон) — DOS-палитра сайта
(#111, cyan #55ffff). Лендинг `site/index.html` подключает `ratescout.ru/assets/styles.css` и повторяет шапку/topnav/.dosborder.
**РАДИУС:** `lib/main.dart` (тема), `site/index.html`.

## UC-4. Сборка 3 платформ в CI — 🟡
**Ожидаемо:** раннеры `flutter create . --platforms=<os>`, патч Android INTERNET + macOS `network.client`,
`flutter build` → apk / windows-zip / macos-zip; тег `v*` → релиз. flutter_inappwebview: Android (WebView),
Windows (WebView2), macOS (WKWebView).
**РАДИУС:** `.github/workflows/build.yml`. **Статус:** 🟡 в доводке под webview: Android — Flutter 3.24.5 (фикс
proguard/AGP у flutter_inappwebview); Windows — latest stable (VS2022); macOS — Podfile deployment target 11.0.
Грабли CI собраны в `docs/project-notes.md`. Гоняю до зелёного по всем 3 ОС.

## UC-5. Лендинг на app.ratescout.ru — 🟡
**Предусловие:** DNS `app` → `sementsul.github.io` (владелец).
**Ожидаемо:** `pages.yml` деплоит `site/` (стиль сайта) в Pages; `site/CNAME`=app.ratescout.ru; кнопки «Скачать»
→ `releases/latest/download/...`. **Статус:** 🟡 Pages деплоится; ждёт DNS.

## UC-6. Защита репозитория — ✅
**Ожидаемо:** `main` защищена: force-push/удаление запрещены, `enforce_admins: true`. **Статус:** ✅ применено (API).

## UC-7. Ссылка из основного сайта — 🟡
**Ожидаемо:** в `sementsul/ratescout` `build.py` — пункт «📱 Приложение» → app.ratescout.ru в обоих sblock левого меню.
**Статус:** 🟡 закоммичено, применится после пересборки сайта. См. [[ratescout-nav-left-only]].
