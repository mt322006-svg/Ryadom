# Nostr MVP

Nostr в `Мы Рядом` — транспорт и event fabric, а не пользовательский интерфейс.

## Что идёт публично

Три app-specific типа событий:

- `31101` — help request
- `31102` — response
- `31103` — request state update

Они подписаны обычным Nostr identity пользователя и проходят строгую проверку схемы перед ingest.

Публичный запрос содержит только приблизительную зону (`g` bucket / area label). Точные latitude/longitude в public request запрещены.

## Приватный чат

Чат использует NIP-17/NIP-59:

1. сообщение создаётся как **unsigned kind 14 rumor**
2. rumor шифруется NIP-44 и помещается в подписанный sender key **kind 13 seal**
3. seal шифруется ещё раз и помещается в **kind 1059 gift wrap**
4. gift wrap подписывается свежим случайным wrapper key
5. relay снаружи видит только gift wrap и `p` получателя, но не настоящий sender/request/message metadata

Отдельный encrypted sender-copy публикуется самому отправителю, чтобы чат можно было восстановить после рестарта без сохранения plaintext history в `SharedPreferences`.

Внутренний app event kind `31104` существует только после расшифровки **в памяти приложения**. На relay как публичный chat event он не публикуется.

## Exact location

Точная геопозиция — structured payload внутри приватного NIP-17 chat.

Условия:
- только автор собственного запроса
- только после выбора конкретного помощника
- отдельное явное подтверждение пользователя
- координата снимается заново непосредственно перед отправкой
- public request event никогда не получает точную точку

## Identity

Устройство создаёт Nostr keypair автоматически. Private key хранится через secure storage.

Протокольные детали скрыты из обычного радара и профиля. Relay/npub диагностика относится к developer options.

## Relay strategy

MVP пока допускает один настраиваемый relay для простого двухтелефонного теста.

Для более широкого запуска понадобятся:
- маленький контролируемый список relay
- NIP-17 DM-relay discovery / NIP-42 там, где это поддерживается
- понятная деградация при недоступности relay

## Validation

Принятый event обязан:
- иметь корректную Nostr signature
- быть ожидаемого kind
- пройти type/length/tag validation
- не содержать точных координат в public request
- для state update быть подписан автором исходного request

Malformed event должен быть отброшен, а не ронять клиент.

## Product stance

Обычный пользователь видит «Связь работает / нет связи», а не церемонию из `wss://`, `npub` и event kinds.
