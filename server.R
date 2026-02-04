server <- function(input, output, session) {

# Page 1 -----------------------------------------------------------------------
county_sightings_map <- county_sightings_map_server("county_sightings_map")
county_sightings_table <- county_sightings_table_server("county_sightings_table")

sighting_counts_plot_server("sighting_counts_plot")
missing_counties_note <- missing_counties_note_server("missing_counties_note")




sighting_counts_plot_server(
  "sighting_counts_plot",
  county_choices = reactive(input$county_choices),
  startdate = reactive(input$startdate)
)

sighting_counts_plot_toolTip <- sighting_counts_plot_toolTip_server("sighting_counts_plot_toolTip",
                                                                    county_choices = reactive(input$county_choices),
                                                                    plot_hover    = reactive({
                                                                      input[["sighting_counts_plot-plot_hover"]]  
                                                                    })
                                                                    )




# Page 2 -----------------------------------------------------------------------

report_class_plot <- report_class_plot_server("report_class_plot")

report_class_plot_toolTip <- report_class_plot_toolTip_server("report_class_plot_toolTip",
                                                              plot_hover    = reactive({
                                                                input[["report_class_plot-plot_hover"]]  
                                                              }))


season_table <- season_table_server("season_table")


weekday_plot <- weekday_plot_server("weekday_plot")
weekday_plot_toolTip <- weekday_plot_toolTip_server("weekday_plot_toolTip")



# Page 3 -----------------------------------------------------------------------


filtered_feet <- filtering_criteria_server("filtering_criteria")





reactive_labels <- reactive_labels_server("reactive_labels", filtered_feet)
bigfoots_maps <- bigfoots_maps_server("bigfoots_maps", filtered_feet, reactive_labels)

## contact form part of the server -----------------------------------------------
# This was adapted from this stack overflow answer:
# https://stackoverflow.com/a/59895346

disable("send")



### Popup Dialouge box ---------------------------------------------------------------
# create a function to display a popup modal box

make_email_sent_modal <-function(failed = FALSE) {
  
  modalDialog(
    title="",
    
    fluidRow(column(width = 12,
                    align = "left",
                    "Thanks for contacting us!")),
    br(),
    easyClose = FALSE,
    footer = fluidRow(column = 12, align="left",
                      modalButton("OK", icon = icon("fas fa-check-circle"))
    )
  )
}


# this uses the shinyjs disable function, to disable the send button,
# the message the user submits and the users email untl some condition is met

observeEvent( input$send, {
  
  shinyjs::disable("send")
  
  shinyjs::disable("users_message")
  shinyjs::disable("users_email")
  
  
  
  # This uses shinyjs to enable the send button, the input boxes and the popup
  shinyjs::enable("send")
  
  shinyjs::enable("users_message")
  shinyjs::enable("users_email")
  showModal(make_email_sent_modal())
  
  # This specifies placeholder values to put in input boxes
  updateTextInput(session,
                  "users_message",
                  value="",
                  placeholder = "Tell us what you think!")
  
  
  updateTextInput(session,
                  "users_email",
                  value="",
                  placeholder = "")
  
  
})



##### enable the option to click to send

# These are two reactive values flags
# used to determine when to enable parts of the email sned function

message_okay <- reactiveValues(sendable = FALSE)
email_okay <- reactiveValues(sendable2 = FALSE)


# If something has been put in the message box
# change first flag to true
observeEvent(input$users_message,{
  
  if(input$users_message != ""){
    isolate(message_okay$sendable <- TRUE)
  }
  else{
    isolate(message_okay$sendable <- FALSE)
  }
})

## If the text put in the email box
## contains a little mouse set the second flag to true

observeEvent(input$users_email, {
  
  if(grepl("@", input$users_email) ){
    isolate(email_okay$sendable2 <- TRUE)
  }
  else{
    isolate(email_okay$sendable2 <- FALSE)
  }
})

# If both the message and the email are okay
# enable the send button
observe({
  
  if(email_okay$sendable2 & message_okay$sendable){
    shinyjs::enable("send")
  }
  else{
    shinyjs::disable("send")
  }
})




## Missing text part of the server---------------------------------------------
# render the text displayed below graphics that tells the viewer how many
# values are missing

output$report_missing <- renderText({ report_missing })

output$time_missing <- renderText({ season_missing })

output$weekday_missing <- renderText({  weekday_missing })




}


