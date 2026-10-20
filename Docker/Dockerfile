# This imports the base image which comes from the rocker project
# they've already made a docker image for base R
FROM rocker/geospatial:latest

# This adds a tag to the image's meta data, it specifies the maintainer as me
LABEL maintainer="Russ <russshean@gmail.com>"


# This runs the install.r command which install R packages
# So this is a list of r packages that will be installed   
RUN install2.r --error --skipinstalled \
    DT \
    leaflet.providers \
    RColorBrewer \
    shiny \
    shinycssloaders \
    shinyjs \
    shinyWidgets

# Make sure we're getting the latest version of leaflet...
#RUN R -e "install.packages(c('leaflet', 'leaflet.providers'), dependencies = TRUE, repos = c(CRAN = 'https://cloud.r-project.org'))"


# This sets the port and writes it to an rprofile file in the container
RUN mkdir -p /usr/local/lib/R/etc \
    && echo "local(options(shiny.port = 6599, shiny.host = '0.0.0.0'))" > /usr/local/lib/R/etc/Rprofile.site


# create a new folder inside the container
RUN mkdir /home/analysis

# specifiy the working directory on the machine that's being used to create the container
WORKDIR /home/analysis/

# Create a system user and group, then give them ownership of the app directory
RUN addgroup --system app \
    && adduser --system --ingroup app app\
    && chown -R app:app /home/analysis


# copy the shiny app folder to the container
COPY data data/ 
COPY R R/
COPY www www/ 
COPY ui.R /home/analysis/
COPY server.R /home/analysis/

#  https://hosting.analythium.io/dockerizing-shiny-applications/, 
#  https://hosting.analythium.io/dockerized-shiny-apps-with-dependencies/,


    

# COPY bigfoot_shiny_demo-main .
# RUN chown app:app -R /home/app
USER app
EXPOSE 6599

CMD ["R", "-e", "shiny::runApp('/home/analysis/')"]


