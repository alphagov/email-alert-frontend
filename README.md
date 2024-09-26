# Email alert frontend

A frontend for creating and managing email subscriptions.

## Features

### Signup

This app provides three routes for signing up to email:

- A `/email-signup?link=/:base_path` route [[example](https://www.gov.uk/email-signup/?link=/money)]. This route supports signup to several types of content. It was [originally specific to the taxonomy](https://github.com/alphagov/email-alert-frontend/pull/33) (despite the generic name), and then [got re-purposed for other document types](https://github.com/alphagov/email-alert-frontend/pull/451).

- A **legacy** `/:base_path/email-signup` route [[example](https://www.gov.uk/foreign-travel-advice/canada/email-signup)]. Each of these routes corresponds to a content item with an [`email_alert_signup` schema](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/email_alert_signup.jsonnet). At the time of writing, `/foreign-travel-advice/*` still uses this route.

- A `/email/subscriptions/new` route [[example](https://www.gov.uk/email/subscriptions/new?topic_id=statistics-with-1-research-and-statistic-5e2982632b)]. This route enables any other application to offer a fully customised email signup experience that is not reliant on the content store. It is used by apps like [finder-frontend](https://github.com/alphagov/finder-frontend), where a new subscriber list is created from the combination of selected filters.

In order to verify the email for a new subscription, we send a verification email using Email Alert API. The email contains a link with a unique token for the subscription. Clicking on the link completes the signup process.

### Manage

This allows the user to list, modify and delete their subscriptions [[login](https://www.gov.uk/email/manage/authenticate)]. It uses a similar, but separate email/token process to authenticate a user, establishing a session for them to make their changes.

## Nomenclature

- [Tags and Links](docs/tags-and-links.md) - strings that uniquely define a list to subscribe to

## Technical documentation

This is a Ruby on Rails app, and should follow [our Rails app conventions](https://docs.publishing.service.gov.uk/manual/conventions-for-rails-applications.html).

You can use the [GOV.UK Docker environment](https://github.com/alphagov/govuk-docker) to run the application and its tests with all the necessary dependencies. Follow [the usage instructions](https://github.com/alphagov/govuk-docker#usage) to get started.

**Use GOV.UK Docker to run any commands that follow.**

### Running the test suite

```
$ bundle exec rake
```

### Publishing Routes

There are six routes provided by this app: /email-signup, /email-signup/confirm, /email/unsubscribe, /email/subscriptions, /email/authenticate and /email/manage. If you are deploying this app to a new environment, you will need to publish these routes using the [special_route tasks](https://github.com/alphagov/publishing-api/blob/main/docs/admin-tasks.md#publishing-special-routes) in Publishing API

### Testing account pages

Some pages are only accessible once a user has logged-in, using a link sent in an email. To test these pages locally, you will need to make a temporary change to the controller code to bypass authentication. If testing on a deployed branch, see the documentation on [receiving emails from in Integration and Staging](https://docs.publishing.service.gov.uk/manual/receiving-emails-from-email-alert-api-in-integration-and-staging.html).

## Licence

[MIT License](LICENCE)
