## Tags and links

Uniquely define a list people can subscribe to. The criteria within are used to figure out whether an update is relevant subscribers in the list. Defined in [the docs for email-alert-api](https://docs.publishing.service.gov.uk/apps/email-alert-api/matching-content-to-subscriber-lists.html).

```
tags: { topics: { any: ["business-tax/vat"] } }
```

```
links: { topics: { any: ["1ddaaacb-0981-4abc-a532-a5111f2bea6b"] } }
```

## Legacy tags and links (yay)

These terms are also used by [the legacy `email_alert_signup` schema](https://github.com/alphagov/govuk-content-schemas/blob/master/formats/email_alert_signup.jsonnet). Note that the flat lists of base paths or Content IDs are interpreted as "any" in the above definition.

```
"tags": { "countries": ["foreign-travel-advice/canada"] }
```

```
"links": { "countries": ["f402b8de-2e99-4ff3-949f-31fe65796cae"] }
```
