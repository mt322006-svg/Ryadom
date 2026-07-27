# Trust & Safety MVP

This note defines the minimum trust and safety layer for `Мы Рядом`.

The product is built on human help, locality, and urgency.

That is beautiful.

It is also exactly the kind of thing bad actors love to exploit.

So the rule is simple:

we do not build on naive trust.

We build on calm trust with guardrails.

## Main risks

### 1. Money scams

Examples:

- asking for prepayment before help
- requesting "fuel money" or "taxi money" in advance
- pretending help is on the way to get a transfer first

### 2. Fake emergencies

Examples:

- invented urgent stories
- emotional pressure to force quick action
- repeated false requests across areas

### 3. Overexposure of private data

Examples:

- exact home address shown too early
- personal phone number shared immediately
- location precision that makes stalking easier

### 4. Unsafe meetings

Examples:

- pushing someone to move to a private place too quickly
- late-night isolated meeting requests
- pressure to leave the app and continue somewhere untracked

### 5. Abuse and spam

Examples:

- mass responses from one new account
- repeated irrelevant messages
- rude, manipulative, or threatening behavior

## MVP safety rules

### Keep location approximate by default

Public request data should show:

- area
- approximate distance
- selected radius

Public request data should not show:

- exact address
- apartment number
- exact pin on a map

### Keep contact inside the app first

Before trust is earned, the default path should be:

- request
- response
- in-app chat
- meeting coordination

The app should not rush users into sharing:

- phone number
- messenger handles
- personal payment details

### No built-in advance payment flow in MVP

If payment exists as a type, it stays descriptive, not transactional.

MVP should avoid:

- prepayment requests
- deposit flows
- money collection tools

This removes one of the easiest scam lanes early.

### Safety language should be calm and visible

We should use short reminders, not alarm sirens.

Examples:

- do not send money in advance to strangers
- meet in a public place when possible
- keep exact address private until you trust the other side

No panic theater.

No fake reassurance either.

## Product restrictions for new users

New accounts should not get full freedom on day one.

MVP protections can include:

- limit active requests
- limit responses per hour
- limit fast repeated chat opens
- flag unusual behavior for review

This is not punishment.

It is just closing the "create account, cause chaos, disappear" loop.

## Trust signals we should show

Do show:

- completed help situations
- confirmed responses
- time in the system
- no-show history in a soft form

Do not over-index on:

- raw star ratings
- vanity scores
- one giant public number pretending to summarize a person

Trust should feel like behavior history, not like a delivery app score.

## Reporting and blocking

Every important surface should support:

- `Пожаловаться`
- `Заблокировать`
- `Скрыть человека`

This must be easy to reach from:

- request details
- chat
- helper/requester profile summary

If a user already feels uneasy, that is not the time to make them solve a UI escape room.

## High-risk patterns to flag internally

The system should watch for:

- many responses from a very new account
- repeated payment-related language
- many cancelled or abandoned interactions
- many reports from different users
- one account posting too many urgent requests in a short time

MVP response does not need full automation.

Even simple internal flags are better than pretending nothing weird is happening.

## Chat safety

Chat should help people coordinate, not disappear into the void.

MVP chat rules:

- keep chat tied to a конкретная ситуация помощи
- show simple status like `на связи`, `в пути`, `завершено`
- allow reporting from chat
- discourage immediate off-platform contact

Quick replies are good.

Blind trust is not a feature.

## Two-phone real-world testing checklist

Before wider rollout, test these on two devices:

1. one user creates a request
2. second user sees it only within chosen radius
3. location stays approximate
4. response opens in-app coordination
5. suspicious or spammy actions can be interrupted

If a flow feels easy to abuse in a simple two-phone test, it will only get worse in the wild.

## MVP stance

`Мы Рядом` should feel warm.

But warm does not mean defenseless.

The goal is human help with boundaries.

That is not cynical.

That is how trust survives contact with reality.
