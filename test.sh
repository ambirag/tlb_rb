#!/bin/bash

source execution_helper.sh

ignore_187=${ignore_187:-false}

if [ $ignore_187 != 'true' ]; then
    run_command_with ruby-1.8.7-head@tlb rake test
fi

run_command_with ruby-1.9.2-head@tlb rake test

run_command_with jruby-head@tlb rake test


