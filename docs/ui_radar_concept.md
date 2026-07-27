# UI Concept: Radar

## Why this direction

The main screen should not feel like a chat, a list of gigs, or a cold map.

The strongest current direction is a help radar:

- the user sees nearby activity as a living local field
- the interface communicates proximity and motion
- requests feel present in space, not buried in menus

## Core idea

`Мы Рядом` should feel like a local pulse of help.

The main screen combines:

- a radar-style nearby layer
- one strong action to create a request
- a short actionable list of nearby help situations

## MVP interpretation

For version `1.0`, the radar should focus on help requests first.

That means:

- help requests are the primary entities on the radar
- people appear in relation to requests or availability
- other layers such as places, events, or signals stay secondary or postponed

## Main screen structure

1. Header
   - app identity
   - connection status
   - notifications

2. Filter row
   - all
   - people
   - requests
   - signals

3. Radar area
   - user at center
   - radius rings
   - visible nearby request markers
   - urgency and compensation shown through marker states

4. Action area
   - one clear primary action: `Нужна помощь`

5. Nearby activity list
   - short list of active nearby situations
   - focused on action, not passive monitoring

6. Navigation
   - radar
   - requests
   - profile

## UX caution

The radar can easily become visually rich but product-wise blurry.

We should protect against that by keeping one rule:

`In the MVP, help must remain the primary meaning of the screen.`
