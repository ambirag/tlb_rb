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
    run_command_with $conf gem install *.gem
    for dir in $projects; do 
        echo "-----" 
        echo "######################### running $dir -- using $conf #########################"
        (cd  $dir && run_command_with $conf ./run_balanced.sh no-verbosity)
        echo "-----"
    done
done
