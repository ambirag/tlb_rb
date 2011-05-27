#!/bin/bash

source execution_helper.sh

projects="
../sample_projects/test-unit_example
../sample_projects/cucumber_example
../sample_projects/rspec2_example
../sample_projects/rspec1_example
"

configurations="
ruby-1.9.2-head@test-tlb
jruby-head@test-tlb
ruby-1.8.7-p334@test-tlb
"

for conf in $configurations; do 
    rvm use $conf
    negate_gem_named=''
    ruby --version | grep -q '1.9'
    if [[ $? -eq 0 ]]; then
        negate_gem_named='18'
    else
        negate_gem_named='19'
    fi 
    ls *.gem | grep -v $negate_gem_named | xargs gem install

    for dir in $projects; do 
        echo "-----" 
        echo "######################### running $dir -- using $conf #########################"
        (cd  $dir && run_command_with $conf ./run_balanced.sh no-verbosity)
        echo "-----"
    done
done
