Feature: Manage advanced searcher
  In order to find to a specific auction
  As an user
  I want specify searching criteria and find all matches

  Scenario: 
    Given I have active user aga with password 1234
    Given I have SiteLink auction created by aga with url www.onet.pl, pagerank 1, users daily 100 minimal price 200, minimal bidding diff 50 which starts at 2020-01-01 and ends 2020-01-15
    