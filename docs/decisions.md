# Decisions

## 2026-09-24

### Private chat transport

Decision:
private chat uses NIP-17/NIP-59 gift wrapping instead of a public custom chat event with only its content encrypted.

Why:
plain NIP-44 inside a signed public app event hid text but still exposed sender/recipient/request metadata. NIP-17 hides that context inside the encrypted rumor/seal.

### Local plaintext policy

Decision:
decrypted chat — including an exact-location payload — is not persisted in `SharedPreferences`.

Why:
private relay transport is not useful if the app then writes the plaintext to a general preferences snapshot. Chat history is rebuilt from encrypted sender/recipient NIP-17 copies.

### Exact location

Decision:
public requests keep approximate location only. Exact location can be shared deliberately inside private chat after a helper is selected.

Why:
the person asking for help controls when a stranger learns the precise meeting point.

### Protocol UX

Decision:
relay and npub details live under developer diagnostics, not on the radar/profile happy path.

Why:
Nostr is infrastructure. A normal user should only need to know whether the app has a working connection.

### Open-source status and license

Decision:
the repository is public under Apache-2.0.

Why:
inspectability and forking are part of the product promise.

### Architecture cleanup

Decision:
remove the superseded Dart HTTP backend prototype.

Why:
the active connected MVP is Nostr-first. Keeping two contradictory architectures in one repo makes maintenance and contributions worse.

## 2026-07-10

### Product ethics

Decision:
`Мы Рядом` is a **help-first** open-source project, not a commercial gig platform.

Rules:
- no commissions, subscriptions, or paid placement in the MVP path
- no architecture that assumes «fees later»
- paid compensation stays between people
- product optimizes for time-to-help and trust, not revenue per request

## 2026-04-28

### Product category

`Мы Рядом` is a proximity-based help system, not a marketplace.

### MVP platform

Flutter, Android first.

### Main interaction model

request → nearby visibility → response → helper selection → private coordination → completion.

### UI direction

Radar is the main nearby experience. Requests remain the primary layer; the app should not drift into a generic social map.

### Request creation

Calm single-screen composer with grouped blocks instead of a heavy form/chat wizard.

### Theme direction

Support light/dark variants early while keeping radar legible.

### Connected architecture

Use app-specific Nostr events for requests/responses/state and private NIP-17 chat for coordination.

### Safety stance

Trust & safety is MVP surface, not a later moderation add-on.

### Two-phone milestone

A real two-phone relay loop is the acceptance test before adding heavier account/profile systems.
