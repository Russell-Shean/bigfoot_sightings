# Bigfoot Shiny Demo
This is a demonstration that shows how R's web development framework `shiny` can be used to make interactive dashboards and websites.  

A publicly available <a href="https://www.bfro.net/GDB">database of bigfoot sightings</a> was used for this project.

Here are some screenshots of what this demonstration app looks like. Scroll past the pictures for instructions to run a live version of this app and read more about how this project is organizsed! 

<img src="https://user-images.githubusercontent.com/119683040/230192238-c480caf0-336f-4043-8e66-7f5b8f73180b.png">
<img src="https://user-images.githubusercontent.com/119683040/230192825-1937b50d-9588-4882-9713-2b8b85a0115d.png">
<img src="https://user-images.githubusercontent.com/119683040/230193191-bb88429a-ee6d-49f0-8a46-a6ebde0f2d06.png">



# How to run a live version of this app
1. Clone this repo as an R Project in Rstudio
2. Open the `app.R` file in Rstudio and click on the run app button:

  <p align="center">          
  <img src="https://user-images.githubusercontent.com/119683040/215877771-f2573a55-cd9d-421e-84ed-7b21aeae1ae9.png">             
  </p>  
  
 
# File organization        
The `app.R` file is divided into three main parts:
1. <strong>Pre-processing</strong>: This section includes some filtering and data aggregation. It also sets file paths, shiny port numbers, and plot and map aestetics and themes.       
2. <strong>User Interface (UI)</strong>: This section specifies the layout and look of the webpage that users see when they interact with the shiny. The html elements for inputs and ouputs are defined here. (Their behavior is defined later in the server section).       
3. <strong>Server</strong>: This section is where the backend behavior of the app is defined. It also includes a lot of the aesthetic settings for r objects such as maps, plots, and tables. This is where <em>almost</em> all the reactive and interactive programing behavior is defined. 

The `App.R` file executes/loads serveral external files including      
1. HTML, CSS, and javascript files stored in the `www/` folder         

Raw HTML, CSS and Javascript can be included directly in shiny apps, here are some references          
- css: https://shiny.rstudio.com/articles/css.html         
- javascript: https://shiny.rstudio.com/articles/packaging-javascript.html            
- html: https://stackoverflow.com/a/24876951/16502170       

#### Inline comments in HTML, CSS, and Javascript       
```
/* CSS comments look like this */
<!-- HTML comments look like this -->
// Javascript comments look like this or like CSS comments

```

2. R scripts that define functions and pre process data stored in the `r_scripts` folder

# Selected frameworks and packages used
- `Shiny`  is an R package for creating interactive webpages and dashboards: https://shiny.rstudio.com/
- `ggplot2` is an R package for creating graphics: https://r-graph-gallery.com/ggplot2-package.html
- `DT` is an R package that interfaces to the data.tables javascript package for displaying interactive tables: https://rstudio.github.io/DT/
- `leaflet` is an R package that interfaces to the leaflet javascript package for displaying interactive maps: https://rstudio.github.io/leaflet/
- `sf` is an R package for manipulating spatial data: https://r-spatial.github.io/sf/
- `CSS and HTML` are for definining and customizing the user interface beyond shiny default options: https://www.w3schools.com/html/html_css.asp


 

## Shiny Resources
### Books
- <a href="https://mastering-shiny.org/"><em>Mastering Shiny</em></a> by Hadley Wickham: An online book that gives an intro to Shiny  
- Book about designing user interfaces: https://unleash-shiny.rinterface.com/index.html           
- Book about engineering for production: https://engineering-shiny.org/index.html  
- Book about how to use javascript with R (focus on htmlwigits and shiny): https://book.javascript-for-r.com/  

### Shiny Gallery

A great set of example shinies with source code: https://shiny.rstudio.com/gallery/  



