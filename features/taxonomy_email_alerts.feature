Feature: Email alert signup
  As an interested person
  In order to get relevant notifications about content updates on GOV.UK
  I want to be able to sign up for email alerts about topics within the taxonomy

  Scenario: Signing up for email alerts about a topic
    Given a taxon in the middle of the taxonomy
    When i visit its signup page
    Then i can subscribe to the taxon or one of its children
    When i choose to subscribe to the taxon
    Then i see a confirmation page
    When i confirm
    Then my subscription is created
    And i am redirected to manage my subscriptions
