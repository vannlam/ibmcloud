#!/usr/bin/env bash

sleep 60
sudo apt update -y
sudo apt upgrade -y
sudo apt install docker.io -y

docker pull hjosef13/ms-helloworld
docker run -p 80:8080 -d hjosef13/ms-helloworld 