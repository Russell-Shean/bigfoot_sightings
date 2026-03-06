# R/modules/contact_form_server.R
contact_form_server <- function(id) {
  moduleServer(id, function(input, output, session) {

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
    
    
  })
}
