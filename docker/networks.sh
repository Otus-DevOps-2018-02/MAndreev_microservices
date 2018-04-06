#!/bin/sh

# Just up and down docker networks 
var=$1

if [[ -z "$var" ]]
then
    docker network rm front_net back_net logging

else
    docker network create --driver=bridge --subnet=10.0.1.0/24 front_net
    docker network create --driver=bridge --subnet=10.0.2.0/24 back_net
    docker network create --driver=bridge --subnet=10.0.4.0/24 logging
fi
