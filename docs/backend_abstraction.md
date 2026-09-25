# Phase 4: backend abstraction

## Goal

Decouple the Ryadom product from a specific transport without changing the
current UX and without removing Nostr.

The target dependency direction is:

```text
UI / presentation
  -> use-cases / domain policy
  -> RyadomBackend
  -> NostrBackend
  -> optional future backend implementations
```

Phase 4 is an architectural hardening phase. It does not add product features.

## Non-goals

- no UI redesign
- no new user-facing screens
- no Supabase dependency in main
- no NIP-17/NIP-44 rewrite
- no localization cleanup
- no broad renaming or folder migration
- no removal of the current Nostr implementation

## First contract

The first transport-neutral contract lives under `lib/backend/`:

- `ryadom_backend.dart`
- `backend_models.dart`
- `encrypted_payload.dart`
- `chat_crypto.dart`

The contract intentionally uses existing product domain types where they are
already stable and introduces only the minimum transport-neutral wrappers
needed at the boundary.

The existing `RequestId` type is currently an ID generator rather than a
value object, so backend APIs use `String requestId` for now. Converting IDs
to value objects is not part of this PR.

## Privacy boundary

Backends must not receive plaintext chat content.

The intended flow is:

```text
plaintext
  -> ChatCrypto
  -> EncryptedPayload
  -> RyadomBackend
  -> transport/storage
```

Exact location follows the same rule. The product policy deciding whether
exact location may be shared belongs above the backend adapter. The backend
only transports encrypted material.

`EncryptedPayload.metadata` is restricted to non-sensitive routing/format
metadata. Plaintext messages and exact coordinates must never be stored there.

## Nostr adapter

The current Nostr implementation remains the production implementation during
Phase 4.

A later PR will place the current gateway/protocol code behind
`NostrBackend implements RyadomBackend`. Nostr-specific concepts such as
relay URLs, event kinds, gift wraps, npub/pubkey presentation and protocol
validation must not leak through the product-facing contract.

## Local store

`LocalNostrRequestStore` is deliberately not given a new generic interface in
this first PR.

Today it combines several responsibilities:

- local request/state materialization
- Nostr event persistence
- responder/helper state
- decrypted in-memory chat reconstruction
- protocol-specific event handling

Freezing that shape behind a generic `LocalRequestStore` now would preserve
the coupling under a new name. Its responsibilities will be split while the
Nostr adapter is introduced.

## Trust and safety

Trust and safety does not require ambient plaintext access to private chat.

Backends may enforce:

- rate limits
- request/state authorization
- reports
- blocks
- abuse controls

Any private-message evidence attached to a report must be an explicit
user-submitted payload, not silent server-side chat inspection.

## Planned PR sequence

1. Contract and architecture document only.
2. Introduce `NostrBackend` around current request/response/state behavior.
3. Move home flow to use-cases/backend abstraction.
4. Move chat flow away from direct Nostr dependencies.
5. Lift crypto above transport so backends only carry encrypted payloads.
6. Add reusable backend contract tests and a fake backend.
7. Only then build a Supabase spike for comparison.

## Definition of done for Phase 4

- presentation code does not depend on Nostr protocol primitives
- Nostr event kinds stay inside the Nostr adapter
- a fake `RyadomBackend` can replace the production backend in tests
- private chat crosses the backend boundary only as ciphertext
- exact-location permission/purge rules live in domain/use-case policy
- backend contract tests pass
- existing tests remain green
- `flutter analyze lib test` is clean
- `flutter test` is green
