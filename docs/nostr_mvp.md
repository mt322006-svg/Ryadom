# Nostr MVP

This note fixes how `Мы Рядом` can use Nostr in the first connected version.

The goal is not to make the whole product "about Nostr".

The goal is to use Nostr as the event and messaging layer while keeping product logic, trust, and safety in our own application model.

## Why Nostr now

- it matches the event-driven nature of the product
- requests, responses, and chat already look like events
- it keeps the system lighter and more flexible than a heavy central backend
- it gives us a natural path from local MVP to a real networked prototype

## MVP scope

For the first Nostr-backed pass we use it for:

- user identity
- request publishing
- response publishing
- private chat between participants

We do **not** expect Nostr alone to solve:

- trust scoring
- moderation policy
- abuse handling
- ranking logic
- product-specific state summaries

Those stay in the application layer.

## Event model

### 1. Help request event

Purpose:
publish a help situation to nearby users.

Approach:
use an app-specific event kind for `Мы Рядом` requests.

Suggested payload:

- `title`
- `description`
- `compensation`
- `urgency`
- `time_label`
- `area_label`
- `status`

Suggested tags:

- `d`: stable request id
- `t`: `we-ryadom`
- `t`: `request`
- `g`: approximate geohash or area bucket
- `expiration`: optional TTL for stale requests

Notes:

- area must stay approximate, not exact
- TTL matters because many requests are short-lived
- we should not leak a real home address into public event content

### 2. Response event

Purpose:
signal that a nearby person is ready to help.

Approach:
publish a second app-specific event that references the request.

Suggested payload:

- `request_id`
- `message`
- `status`

Suggested tags:

- `e`: referenced request event id
- `d`: stable response id
- `t`: `we-ryadom`
- `t`: `response`

Notes:

- MVP can keep response content short
- helper selection can still be expressed in app logic, even if responses are distributed as events

### 3. Chat messages

Purpose:
let two people coordinate a real act of help.

Approach:
use NIP-17 private direct messages for the actual conversation.

Notes:

- chat should open only after a meaningful response exists
- chat is not the product center, it is the coordination layer
- quick replies like `Я рядом` and `Уже иду` still make sense in the UI even if transport is Nostr

## Identity

Each user is a Nostr identity.

For MVP:

- generate or import a keypair
- keep onboarding calm and simple
- hide protocol complexity from normal users

The user should feel:
"I opened the app and I can ask for help"

not:
"Welcome to a decentralized key ceremony"

## Relay strategy

For MVP:

- start with a small controlled relay set
- do not depend on random public relays for core user experience
- keep relay configuration explicit in the app layer

This gives us:

- better reliability
- better control of product behavior
- less chaos during testing

## Privacy and trust

Important:

- public request events must stay approximate in location
- private coordination should move to direct chat as soon as possible
- trust, reports, and rating should be calculated by app rules, not guessed from raw relay data

## First implementation order

1. define app-specific Nostr kinds and tags
2. move request publish from local state to Nostr event creation
3. move response publish to Nostr event creation
4. connect chat transport to NIP-17 messages
5. keep trust and rating as a separate application layer

## Product stance

Nostr is the transport and event fabric.

`Мы Рядом` is still the product.

That sounds obvious, but it saves us from the classic engineer move of falling in love with the pipe and forgetting the water.
