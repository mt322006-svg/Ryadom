# Geo MVP

This note defines how geolocation should behave in `Мы Рядом` without turning the app into either a toy or a surveillance gadget.

## Why it matters

Location is one of the core promises of the product.

If `рядом` is vague, unstable, or misleading, the product loses its spine.

So the rule is simple:

geolocation is infrastructure, not decoration.

## MVP goals

- know whether the phone has a usable location
- let the user control whether geo is on
- let the user choose the visibility radius
- keep public location approximate
- keep the UI honest about confidence and errors

## Location states

The app should clearly show one of these states:

- `Ищем точку`
- `Гео точное`
- `Гео стабильное`
- `Гео примерное`
- `Геодоступ не выдан`
- `Включи геолокацию на телефоне`
- `Гео выключено`

This matters because “enabled” is not the same thing as “trustworthy”.

## Precision model

Inside the phone we may keep:

- exact latitude
- exact longitude
- accuracy in meters
- last update time

Publicly we should expose only:

- area label
- approximate zone
- selected radius

Not:

- exact coordinates in public events
- exact home entrance
- apartment-level precision

## Radius

The user should be able to choose:

- `500 м`
- `1 км`
- `3 км`
- `5 км`
- `10 км`

For MVP the radius filter is client-side.

That is acceptable as long as it is predictable and tested on real phones.

## Update policy

For now:

- get location when the user enables it
- allow manual refresh
- show when the point was last updated

Do not:

- hammer GPS constantly
- pretend stale coordinates are fresh

## Network and privacy stance

When we publish request events:

- keep area information approximate
- send a coarse area bucket for indexing
- do not send exact latitude and longitude in public request events

This is both a privacy rule and a trust rule.

## Two-phone acceptance check

Before we call geo ready for live testing, verify:

1. both phones can enable location cleanly
2. both phones show understandable geo state
3. radius filtering behaves the same way on both phones
4. public request data stays approximate
5. requests do not jump wildly because of one noisy GPS read

## MVP stance

Good geo in `Мы Рядом` should feel calm and dependable.

Not magical.

Not creepy.

Just clear enough that people can trust what “рядом” means.
