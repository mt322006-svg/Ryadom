# Мы Рядом

Android-first Flutter-приложение для быстрой **локальной** помощи рядом.

Не маркетплейс и не «заработок на курьерах». Смысл простой:

1. человек создаёт запрос о помощи  
2. соседние люди видят его на **радаре**  
3. кто-то откликается  
4. автор выбирает помощника  
5. договариваются в чате, завершают, оценивают  

**Помощь важнее монетизации.** Открытый исходный код — когда петля на живых телефонах стабильна.

## Стек

| | |
|--|--|
| UI | Flutter (Material 3) |
| Платформа | Android first |
| Связь | Nostr (relay, события запросов / откликов / чата) |
| Гео | опционально, публично только **приблизительная зона** |
| Локализация | `ru` (по умолчанию), `en` |

Пакет приложения: `com.ryadom`  
Версия: см. `pubspec.yaml`

## Возможности MVP

- Радар с **зонами близости** (кольца) и обновлением гео  
- Создание запроса, отклик, выбор помощника, чат (NIP-44)  
- Отмена своего запроса, TTL неактивных сигналов  
- Радиус поиска 500 м … 10 км  
- Открытие ориентира зоны в Яндекс / Google Картах  
- Темы: классическая, ночная, светлая, киберпанк  
- Блок / жалоба, rate limit откликов  

## Запуск

```bash
flutter pub get
flutter run
```

Тесты:

```bash
flutter test
flutter analyze lib test
```

## Сборка APK

```powershell
# release
flutter build apk --release

# или скрипт
.\scripts\build-apk.ps1
```

Готовый файл: `build/app/outputs/flutter-apk/app-release.apk`  
(копия вида `ryadom-<version>.apk` — если используете `scripts/build-apk.ps1`).

Подпись: `android/key.properties` (не в git; есть `key.properties.example`).

## Два телефона

1. Один и тот же **relay** в настройках Nostr (например `wss://nos.lol`)  
2. На обоих — гео и похожий радиус  
3. Телефон A: «Нужна помощь» → опубликовать  
4. Телефон B: радар / «Запросы» → отклик  
5. A: увидеть движение → чат  

Подробнее: [docs/two_phone_test_flow.md](docs/two_phone_test_flow.md)

## Документация

Каталог [docs/](docs/README.md) — видение, MVP, гео, Nostr, trust & safety, журнал сессий.

## Структура

```
lib/
  app/                 # MaterialApp, locale, theme
  features/
    home/              # радар, навигация
    requests/          # создание и lifecycle запросов
    chat/              # чат
    nostr/             # gateway, store, NIP-44
    geo/               # privacy buckets, map links
    trust/             # block / report / rate limit
    settings/
  l10n/                # ru / en
  theme/
```

## Лицензия

См. [LICENSE](LICENSE). Выбор публичной лицензии — к моменту open source релиза.
