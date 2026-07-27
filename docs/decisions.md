# Decisions

## 2026-07-10

### Product ethics and release model

Decision:
`Мы Рядом` is a **help-first** project: polish the MVP, then **open source**. Not a commercial gig platform.

Why:
The founder intent is explicit: the app should help people nearby, not earn from them. Open source keeps that promise visible and harder to quietly reverse.

Rules:
- no commissions, subscriptions, or paid placement in the MVP path
- no architecture that assumes «fees later»
- paid compensation stays **between people**, outside app monetization
- public release only after the two-phone core loop is solid

### License direction (pending)

Decision:
Pick an OSI license at open-source release (likely permissive: MIT or Apache-2.0). Decide together before the first public repo push.

Why:
License choice is a release step, not a blocker for current MVP work.

## 2026-04-28

### Product category

Decision:
`Мы Рядом` is a proximity-based help system, not a marketplace.

Why:
This protects the product from drifting into gig-platform patterns too early.

### MVP platform

Decision:
Build the first version in Flutter, Android first.

Why:
This keeps delivery focused while preserving room for later expansion.

### Main interaction model

Decision:
The core interaction is request -> nearby visibility -> response -> helper selection -> completion.

Why:
This is the shortest meaningful loop for the product.

### UI direction

Decision:
Explore the radar as the main nearby experience, but keep help requests as the primary layer.

Why:
The radar expresses locality and real-time presence better than a plain list or a chat-first interface.

### Request creation approach

Decision:
Use a calm single-screen request composer with grouped blocks instead of a heavy form or a chat-like flow.

Why:
This keeps the MVP fast to understand while preserving structure and trust.

### Radar MVP scope

Decision:
The radar screen in MVP should focus on nearby help requests first, with other entities staying secondary.

Why:
This keeps the main screen aligned with the core product loop and protects it from becoming a generic local activity map.

### Theme direction

Decision:
Support both light and dark theme early, with radar visuals staying strong in both modes.

Why:
The product naturally lives in a calm, low-noise visual space, and the radar experience especially benefits from dark presentation.

### Backend MVP direction

Decision:
Move the first connected product layer toward Nostr for requests, responses, and private chat.

Why:
The product already behaves like an event system. Nostr matches that shape better than a heavier central service, while still letting us keep trust and moderation logic in the app layer.

### Nostr event shape

Decision:
Use app-specific event kinds for requests, responses, and request state updates, while keeping private coordination in direct messages.

Why:
This keeps the protocol layer explicit and queryable, without stuffing all product meaning into generic text events.

### Safety stance

Decision:
Treat trust and safety as part of the MVP surface, not as a later moderation add-on.

Why:
The product combines urgency, geography, and human trust. That makes it valuable, and it also makes it attractive to scammers if we leave it naive.

### Two-phone direction

Decision:
Move the next milestone to a real two-phone relay test before deeper account work like SMS login.

Why:
If two phones cannot create, see, and respond through one shared event channel, heavier auth and profile layers would only decorate an unfinished core.
