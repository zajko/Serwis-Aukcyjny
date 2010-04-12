Feature: Manage Personal
  In order to fill my personal auctions list
  As an user
  I want create auctions and find them on the list

Scenario: User didnt add any auction
     Given I have active user agnieszka with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "agnieszka"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Then I follow "Moje aukcje"
    Then I follow "Zarządzaj aukcjami"
    Then I should see "Obecnie nie masz założonych żadnych aukcji."


  Scenario: User has more than zero auction
     Given I have active user agnieszka with password 1234
    When I go to "zaloguj sie"
    And I fill in "login" with "agnieszka"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Given I have SiteLink auction created by agnieszka with url www.onet.pl, pagerank 1, users daily 100, minimal price 200, minimal bidding diff 50
    Given I have SiteLink auction created by agnieszka with url www.o2.pl, pagerank 1, users daily 100, minimal price 200, minimal bidding diff 50
    Then I follow "Moje aukcje"
    Then I follow "Zarządzaj aukcjami"
    Then I should see "Pokaż aukcję"
    And I should see "http://www.onet.pl"
    And I should see "http://www.o2.pl"
    