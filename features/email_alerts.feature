Feature: Email alert signup
  As an interested person
  In order to get up to date notifications about content on GOV.UK
  I want to be able to sign up for email alerts for relevant content

  @mock-email-alert-api
  Scenario: signing up for email alerts for a page
    Given a content item exists for an email alert signup page
    When I access the email signup page
    Then I see the email signup page
    When I sign up to the email alerts
    Then my subscription should be registered

  Scenario: Visit a government email alert page
    Given a government email alert page exists
    Then I can see the government header
