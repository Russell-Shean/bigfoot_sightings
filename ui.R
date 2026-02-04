# User interface (UI)-----------------------------------------------
#
# This defines the User interface (UI)
# This is what defines the look of the webpage, it defines inputs, things to display
# etc and where they appear on the page
# raw HTML and CSS can be integrated into the user interface to customize the look of the webpage
# beyond the defaults that Shiny has implemented

# load data and settings
source("R/settings.R")

# Load modules
module_files <- list.files("R/modules", pattern = "\\.R$", recursive = TRUE, full.names = TRUE)
sapply(module_files, source)


# Navbarpage defines a page with multiple tabs
ui <- navbarPage(
  
  # This is the title of the overall webpage:
  "BIGFOOT SIGHTINGS IN WASHINGTON STATE DASHBOARD",
  
  # This enables the shinyjs library inside the app
  # I used this for the email server
  useShinyjs(),
  
  ## CSS style tags---------------------------------------------------------------
  # here are a bunch of Cascading Style Sheets (CSS) style for different elements
  
  # Here's how to load an external css style sheet
  # it needs to be stored in a sub-directory named www/
  # https://shiny.rstudio.com/articles/css.html
  
  # /* CSS comments look like this */
  tags$link(rel = "stylesheet", type = "text/css", href = "css/bigfoot_dashboard_styles.css"),
  
  ## Pages
  page1_UI(),
  page2_UI(),
  page3_UI(),

  ## Fourth page -----------------------------------------------------------------
  
  # This page is entirely text and links (ie standard html sort of things
  # without any r objects), for simplicity of css formating, the section is
  # written entirely in html using Html tags created by r
  # It is stored in the app's www/ directory
  
  tabPanel("Data Notes",
           
           # <!-- HTML comments look like this -->
           includeHTML("www/html/page4.html")
           
  ),
  
  ## Website footer -------------------------------------------------------------
  footer = includeHTML("www/html/site_footer.html"),
  
  # these scripts are run at the end
  # bc they need to run AFTER the page has finished rendered
  # one script removes weird random dots that appear
  # and the other moves the location of the time stamp
  tags$script(src="move_remove_functions.js"),

)



