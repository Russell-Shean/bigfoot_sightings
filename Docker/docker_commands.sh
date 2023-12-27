#! /usr/bin/bash

# update all packages
apt-get update

# install packages if they're missing
# most of these are dependencies for spatial packages
apt-get install libudunits2-dev
apt-get install -y libsecret-1-0
apt-get install proj-bin
apt install libpq-dev gdal-bin libgdal-dev


# This assumes you are starting in the bigfoot_sightings/Docker folder
cd ..

sudo docker build --file ./Docker/Dockerfile -t bigfoot-shiny .

# To run the image after it's built
# sudo docker run  -p 6599:6599 bigfoot-shiny:latest

# login to Docker hub
sudo docker login -u rshean

# create a new repository on docker hub and connect to local image
sudo docker tag bigfoot-shiny  rshean/bigfoot-shiny

# push to docker hub
sudo docker push rshean/bigfoot-shiny

# to pull from docker hub
# sudo docker run  -p 6599:6599 rshean/shiny-test:latest
