#!/bin/bash

# this is a smart hack strictly meant for developer convinience, not for CI. -janmejay

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

sep() {
    in_red "-----------------------------------------------------------------"
    echo
}

function in_red {
    tput sgr0
    tput setaf 1; 
    tput setab 7; 
    echo -n $1; 
    tput sgr0
}

function show_running_with {
    echo -e "\n"
    sep
    in_red "|"
    echo -n " "
    tput setaf 4
    echo -n "Running tests with: "
    tput bold; 
    tput setaf 0
    ruby --version
    sep
    echo 
}

run_tests_with() {
    rvm use $1
    show_running_with  
    rake test
}

run_tests_with ruby-1.8.7-p334@tlb

run_tests_with ruby-1.9.2-head@tlb

run_tests_with jruby-1.6.0@tlb


