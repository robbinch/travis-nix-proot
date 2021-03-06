# travis-nix-proot

`travis-nix-proot` is a helper script for testing with **Nix**
(<https://github.com/NixOS/nixpkgs>) on **Travis CI** without sudo. It uses
**proot** (<http://proot.me>) under the hood to fake root access. This allows
Travis containers to be used to full effect.

## Features
* Create a new Nix installation environment in one command
* Run commands that require super-user privileges in the Nix environment
* Use Travis caching for the Nix environment so subsequent builds run faster

## Example .travis.yml
The following is a sample `.travis.yml` for a project that uses `BATS`
(<https://github.com/sstephenson/bats>) for testing. It:

1. Creates a Nix environment (from cache if possible)
2. Installs `BATS` in the Nix environment
3. Runs `BATS` on the project's testsuite (in the Nix environment)
4. Prunes the Nix store and exports it to cache

```yaml
# sample .travis.yml for use with travis-nix-proot
sudo: false
language: c

install:
  # Install travis-nix-proot into $HOME/.travis-nix-proot directory
  - bash <(curl -sSL https://github.com/robbinch/travis-nix-proot/raw/master/install)

  # Setup PATH
  - export PATH=$HOME/.travis-nix-proot/bin:$PATH

  # Setup Nix environment (from cache if possible) and nixpkgs-unstable channel
  # Among the directories created are:
  #  - $HOME/travis-nix-proot.rootfs, this contains /nix, /etc and other
  #    directories used by Nix but not necessary for caching
  #  - $HOME/travis-nix-proot.cache, this is the only directory Travis needs to
  #    cache and contains /nix/store, profiles, etc
  - travis-nix-proot setup

script:
  # Run commands under the Nix environment
  # (eg, to install BATS <https://github.com/sstephenson/bats>)
  - travis-nix-proot nix-env -i bats

  # Run bats command in Nix environment on this project's tests
  - travis-nix-proot bats test.sh
  # If test.sh is executable and starts with `#!/usr/bin/env bats`, it can be
  # started directly with:
  # - travis-nix-proot test.sh

before_cache:
  # Run nix-collect-garbage in Nix environment to prune /nix/store
  - travis-nix-proot gc

  # Dump Nix DB to cache
  - travis-nix-proot dump-db

cache:
  directories:
    # Use caching to skip rebuilding of Nix environment on next run
    - $HOME/travis-nix-proot.cache
```
