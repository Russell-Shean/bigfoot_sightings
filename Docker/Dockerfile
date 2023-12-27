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
RUN install.r dplyr DT lubridate RColorBrewer sf shiny shinycssloaders shinyjs shinyWidgets pacman

# Make sure we're getting the latest version of leaflet...
RUN R -e "install.packages('leaflet', dependencies = TRUE, repos = c(CRAN = 'https://cloud.r-project.org'))"

RUN R -e "install.packages('leaflet.providers', dependencies = TRUE, repos = c(CRAN = 'https://cloud.r-project.org'))"

# This sets the port and writes it to an rprofile file in the container
RUN echo "local(options(shiny.port = 6599, shiny.host = '0.0.0.0'))" > /usr/lib/R/etc/Rprofile.site

# create a new folder inside the container
RUN mkdir /home/analysis

# specifiy the working directory on the machine that's being used to create the container
WORKDIR /home/analysis/

# copy the shiny app folder to the container
COPY data data/ 
COPY R R/
COPY www www/ 
COPY app.R /home/analysis/

#  https://hosting.analythium.io/dockerizing-shiny-applications/, 
#  https://hosting.analythium.io/dockerized-shiny-apps-with-dependencies/, 

RUN addgroup --system app \
    && adduser --system --ingroup app app
    

# COPY bigfoot_shiny_demo-main .
# RUN chown app:app -R /home/app
USER app
EXPOSE 6599
CMD ["R", "-e", "shiny::runApp('/home/analysis/')"]


