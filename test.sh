#!/usr/bin/env bats

@test "can run nix-env -q" {
  nix-env -q
  [ "$?" -eq 0 ]
}

@test "can run nix-env -qa --json" {
  nix-env -qa --json
  [ "$?" -eq 0 ]
}

@test "can install BATS" {
  run nix-env -q
  echo "$output" | grep bats
  [ "$?" -eq 0 ]
}
