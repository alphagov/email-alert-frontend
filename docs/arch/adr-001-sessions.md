# Decision Record: Session management for Email Alert Frontend

> NOTE
> This ADR has been superseded by [ADR 002](adr-002-sessions.md).

## Introduction

Frontend applications on GOV.UK have cookies stripped by Varnish. This renders the default CSRF protection offered by Rails useless and also raises an error if CSRF is not actively disabled for the application.

### CSRF and Authenticity Tokens

An accepted way of securing against Cross Site Request Forgery in web applications is the inclusion of a hidden authenticity token in each form which might cause state to change (typically PUT, POST and DELETE actions). The role of the token is to ensure requests have come from pages served by the application and not malicious third party sites. The built-in default CSRF protection in Rails requires session cookies.

### GOV.UK Varnish configuration

All GOV.UK frontend applications aside from Licensing have their cookies stripped by Varnish. See [`vcl_recv`](https://github.com/alphagov/govuk-puppet/blob/a6c51d887a6501f02766b7279127b60f02037a7f/modules/varnish/templates/default.vcl.erb#L83) and [`vcl_fetch`](https://github.com/alphagov/govuk-puppet/blob/a6c51d887a6501f02766b7279127b60f02037a7f/modules/varnish/templates/default.vcl.erb#L119).

### Email Alert Frontend's responsibilities

Email Alert Frontend is responsible for the front end journeys that allow users to subscribe to and unsubscribe from emails. It communicates with Email Alert API through GDS API Adapters. Email Alert API stores and retrieves the actual data relating to email subscriptions.

## Current Decision

The current decision is to continue stripping cookies in Varnish for Email Alert Frontend and to disable CSRF protection on a [per-method basis](https://github.com/alphagov/email-alert-frontend/blob/9f786ffeccbe69753f881854f6878e77a80ddd98/app/controllers/unsubscriptions_controller.rb#L2).

Disabling CSRF protection for the application as a whole was rejected because its not expected application behaviour and could leave unintended security risks in place in the future if developers expect a standard Rails application setup.

### Risk

The main risk to newly-developed functionality at the moment is that a malicious party could trick users into subscribing to or unsubscribing from content on GOV.UK. A further risk is that a malicious party could iterate through or craft specific UUIDs in an attempt to automate unsubscriptions.

## Future

It is likely that Email Alert Frontend will want to implement proper session management in a future piece of development when the full subscription management process is undertaken. At that point we should revisit this decision and if appropriate remove the code disabling CSRF protection.

There are some potential issues with caching in that Fastly does not differentiate on session cookies which means users will see each other's content. This is something Tijmen brought up so it's worth chatting to him about it for more context.
