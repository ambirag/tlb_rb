#!/bin/sh
while [[ true ]] ;
do
    echo "hello out"
    echo "hello err" 1>&2
    sleep 1
done