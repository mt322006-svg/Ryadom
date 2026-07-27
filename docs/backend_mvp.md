# Backend MVP

## Purpose

The first backend for `Мы Рядом` should make the product real as quickly as possible.

Its job is not to solve the final architecture.
Its job is to provide a stable first networked loop:

1. create request
2. fetch nearby requests
3. respond to request
4. see request state change

## Decision

For the first backend MVP, use a small HTTP API on Dart instead of jumping directly into a full Nostr-first runtime.

Nostr remains strategically important, but it should not block the first working server.

## Why this approach

- fastest path to a real connected MVP
- easy to run locally
- easy to debug
- low cognitive overhead
- keeps us focused on the product loop

## What the backend must do

### Requests

- create a request
- list active requests
- fetch a request by id
- update request state later

### Responses

- create a response to a request
- increase response count
- reflect that a user responded

### Health

- expose a health endpoint
- be easy to boot and test locally

## First API shape

### `GET /health`

Returns:

- service status
- current timestamp

### `GET /requests`

Returns:

- active requests
- enough fields for the current Flutter UI

### `POST /requests`

Creates:

- a new help request

### `POST /requests/<id>/respond`

Creates:

- a new local response for a request
- increments response count

## Data model for MVP

### Request

- id
- title
- description
- compensation
- area label
- time label
- urgency
- status
- response count
- own request flag later on the client side

### Response

- id
- request id
- responder id
- created at

## Storage

For the first iteration:

- keep data in memory
- accept reset-on-restart behavior

This is enough to validate the API contract and frontend integration.

Next layer can move to SQLite or Postgres once the client flow stabilizes.

## Nostr position

Nostr is not abandoned.

It moves to the next architecture stage:

- once the product loop is stable
- once request and response semantics are clearer
- once we know what should remain event-native

## Local run target

The backend should run locally on:

`http://localhost:8080`

## Next backend steps

1. scaffold the Dart server
2. implement health and request endpoints
3. implement response endpoint
4. connect Flutter to real backend data
5. replace local in-app sample state gradually
