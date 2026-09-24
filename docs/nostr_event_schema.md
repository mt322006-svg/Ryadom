# Nostr Event Schema

## Public app events

### 31101 — help request

Required tags:
- `d` stable request id
- `t=we-ryadom`
- `t=request`
- `g` approximate area bucket
- `status`
- `urgent`
- `comp`
- `when`

Content:
```json
{
  "title": "Прикурить автомобиль",
  "description": "Сел аккумулятор, нужны провода.",
  "area_label": "Примерная зона",
  "time_label": "Сейчас"
}
```

`latitude` и `longitude` в публичном content запрещены.

### 31102 — help response

Tags:
- `d` stable response id
- `e` referenced request event id
- `a` request address
- `t=we-ryadom`
- `t=response`
- `status=sent|accepted|declined`

Content:
```json
{
  "request_id": "req-123",
  "message": "Я рядом, могу помочь."
}
```

### 31103 — request state

Tags:
- `d` stable update id
- `e` referenced request event id
- `t=we-ryadom`
- `t=request-state`
- `status`

Content may include:
- `request_id`
- `status`
- short `note`
- selected `helper_pubkey`
- optional rating 1..5

State update принимается только от pubkey автора исходного request.

## Private chat: NIP-17

Публичного `31104` chat-event на relay **нет**.

Wire format:
- unsigned `kind 14` rumor: text + `p` participant + private `subject=we-ryadom:<requestId>`
- signed `kind 13` seal, encrypted with NIP-44
- random-key signed `kind 1059` gift wrap, encrypted again

`subject`, request id, real sender and message body находятся внутри шифрованных слоёв.

Для sender history создаётся отдельный gift wrap на собственный pubkey.

## Exact location payload

После выбора помощника автор может осознанно отправить structured payload:
```json
{
  "type": "ryadom.location.v1",
  "latitude": 55.0,
  "longitude": 37.0
}
```

Он передаётся **только как содержимое приватного NIP-17 сообщения** и не копируется в public request/state.

## Ingest limits

Клиент проверяет kind, signature, типы JSON-полей, длины строк и tags, допустимые enum values и timestamp skew. Неожиданный или malformed event отбрасывается.
