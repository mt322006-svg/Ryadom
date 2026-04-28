# Ryadom MVP

## Product core

`Ryadom` is not a marketplace. It is a proximity-based help system built around a short loop:

1. A person asks for help.
2. Nearby people see the request.
3. Someone responds quickly.
4. The requester chooses a helper.
5. The task is completed and can be rated.

## First version boundaries

The first version should stay small and reliable.

In scope:
- create a help request
- show nearby requests
- respond to a request
- select a helper
- mark request as completed
- lightweight rating

Out of scope for now:
- complex payment flows
- deep identity verification
- heavy moderation tools
- recommendation systems
- broad social features

## Core entities

### Help request
- title
- description
- compensation type: free or paid
- approximate area
- time label
- urgency
- status

### Status flow

`created -> visible -> accepted -> in_progress -> completed -> rated`

Alternative exit:

`created/visible/accepted -> cancelled`

## UX rules

- one main action in each moment
- approximate location only
- calm interface
- no overload on the first screen
- speed matters more than feature count

## Technical direction

- Flutter, Android first
- Nostr as event transport
- requests as events
- responses as replies
- profiles as Nostr identities
