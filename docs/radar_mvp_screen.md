# Radar MVP Screen

## Purpose

The radar screen is the main nearby view of `Мы Рядом`.

Its job is not to entertain or monitor everything around the user.
Its job is to help the user understand, in a few seconds:

- what help is needed nearby
- how urgent it is
- what they can do next

## Main rule

In the MVP, the radar is primarily about help requests.

It is not:

- a social map
- a city events feed
- a general local discovery screen

## User outcomes

The screen should support two fast outcomes:

1. `I need help`
2. `I can help`

Everything else is secondary.

## Screen structure

### 1. Header

Contents:

- app name
- quiet connection status
- optional notifications entry

Behavior:

- should feel calm
- should not compete with the radar

### 2. Filter row

MVP filters:

- `Все`
- `Запросы`
- `Люди`
- `Сигналы`

Rules:

- default filter is `Все`
- `Запросы` is the most product-important filter
- `Люди` should be secondary and lightweight
- `Сигналы` should remain limited in MVP

### 3. Radar canvas

This is the visual center of the screen.

Contents:

- user at the center
- distance rings
- nearby request markers
- subtle sweep or live-state effect

Rules:

- request markers must be more important than other entities
- exact location must not be exposed
- visual density must stay low enough to scan quickly

### 4. Primary action

There must be one clear primary action on the radar screen:

`Нужна помощь`

Rules:

- always visible
- easy to tap with one hand
- should feel like creating a signal, not opening a complex form

### 5. Nearby activity list

Below the radar, show a short list of actionable nearby situations.

Examples:

- `Прикурить автомобиль`
- `Помочь донести сумки`
- `Погулять с собакой`

Rules:

- keep the list short
- prioritize urgency and recency
- each row should be understandable in one glance

### 6. Navigation

MVP navigation:

- `Радар`
- `Запросы`
- `Профиль`

The radar is the default landing screen.

## Marker system

### Request markers

These are the primary marker type in MVP.

Each request marker should communicate:

- approximate distance
- urgency
- compensation type

Suggested encoding:

- color or glow intensity for urgency
- small badge or icon hint for paid/free
- tap opens short request summary

### People markers

People should not dominate the screen in MVP.

Use them only if they serve the help loop:

- available helper nearby
- selected helper later
- maybe anonymous or lightweight representation

### Signal markers

Signals can exist, but should stay limited.

They are useful only if they support nearby decision-making.

## Content priority

When the screen has too much going on, use this order:

1. urgent help requests
2. fresh nearby requests
3. own active requests
4. helper presence
5. other signals

## States

### Default state

- radar visible
- a few nearby requests visible
- activity list under it
- primary action available

### Low activity state

- radar still visible
- fewer markers
- encourage creating a request or widening view later

### No nearby requests state

- do not show a dead empty screen
- keep the radar structure
- show a calm message and the main action

Example idea:

`Пока рядом тихо. Если нужна помощь, можно создать сигнал первым.`

### Own request active state

If the user has an active request:

- it should be visible in `Мои запросы`
- radar can gently emphasize that the request is now visible nearby

## What stays out of MVP

- heavy map interactions
- crowded real-time simulation
- deep entity taxonomy
- complex event/place layers
- full chat from the radar itself

## Engineering note

For implementation, it is acceptable to start with:

- a stylized radar panel
- static or locally generated marker positions
- local request data from app state

The first goal is product clarity, not geographic precision.
