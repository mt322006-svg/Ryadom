# Request Creation Flow

## Goal

Creating a request must feel like sending a clear local signal, not filling out a service form.

The user should be able to describe a real situation quickly and without friction.

## Product role

This is the core action of the MVP.

If this flow is slow, confusing, or heavy, the product loses its main value.

## UX principles

- one thought per step or block
- plain language instead of formal labels
- approximate location only
- urgency should be easy to express
- paid vs free should be optional and lightweight
- the user should always understand what happens next

## MVP structure

The first version can work as one calm screen with grouped blocks instead of a long wizard.

Recommended block order:

1. What help is needed
2. Short context
3. When it is needed
4. Where approximately
5. Urgency
6. Free or paid
7. Publish action

## Screen outline

### Header

- title: `Нужна помощь`
- short helper text: this request will be visible to nearby people

### Block 1: What happened

- short title input
- examples:
  - `Нужно прикурить автомобиль`
  - `Помочь донести сумки`
  - `Погулять с собакой`

### Block 2: Context

- multiline description
- should stay optional but strongly encouraged
- helps nearby people decide fast

### Block 3: Time

Quick choices:

- сейчас
- в течение часа
- сегодня
- выбрать вручную later

For MVP, quick options are enough.

### Block 4: Approximate location

The app should not ask the user to expose an exact point in the first version.

Use:

- current area label
- editable area note
- radius awareness later

### Block 5: Urgency

Quick choices:

- спокойно
- сегодня
- срочно

Urgency should influence visibility style later.

### Block 6: Compensation

Quick choices:

- бесплатно
- оплачу

If `оплачу` is selected, a simple optional amount field can appear later.

## Publish state

Primary CTA:

`Опубликовать запрос`

After publish:

1. request becomes visible nearby
2. user sees confirmation
3. user can track responses from `Мои запросы`

## What to avoid

- long required forms
- category trees
- contracts or payment flow before publish
- exact address pressure
- chat before someone responds

## Future extensions

- suggested request templates
- amount for paid requests
- better time picker
- location refinement
- trust hints before publish
