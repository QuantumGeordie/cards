Feature: Login stuff

  Scenario: Register a new user
    Given I register a new user
    Then I should see 'Welcome'
    Then I logout
    Then I should see 'logged out'
