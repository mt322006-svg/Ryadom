# Session Log

## 2026-09-25

- Continued phase-2 hardening from current `main`.
- Extracted Nostr developer settings and geo/radius sheets from `HomeScreen`.
- Exact shared locations are now purged from in-memory chat when a request is completed, rated or cancelled.
- Added a regression test for exact-location purge.
- Replaced clock-based request IDs with 128-bit `Random.secure` IDs and added uniqueness/format coverage.
- Updated privacy documentation to match the shorter lifetime of exact-location data.
- Opened draft PR #4 for CI validation before merge.

## 2026-09-24

- Integrated the private exact-location sharing work onto the hardening branch.
- Replaced public custom chat transport with NIP-17/NIP-59 gift wraps.
- Added encrypted sender copies so restart recovery does not require plaintext chat persistence.
- Purged legacy decrypted chat records from SharedPreferences and stopped future plaintext chat persistence.
- Added strict validation for incoming app-specific Nostr events.
- Serialized local snapshot writes to avoid racing persistence updates.
- Split large home/chat presentation widgets into part files without adding a state-management framework.
- Removed Nostr jargon from the radar/profile happy path; relay settings moved to developer options.
- Added completion gratitude + optional rating and actionable empty states.
- Removed the superseded HTTP backend prototype.
- Added/updated privacy, security and protocol documentation.
- Added CI and privacy/NIP-17 tests.

## 2026-07-10

- Captured founder intent: people learn to help each other; product does not monetize urgency.
- Fixed help-first/open-source principles in docs.
- Chose Apache-2.0 for public release.

## 2026-04-30

- Added response flow and app themes.
- Connected the MVP direction to Nostr.
- Added chat, Nostr event schema, trust/safety rules and optional geolocation.
- Added radius control and real connection state.
- Prepared two-phone live testing.

## 2026-04-29

- Added request creation.
- Connected published requests to home / My Requests.
- Moved main UI to radar-first.

## 2026-04-28

- Created Flutter project scaffold.
- Added initial help request model and MVP docs.
- Fixed the product category: help system, not marketplace.
