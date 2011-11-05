Feature: Search

  As a interested person
  I want to search for an MP or Lords name
  So that I can see which committees they're on

  Scenario: Name exists
    Given an MP named "Alice" who's on the "Internet Committee"
    When I search for "Alice"
    Then I should see "Alice"
    And I should see "Internet Committee"
