#!/bin/sh

# Usage:
#   Invoke shell runner with arguments for the following
#    - relative or absolute path to beaker hosts file to use
#    - SHA of puppet-agent package to install. These can be
#      found at http://builds.puppetlabs.lan/puppet-agent/
#
# Example:
#   sh aio_test_runner.sh config/nodes/win2012r2-rubyx64.yaml 1.1.1

export BUNDLE_PATH=.bundle/gems
export BUNDLE_BIN=.bundle/bin

# SHA is puppet-agent package version
#export SHA=1.1.0
#export CONFIG=config/nodes/redhat-7-x86_64.yaml
export SHA=$2
export CONFIG=$1
export TESTS=tests

#rm -rf .bundle log junit
bundle install

bundle exec rake ci:test:aio
