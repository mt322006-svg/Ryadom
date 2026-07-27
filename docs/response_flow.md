# Response Flow

## Purpose

The response flow is the first real interaction between people in `Мы Рядом`.

The product stops being only about publishing a signal and starts becoming a local exchange:

1. someone asks for help
2. someone nearby responds
3. the request starts showing movement

## MVP goal

In the first local version, a response should be simple and immediate.

The user should be able to:

- open a request
- tap `Откликнуться`
- see that the response changed the request state

## MVP behavior

### For a nearby request

When the user taps `Откликнуться`:

- the request stores that the current user responded
- the request response count increases
- the request can move from `visible` toward `accepted`
- the interface should show that the request now has movement

### For the request owner

For requests created by the current user:

- the UI should show how many responses arrived
- `Мои запросы` should reflect that the request is no longer static

## UI touchpoints

- radar marker
- nearby activity list row
- request details bottom sheet
- `Мои запросы`

## What matters most

- the response must feel immediate
- the state change must be visible
- no heavy chat or negotiation yet

## What stays out of MVP

- multi-user sync
- full helper selection flow
- real chat between both sides
- trust negotiation steps

## Engineering direction

For now, local state is enough.

We can model:

- response count
- current user responded yes/no
- own request yes/no

That gives us a believable first response loop before networking arrives.
