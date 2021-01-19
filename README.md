# Email alert frontend

A frontend for creating and managing email subscriptions.

## Overview

### Signup

This app provides three routes for signing up to email:


- A `/email-signup?link=/:base_path` route [[example](https://www.gov.uk/email-signup/?link=/money)].

This route supports signup to several types of content. It was [originally specific to the taxonomy](https://github.com/alphagov/email-alert-frontend/pull/33) (despite the generic name), and then [got re-purposed for other document types](https://github.com/alphagov/email-alert-frontend/pull/451).

- A **legacy** `/:base_path/email-signup` route [[example](https://www.gov.uk/foreign-travel-advice/canada/email-signup)].

Each of these routes corresponds to a content item with an [`email_alert_signup` schema](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/email_alert_signup.jsonnet). At the time of writing, `/foreign-travel-advice/*` still uses this route.

- A `/email/subscriptions/new` route [[example](https://www.gov.uk/email/subscriptions/new?topic_id=statistics-with-1-research-and-statistic-5e2982632b)].

This route enables any other application to offer a fully customised email signup experience that is not reliant on the content store.

It is used by apps like [finder-frontend](https://github.com/alphagov/finder-frontend), where a new subscriber list is created from the combination of selected filters.

### Double Opt-In

In order to verify the email for a new subscription:

- We [send a verification email using email-alert-api](https://github.com/alphagov/email-alert-frontend/pull/629)
- The email [contains a link with a unique token for the subscription](https://github.com/alphagov/email-alert-api/pull/1051)\*
- Clicking on the link [completes the signup process](https://github.com/alphagov/email-alert-frontend/pull/615)

\* Note that [the token strategy has changed over time](https://github.com/alphagov/email-alert-api/pull/1083).

### Manage

This allows the user to list, modify and delete their subscriptions [[login](https://www.gov.uk/email/manage/authenticate)]. It uses a similar, but separate email/token process to authenticate a user, establishing a session for them to make their changes.

## Nomenclature

### Tags and links

Uniquely define a list people can subscribe to. The criteria within are used to figure out whether an update is relevant subscribers in the list. Defined in [the docs for email-alert-api](https://github.com/alphagov/email-alert-api/blob/master/doc/matching-content-to-subscriber-lists.md).

```
tags: { topics: { any: ["business-tax/vat"] } }
```

```
links: { topics: { any: ["1ddaaacb-0981-4abc-a532-a5111f2bea6b"] } }
```

### Legacy tags and links (yay)

These terms are also used by [the legacy `email_alert_signup` schema](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/email_alert_signup.jsonnet). Note that the flat lists of base paths or Content IDs are interpreted as "any" in the above definition.

```
"tags": { "countries": ["foreign-travel-advice/canada"] }
```

```
"links": { "countries": ["f402b8de-2e99-4ff3-949f-31fe65796cae"] }
```

## Running the test suite

```
$ bundle exec rake
```

## Licence

[MIT License](LICENCE)
