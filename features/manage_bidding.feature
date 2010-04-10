Feature: Manage Bidding
  In order to bid
  As an user
  I want find an auction and make an offer

  Scenario: User makes a single offer
    Given I have active user agnieszka with password 1234
    Given I have user onet 
    When I go to "zaloguj sie"
    And I fill in "login" with "agnieszka"
    And I fill in "hasło" with "1234"
    And I press "loguj"
    Given I have SiteLink auction created by onet with url www.onet.pl, pagerank 1, users daily 1000 minimal price 300, minimal bidding diff 50 which starts at 2020-01-01 and ends 2020-01-15
    And I should see "Zaawansowane wyszukiwanie"
    Then I go to "Zaawansowane wyszukiwanie"
    And I should see "Pokaż 01-01-2020 00:01 15-01-2020 00:01 1 1000 0.0"
    When I follow "Pokaż"
    And I fill in "bid_offered_price" with "350"
    And I press "Licytuj"
    And I should see "350.0 zł od agnieszka"


Scenario: User calls of this offer
    GivenScenario User makes a single offer
    And I should see "agnieszka"



