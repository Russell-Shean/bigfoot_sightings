# Bigfoot Shiny Demo
---------------------------------------------------------------------
Here's a link to a live version of the app:         
https://russellshean.shinyapps.io/bigfoot_sightings/
--------------------------------------------------------------------
This is a demonstration that shows how R's web development framework `shiny` can be used to make interactive dashboards and websites.  

A publicly available <a href="https://www.bfro.net/GDB">database of bigfoot sightings</a> was used for this project.

Here are some screenshots of what this demonstration app looks like. Scroll past the pictures for instructions to run a live version of this app and read more about how this project is organized! 

<img src="https://user-images.githubusercontent.com/119683040/230192238-c480caf0-336f-4043-8e66-7f5b8f73180b.png">
<img src="https://user-images.githubusercontent.com/119683040/230192825-1937b50d-9588-4882-9713-2b8b85a0115d.png">
<img src="https://user-images.githubusercontent.com/119683040/230193191-bb88429a-ee6d-49f0-8a46-a6ebde0f2d06.png">



# How to run a live version of this app
1. Clone this repo as an R Project in Rstudio
2. Open the `app.R` file in Rstudio and click on the run app button:

  <p align="center">          
  <img src="https://user-images.githubusercontent.com/119683040/215877771-f2573a55-cd9d-421e-84ed-7b21aeae1ae9.png">             
  </p>  

The app can also be run as a docker container
```
sudo docker run  -p 6599:6599 rshean/bigfoot-shiny:latest
```
If you don't have docker on your computer, you can also run the container on this online sandbox: https://labs.play-with-docker.com/ 
 
# File organization        
1. The app is separated into modules stored in the `R/modules/` folder. The modules are further divided into folders for each page of the app. Settings and functions are defined outside of the modules inside of the `R/` folder.

2. The app also executes/loads HTML, CSS, and javascript files stored in the `www/` folder.         

2. An R script that pre-processes the data is stored in the `R/data_cleaning/` folder.

3. Python scripts for scraping the data are stored in the `python/` folder.



