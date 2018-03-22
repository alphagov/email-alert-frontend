# Decision Record: Session management for Email Alert Frontend

> NOTE
> This ADR supersedes by [ADR 001](adr-001-sessions.md).

## Introduction

As part of implementing subscription management, we have decided to enable sessions in Email Alert Frontend. This will allow users to move through the subscription management interface without having to pass large query string parameters between pages.

## Technical implementation

The Varnish configration for [`vcl_recv`](https://github.com/alphagov/govuk-puppet/blob/a6c51d887a6501f02766b7279127b60f02037a7f/modules/varnish/templates/default.vcl.erb#L83) and [`vcl_fetch`](https://github.com/alphagov/govuk-puppet/blob/a6c51d887a6501f02766b7279127b60f02037a7f/modules/varnish/templates/default.vcl.erb#L119) that strips all cookies except for those set by Licensing has been modified to allow cookies for all pages under `/email`. This will enable sessions to work once we start setting session data.

# CSRF protection

Email Alert Frontend has been updated to enable CSRF protection for controllers that render pages under `/email` since cookies are now set for these pages. This fixes some of the issues referred to in ADR 001.

# Cache-Control headers

Email Alert Frontend now explicitly sets the `Cache-Control` HTTP header to `private`. This signals to Fastly and our own Varnish caches that these pages should never be cached. This will prevent users from seeing other users' cached subscription data.
