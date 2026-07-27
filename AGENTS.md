# Мы Рядом (Ryadom)

Flutter MVP: помощь рядом + Nostr. Пакет `com.ryadom`.

## Сборка и проверка

- Тесты: `flutter test`
- Analyze: `flutter analyze lib test`
- Release APK: `flutter build apk --release` или `.\scripts\build-apk.ps1`
- Установка: `adb install -r build\app\outputs\flutter-apk\app-release.apk`
- Не добавлять `dependency_overrides` без необходимости

## Продукт

- Темы: Настройки → Классическая / Ночная / Светлая / Киберпанк
- Радар: зоны близости, гео обновляется при resume и по таймеру
- Два телефона: один relay Nostr на обоих
- Язык: ru по умолчанию, en в настройках

## Код

- UI: `lib/features/`, тема: `lib/theme/`
- Стеклянные кнопки: `lib/theme/ryadom_buttons.dart`
- Минимальные точечные правки, без лишних рефакторингов

## Конвенции

- Отвечать по-русски, по делу
- Сам запускать `flutter` / `adb`, не отдавать только инструкции
- Скрины: `adb shell screencap` → `screenshots/`
