# Bigfoot Shiny Demo
---------------------------------------------------------------------
Here's a link to a live version of the app:         
https://russellshean.shinyapps.io/bigfoot_sightings3/
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
The `app.R` file is divided into three main parts:
1. <strong>Pre-processing</strong>: This section includes some filtering and data aggregation. It also sets file paths, shiny port numbers, and plot and map aestetics and themes.       
2. <strong>User Interface (UI)</strong>: This section specifies the layout and look of the webpage that users see when they interact with the shiny. The html elements for inputs and ouputs are defined here. (Their behavior is defined later in the server section).       
3. <strong>Server</strong>: This section is where the backend behavior of the app is defined. It also includes a lot of the aesthetic settings for r objects such as maps, plots, and tables. This is where <em>almost</em> all the reactive and interactive programing behavior is defined. 

The `App.R` file executes/loads serveral external files including      
1. HTML, CSS, and javascript files stored in the `www/` folder         

2. R scripts that define functions and pre process data stored in the `r_scripts` folder



