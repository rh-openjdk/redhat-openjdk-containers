#!/usr/bin/env bats
load common

@test "_add_maven_repo_server: Should set only the ID." {
  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server.xml"
}

@test "_add_maven_repo_server: Should not set the username and password. Missing username" {
  REPO_PASSWORD="thefrog"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server.xml"
}

@test "_add_maven_repo_server: Should not set the username and password. Missing password" {
  REPO_USERNAME="kermit"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server.xml"
}

@test "_add_maven_repo_server: Should set the username and password." {
  REPO_USERNAME="kermit"
  REPO_PASSWORD="thefrog"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server_with_username.xml"
}

@test "_add_maven_repo_server: Should not set the private key and passphrase. Missing private key" {
  REPO_PASSPHRASE="mypassphrase"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server.xml"
}

@test "_add_maven_repo_server: Should not set the private key and passphrase. Missing passphrase" {
  REPO_PRIVATE_KEY="myprivatekey"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server.xml"
}

@test "_add_maven_repo_server: Should set the private key and passphrase" {
  REPO_PRIVATE_KEY="myprivatekey"
  REPO_PASSPHRASE="mypassphrase"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server_with_privatekey.xml"
}

@test "_add_maven_repo_server: Should use all the parameters provided. No prefix" {
  REPO_USERNAME="kermit"
  REPO_PASSWORD="thefrog"
  REPO_PRIVATE_KEY="myprivatekey"
  REPO_PASSPHRASE="mypassphrase"

  run _add_maven_repo_server $SETTINGS "my_id"
  assert_server_xml "my_id" "server_with_all.xml"
}

@test "_add_maven_repo_server: Should use all the parameters provided. Empty prefix" {
  REPO_USERNAME="kermit"
  REPO_PASSWORD="thefrog"
  REPO_PRIVATE_KEY="myprivatekey"
  REPO_PASSPHRASE="mypassphrase"

  run _add_maven_repo_server $SETTINGS "my_id" ""
  assert_server_xml "my_id" "server_with_all.xml"
}

@test "_add_maven_repo_server: Should use all the parameters provided. Use prefix" {
  TEST_REPO_USERNAME="kermit"
  TEST_REPO_PASSWORD="thefrog"
  TEST_REPO_PRIVATE_KEY="myprivatekey"
  TEST_REPO_PASSPHRASE="mypassphrase"

  run _add_maven_repo_server $SETTINGS "my_id" "TEST"
  assert_server_xml "my_id" "server_with_all.xml"
}
