# Decisions

## 2026-04-28

### Product category

Decision:
`Ryadom` is a proximity-based help system, not a marketplace.

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
