# RateScout App — юзер-кейсы (живой список)

Статусы: ✅ проверено · 🟡 собрано/задеплоено, ждёт ручной приёмки · 🔴 нужна проверка на устройстве · ❌ не работает.

## UC-1. Просмотр курсов валют — 🟡
**Предусловие:** есть интернет, приложение запущено (Android/Windows/macOS).
**Шаги/ожидаемо:** при старте `loadData()` тянет `currencies.json`+`history.json` (raw GitHub), объединяет →
список валют (тикер·имя, категория, текущий курс в USDT — последняя точка истории). Показываются только валюты
с актуальным курсом. Внизу — «Обновлено … UTC · данные BestChange».
**РАДИУС:** `lib/data.dart` (loadData/парсинг), `lib/main.dart` (список). СОСЕДИ: UC-4 (сеть).

## UC-2. Конвертер — 🟡
**Предусловие:** данные загружены.
**Шаги/ожидаемо:** ввод суммы + выбор «из»/«в» (dropdown) → результат `сумма × from.usdt / to.usdt` (кросс через USDT),
пересчёт вживую. По умолчанию первые две валюты.
**РАДИУС:** `_converter` в `lib/main.dart`. РОЛИ: пользователь.

## UC-3. Открыть сайт / поиск — 🟡
**Шаги/ожидаемо:** кнопка 🌐 в AppBar → `url_launcher` открывает ratescout.ru во внешнем браузере; поле поиска
фильтрует список по имени/тикеру; кнопка ⟳ перезагружает данные.
**РАДИУС:** `_openSite`, поиск, `_reload` в `lib/main.dart`, `url_launcher`.

## UC-4. Нет сети / ошибка загрузки — 🟡
**Шаги/ожидаемо:** при ошибке fetch — экран с иконкой, текстом ошибки и кнопкой «Повторить» (не краш).
**РАДИУС:** `_ErrorView` + FutureBuilder error-ветка.

## UC-5. Сборка 3 платформ в CI — ✅
**Ожидаемо:** на push/тег раннеры делают `flutter create . --platforms=<os>` (папки платформ не в репо),
патчат Android INTERNET-permission и macOS `network.client` entitlement, затем `flutter build` →
артефакты apk / windows-zip / macos-zip; тег `v*` → релиз со всеми тремя.
**РАДИУС:** `.github/workflows/build.yml`, `pubspec.yaml`. **Статус:** ✅ CI зелёный, релиз v1.0.0 (3 ассета).
⚠️ macOS не подписан (ПКМ «Открыть»), Android — debug-подпись (сайд-лоад вне Play).

## UC-6. Лендинг на app.ratescout.ru — 🟡
**Предусловие:** DNS `app` → `sementsul.github.io` (добавляет владелец).
**Шаги/ожидаемо:** `pages.yml` деплоит `site/` в GitHub Pages; `site/CNAME`=app.ratescout.ru + custom domain в
настройках Pages (через API). Кнопки «Скачать» ведут на `releases/latest/download/ratescout-{android.apk,windows.zip,macos.zip}`.
**РАДИУС:** `site/index.html`, `site/CNAME`, `.github/workflows/pages.yml`. **Статус:** 🟡 Pages задеплоен; ждёт DNS для домена.
Грабли: `configure-pages` падает, если Pages ещё не включён (гонка) → перезапуск workflow.

## UC-7. Защита репозитория — ✅
**Ожидаемо:** ветка `main` защищена сразу после первого пуша: force-push и удаление запрещены, `enforce_admins: true`.
**РАДИУС:** GitHub branch protection (API). РОЛИ: владелец/админ. **Статус:** ✅ применено (проверено ответом API).

## UC-8. Ссылка из основного сайта — 🟡
**Ожидаемо:** в `sementsul/ratescout` (`build.py`) в обоих sblock левого меню есть пункт «📱 Приложение» → app.ratescout.ru;
появляется после ближайшего деплоя основного сайта.
**РАДИУС:** `build.py` основного репо (2 sblock). СОСЕДИ: [[ratescout-nav-left-only]]. **Статус:** 🟡 закоммичено, ждёт пересборки сайта.
