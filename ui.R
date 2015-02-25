library(shiny)
library(shinythemes)

shinyUI(fluidPage(
  titlePanel(strong("Where in the world is Wikipedia?")),
  sidebarLayout(
    sidebarPanel(
      selectInput("project",
                  "Project:",
                  choices = unique(country_data$project)),
      downloadButton("downloadCountrySubset", "Download this subset"),
      h2("About this data"),
      p("This dataset contains the proportion of traffic to each public Wikimedia project, from each known country, with some caveats."),
      
      h3("Details"),
      p("125,000 requests come to Wikimedia properties every second, for myriad projects and from myriad countries. Far too little
        of it is made available to third-party researchers, due to an understandable and laudable desire to avoid compromising the
        privacy of our users. Instead, we analyse it ourselves.
        
        Part of the analysis we perform - and one of the things third-party researchers do great work on! - is high-level geolocation.
        We do work geolocating requests down to the country-level, and third-party researchers (some of whom are linked below) do fantastic
        research investigating the implications of where our traffic comes from - both due to its implications around systemic bias and
        due to"),
      h3("Privacy implications")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("country_distribution"),
      h2(textOutput("project_output")),
      dataTableOutput("table")
    )
  ), theme = shinytheme("cosmo")
))
