Feature: Miscellaneous general settings unit tests

  @ubi9
  Scenario: Check the attributes of /home/default using stat
    When container is started with args
    | arg     | value              |
    | command | stat /home/default |
    Then available container log should contain Access: (0770/drwxrwx---)
