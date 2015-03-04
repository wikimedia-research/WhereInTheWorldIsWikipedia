library(shiny)
library(shinythemes)
country_data <- read.delim("./data/language_pageviews_per_country.tsv", as.is = TRUE, header = TRUE)

shinyUI(fluidPage(
  titlePanel(title = "", windowTitle = "Where in the world is Wikipedia?"),
  h2("Where in the world is Wikipedia?"),
  h4("Explore how traffic to Wikimedia projects is distributed around the globe."),
  sidebarLayout(
    sidebarPanel(
      selectInput("project",
                  "Project:",
                  choices = unique(country_data$project),
                  selected = "en.wikipedia.org"),
      downloadButton("downloadCountrySubset", "Download this subset"),
      h2("About this data"),
      p("This dataset contains the proportion of traffic to each public Wikimedia project, from each known country, with some caveats."),
      
      h3("Details"),
      p("Wikimedia properties receive 125,000 requests every second, 
        for myriad projects and from myriad countries. Too little of it is 
        made available to third-party researchers, due to an understandable and
        laudable desire to avoid compromising the privacy of our users.
        So instead, we analyse it ourselves."),
      p("Part of the analysis we perform is high-level geolocation:
         investigating the idea that where our traffic comes from has
         implications for systemic bias and reach. This is /also/ work that third-parties
         do really well. We've decided to release a high-level dataset of
         geodata, to assist these researchers in their work. This tool
         represents a simple attempt to visualise it and make it explorable."),
      h3("Data preparation"),
      HTML("<p>This dataset represents an aggregate of 1:1000 sampled pageviews from the entirety of 2014. The pageviews definition applied
        was the Foundation's
        <a href = 'https://github.com/wikimedia/analytics-refinery-source/blob/master/refinery-core/src/main/java/org/wikimedia/analytics/refinery/core/Pageview.java'>
        new pageviews definition</a>; additionally, spiders and similar automata were filtered out with Tobie's <a href = 'http://www.uaparser.org/'>ua-parser</a>.
        Geolocation was then performed using MaxMind's <a href = 'http://dev.maxmind.com/geoip/'> geolocation products</a>.</p>"),
      p("There are no privacy implications that we could identify; The data comes from 1:1000 sampled logs, is proportionate rather than raw, and aggregates any nations with <1% of a project's pageviews
        under 'Other'."),
      h3("Reusing this data"),
      HTML("The data is released into the public domain under the
           <a href = 'https://creativecommons.org/publicdomain/zero/1.0/'>CC-0 public domain dedication</a>, and can be freely reused
           by all and sundry. Iff you decide you want to credit it to people, though, the appropriate citation is:
           <br/><br/>
           <blockquote>Keyes, Oliver (2015) <em><a href = 'http://dx.doi.org/10.6084/m9.figshare.1317408'>Geographic Distribution of Wikimedia Traffic</a></em></blockquote>
           "),
      downloadButton("downloadAll", "Download all data")
    ),

    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("country_distribution"),
      h2(textOutput("project_output")),
      dataTableOutput("table")
    )
  ), theme = shinytheme("cosmo")
))
