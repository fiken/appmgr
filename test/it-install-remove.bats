#!/usr/bin/env bats
# vim: set filetype=sh:

load utils

@test "install remove roundtrip" {
  mkzip "app-a"
  install_artifact

  describe "Installing app"
  app init -d my-app/prod maven -r $REPO_URL org.example:app-a:1.0-SNAPSHOT; echo_lines
  eq '$status' 0

  is_directory "my-app/prod/.app"
  cd my-app/prod

  describe "Setting property"
  app conf set env.TEST_PROPERTY awesome; echo_lines
  eq '$status' 0

  describe "Starting"
  app start; echo_lines
  eq '$status' 0
  can_read .app/pid

  describe "Stopping"
  app stop
  eq '$status' 0
  echo_lines
  can_not_read .app/pid

  can_read "logs/app-a.log"
  can_read "logs/app-a.env"
  can_read "current/foo.conf"

  [ "`cat logs/app-a.env`" = "TEST_PROPERTY=awesome" ]
  [ "`cat current/foo.conf`" = "hello" ]

  # TODO: Remove the version
}
