Feature: Manage User Session
  In order to login
  As an user
  I want to login

  Scenario: Active user login
    Given I have active user jarek with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "jarek"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I should see "Zalogowano poprawnie"

  Scenario: Not active user login
    Given I have no active user jarek with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "jarek"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I should see "Zaktywuj konto!"

  Scenario: Banned user login
    Given I have banned user jarek with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "jarek"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I should see "Zostałeś zablokowany!"

  Scenario: User login
    Given I have superuser jarek with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "jarek"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I should see "Zalogowano poprawnie"

  Scenario: User login
    Given I have admin jarek with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "jarek"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I should see "Zalogowano poprawnie"

  Scenario: User logout
    Given I have active user jarek with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "jarek"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I should see "Zalogowano poprawnie"

    When I go to "wyloguj sie"
    Then I should see "Wylogowano poprawnie"