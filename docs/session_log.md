# Session Log

## 2026-07-10

- Captured founder intent in `vision.md`: learn to help each other, become kinder — technology as practice, not profit.
- Fixed product ethics in docs: **help, not earn**; open source after MVP polish.
- Updated `vision.md`, `product_principles.md`, `decisions.md`, root `README.md`.
- License choice deferred to public release (MIT/Apache candidate).

## 2026-04-28

- Created the Flutter project scaffold.
- Replaced the default sample app with the first `Ryadom` home screen.
- Added initial domain model for help requests and request status.
- Wrote the first MVP doc.
- Agreed that the product should not feel like a chat or a marketplace.
- Captured the radar direction as the current main UI concept.

## 2026-04-29

- Added the request creation flow doc.
- Built the first request creation screen.
- Connected `Нужна помощь` to a real local publish flow.
- Published requests now appear on the home screen and in `Мои запросы`.
- Added a structured MVP spec for the radar main screen.
- Replaced the old list-first home screen with the first radar-style MVP screen.

## Next

- improve local request state and empty states
- prepare navigation and state for the next real user flow
- connect radar markers to richer request states and summaries

## 2026-04-30

- Added the response flow doc.
- Planned local response state as the next logic step.
- Added dark theme to the active implementation queue.
- Implemented the first local response loop from request details.
- Added app-level light and dark theme support with manual toggle.
- Renamed the product-facing brand to `Мы Рядом`.
- Switched the connected MVP direction toward Nostr for requests, responses, and chat.
- Added the first in-app chat flow with сменные темы and quick replies.
- Added a concrete Nostr event schema for requests, responses, and state updates.
- Prepared app-side Nostr mapping helpers so transport can be connected without rewriting core request logic.
- Added MVP trust and safety rules around scam prevention, privacy, and in-app boundaries.
- Added optional geolocation and a user-controlled radius from 500 m to 10 km.
- Added a dedicated Geo MVP note and tightened the rule that public request events keep only approximate location.
- Improved geo states in the app: searching, stable/approximate quality, last update, manual refresh, and clearer user control.
- Polished radar text layout and marker motion on real phone screens.
- Added a live Nostr gateway with saved device identity, relay settings, and live event subscription.
- Replaced the fake `Связь активна` header chip with real Nostr connection state and relay settings.
- Wrote the first two-phone test flow for one-device-create / second-device-respond.
