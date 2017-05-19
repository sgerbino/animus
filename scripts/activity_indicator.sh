#!/bin/bash

message=$1
command=$2
result_message=$3

$command >/dev/null 2>&1 &
pid=$! # Process Id of the previous running command

spin='-\|/'

i=0
while kill -0 $pid 2>/dev/null
do
  i=$(( (i+1) %4 ))
  printf "\r-- ${message} ${spin:$i:1}"
  sleep .1
done

printf "\r\033[K-- ${result_message}\r\n"
