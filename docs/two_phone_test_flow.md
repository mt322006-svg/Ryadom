# Two-Phone Test Flow

This note defines the first real-world check for `Мы Рядом` on two Android phones.

The point is simple:
one phone creates a request, the second phone sees it and responds.

If that loop works, the app stops being a solo prototype and starts becoming a living system.

## Goal

Prove the first connected flow:

1. Phone A opens the app
2. Phone A creates a request
3. Phone B sees the request through the same relay
4. Phone B taps `Откликнуться`
5. Phone A sees that the request has movement

## Conditions

- both phones use the same `relay`
- both phones have internet access
- both phones allow optional geolocation
- both phones run the same app build

## In-app setup

The app now keeps a local Nostr identity and one relay URL on the device.

For the first test we use:

- one relay URL for both phones
- one stored identity per phone
- local request state still available as fallback if the relay is down

## Test Steps

### 1. Prepare both phones

- install the same build
- open the `Nostr` pill in the header
- make sure both phones point to the same relay
- confirm the status says `Nostr онлайн`

### 2. Create a request on Phone A

- tap `Нужна помощь`
- create a short clear request
- publish it

Expected result:

- request appears immediately on Phone A locally
- request is published to the relay

### 3. Watch Phone B

Expected result:

- the new request appears on Phone B without manual refresh
- the request can be opened from the radar or activity list

### 4. Respond from Phone B

- open the request
- tap `Откликнуться`

Expected result:

- Phone B sees its own response state
- response and accepted-state events go to the relay

### 5. Check Phone A again

Expected result:

- request reflects that someone responded
- request moves into a more active state

## MVP limits we accept for now

- relay filtering is still broad, not true geospatial relay-side search
- radius filtering is client-side
- request acceptance is still simplified
- chat messages go through relay (kind 31104); history loads by `request_id`

## What we need to observe carefully

- how long relay delivery takes between the two phones
- whether duplicated request records appear
- whether our own requests stay marked as our own after relay sync
- whether response counts stay stable
- whether location/radius settings make sense to real fingers and real screens

## Success definition

The test is successful when:

- both phones connect to the same relay
- Phone A creates a request
- Phone B sees it
- Phone B responds
- Phone A reflects the response

That is the first true heartbeat of the connected product.
