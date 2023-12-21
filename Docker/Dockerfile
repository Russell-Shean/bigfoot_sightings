# This imports the base image which comes from the rocker project
# they've already made a docker image for base R
FROM rocker/r-base:latest

# This adds a tag to the image's meta data, it specifies the maintainer as me
LABEL maintainer="Russ <russell.shean@doh.wa.gov>"

# This executes some linux commands to update all packages and then install packages
# Sudo is a mode with privliges 
# everything after sudo is a linux dependency

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libudunits2-dev \
    libsecret-1-0 \
    proj-bin \
    libpq-dev \
    gdal-bin \
    libsodium-dev \
    libgdal-dev \
    libssh2-1-dev \
    && rm -rf /var/lib/apt/lists/*

# This runs the install.r command which install R packages
# So this is a list of r packages that will be installed   
RUN install.r blastula data.table dplyr DT forcats ggrepel keyring leaflet lubridate mapview RColorBrewer readr sf shiny shinycssloaders shinyjs shinythemes stringr tidyr shinyWidgets pacman

# This sets the port and repeats it back
RUN echo "local(options(shiny.port = 6599, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

# create a new folder inside the container
RUN mkdir /home/analysis

# specifiy the working directory on the machine that's being used to create the container
WORKDIR /home/russ/Documents/r_projects/docker_shiny

# copy the shiny app folder to the container
COPY bigfoot_shiny_demo-main /home/analysis/bigfoot_shiny_demo-main

# No 100% sure what this does, the tutorial didn't really fully explain everything : https://hosting.analythium.io/dockerizing-shiny-applications/, 
# also really bad: https://hosting.analythium.io/dockerized-shiny-apps-with-dependencies/, 

RUN addgroup --system app \
    && adduser --system --ingroup app app
    

# COPY bigfoot_shiny_demo-main .
# RUN chown app:app -R /home/app
USER app
EXPOSE 6599
CMD ["R", "-e", "shiny::runApp('/home/analysis/bigfoot_shiny_demo-main')"]


