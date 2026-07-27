# Nostr Event Schema

This note turns the general Nostr direction into a concrete schema for `Мы Рядом`.

The point is simple:

before we connect real relays, we need to know exactly what our application is saying.

## Principles

- keep request events public but approximate
- keep direct coordination private
- do not hide product meaning inside random free-form text
- use tags for linking and indexing
- keep the schema small enough to survive MVP changes

## App event kinds

For MVP we keep three application-level event types:

### `31101` - help request

Purpose:
publish a nearby help situation.

Tags:

- `d`: stable request id
- `t`: `we-ryadom`
- `t`: `request`
- `g`: area bucket or approximate geohash
- `status`: `visible`, `accepted`, `completed`, `cancelled`
- `urgent`: `low`, `normal`, `urgent`
- `comp`: `free`, `paid`
- `when`: human-facing time label

Content:

```json
{
  "title": "Прикурить автомобиль",
  "description": "Сел аккумулятор, нужны провода на 10 минут.",
  "area_label": "Рядом с ТЦ Гринвич",
  "time_label": "В ближайшие 15 минут"
}
```

Note:

- exact latitude and longitude stay on the device
- public events carry only approximate area information

Why custom kind:

- it gives us a clean app namespace
- it avoids overloading a generic text-note style event
- it leaves room for future filters and summaries

### `31102` - help response

Purpose:
show that someone is ready to help.

Tags:

- `d`: stable response id
- `e`: referenced request event id
- `a`: optional address of the request for easier indexing
- `t`: `we-ryadom`
- `t`: `response`
- `status`: `sent`, `accepted`, `declined`

Content:

```json
{
  "request_id": "req-123",
  "message": "Я рядом, могу подойти через 5 минут."
}
```

Why separate event:

- responses are first-class product actions
- they should be queryable without parsing a chat log

### `31103` - request state update

Purpose:
track the life of the request without mutating old events.

Tags:

- `d`: stable update id
- `e`: referenced request event id
- `t`: `we-ryadom`
- `t`: `request-state`
- `status`: `accepted`, `in_progress`, `completed`, `rated`, `cancelled`

Content:

```json
{
  "request_id": "req-123",
  "status": "completed",
  "note": "Помощь оказана"
}
```

Why this matters:

- Nostr is append-only in spirit
- status updates should read like a timeline, not like a spreadsheet cell rewrite

## Private chat

For chat we use NIP-17 direct messages.

We do not invent our own public message event for normal private coordination.

App-side metadata can still remember:

- which request the chat belongs to
- who the other participant is
- whether the chat is still active

But the actual private message transport should stay in the direct message layer.

## Mapping from app model

### `HelpRequest -> help request event`

Map:

- `id` -> `d`
- `title` -> content `title`
- `description` -> content `description`
- `areaLabel` -> content `area_label`
- `timeLabel` -> content `time_label`
- `urgency` -> tag `urgent`
- `compensation` -> tag `comp`
- `status` -> tag `status`

### Local response -> help response event

Map:

- local request reference -> tag `e`
- local response id -> tag `d`
- helper message -> content `message`

## Relay queries we will need first

### Nearby requests

Filter by:

- kind `31101`
- tag `t=we-ryadom`
- tag `t=request`
- area bucket `g`
- recent time window

### Responses for one request

Filter by:

- kind `31102`
- referenced request id in `e`

### Request state timeline

Filter by:

- kind `31103`
- referenced request id in `e`

## Deliberate limits

For MVP we do not try to solve everything in schema:

- ratings stay separate
- moderation stays separate
- exact location stays out of public request content
- "helper selection" can remain an application rule on top of raw events

## Sanity check

If a schema choice makes the product harder to understand, it is probably too clever.

We are building a help app, not a museum of distributed systems decisions.
