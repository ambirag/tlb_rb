#!/bin/bash

source execution_helper.sh

run_command_with ruby-1.8.7-p334@tlb rake test

run_command_with ruby-1.9.2-head@tlb rake test

run_command_with jruby-1.6.0@tlb rake test


