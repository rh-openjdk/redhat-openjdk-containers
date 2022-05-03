#!/usr/bin/env bats
load common

@test "_add_maven_repo_profile: Should use the parameters provided and defaults for the rest" {
  run _add_maven_repo_profile $SETTINGS my_id http://my_url:8080
  assert_profile_xml "my_id-profile" "profile_default.xml"
  assert_active_profile "my_id-profile"
}

@test "_add_maven_repo_profile: Should use the parameters provided and defaults for the rest using prefix" {
  run _add_maven_repo_profile $SETTINGS my_id http://my_url:8080 "TEST_1"
  assert_profile_xml "my_id-profile" "profile_default.xml"
  assert_active_profile "my_id-profile"
}

@test "_add_maven_repo_profile: Should use all the parameters provided. No prefix" {
  REPO_LAYOUT="other_layout"
  REPO_RELEASES_ENABLED="false"
  REPO_RELEASES_UPDATE_POLICY="never"
  REPO_SNAPSHOTS_ENABLED="other_false"
  REPO_SNAPSHOTS_UPDATE_POLICY="other_never"
  REPO_SNAPSHOTS_CHECKSUM_POLICY="other_fail"

  run _add_maven_repo_profile $SETTINGS my_id http://my_url:8080
  assert_profile_xml "my_id-profile" "profile_all_vars.xml"
  assert_active_profile "my_id-profile"
}

@test "_add_maven_repo_profile: Should use all the parameters provided. Empty prefix" {
  REPO_LAYOUT="other_layout"
  REPO_RELEASES_ENABLED="false"
  REPO_RELEASES_UPDATE_POLICY="never"
  REPO_SNAPSHOTS_ENABLED="other_false"
  REPO_SNAPSHOTS_UPDATE_POLICY="other_never"
  REPO_SNAPSHOTS_CHECKSUM_POLICY="other_fail"

  run _add_maven_repo_profile $SETTINGS my_id http://my_url:8080
  assert_profile_xml "my_id-profile" "profile_all_vars.xml"
  assert_active_profile "my_id-profile"
}

@test "_add_maven_repo_profile: Should use all the parameters provided. Use prefix" {
  TEST_1_REPO_LAYOUT="other_layout"
  TEST_1_REPO_RELEASES_ENABLED="false"
  TEST_1_REPO_RELEASES_UPDATE_POLICY="never"
  TEST_1_REPO_SNAPSHOTS_ENABLED="other_false"
  TEST_1_REPO_SNAPSHOTS_UPDATE_POLICY="other_never"
  TEST_1_REPO_SNAPSHOTS_CHECKSUM_POLICY="other_fail"

  run _add_maven_repo_profile $SETTINGS my_id http://my_url:8080 "TEST_1"
  assert_profile_xml "my_id-profile" "profile_all_vars.xml"
  assert_active_profile "my_id-profile"
}
