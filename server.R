library(shiny)
library(ggplot2)
library(RColorBrewer)
library(scales)
library(grid)
library(maptools) #Mapping dependency
library(rgeos) #Mapping dependency
library(rworldmap) #SpatialPolygonDataFrame creation.
library(RColorBrewer) #Colour scale definitions.
library(gridExtra) #Multi-mapping
library(mapproj) #mollweide projection

#Plot for per-project data
per_project_plot <- function(data, project){
  names(data) <- c("country","count")
  cdm <- joinCountryData2Map(data, joinCode="ISO2", nameJoinColumn="country", suggestForFailedCodes=TRUE)
  missingCountries <- unique(cdm$ISO_A2[!(cdm$ISO_A2 %in% data$country)])
  if(length(missingCountries) >= 1){
    data <- rbind(data, data.frame(country=missingCountries, count=0))
  }
  cdm <- joinCountryData2Map(data, joinCode="ISO2", nameJoinColumn="country", suggestForFailedCodes=TRUE)
  values <- as.data.frame(cdm[,c("count", "country")])
  names(values) <- c("count", "id")
  values <- unique(values)
  fortified_polygons <- fortify(cdm, region = "country")
  palette <- brewer.pal("Greys", n=9)
  color.background = palette[2]
  color.grid.major = palette[3]
  color.axis.text = palette[6]
  color.axis.title = palette[7]
  color.title = palette[9]
  ggplot(values) + 
    geom_map(aes(fill = count, map_id = id),
             map = fortified_polygons) +
    expand_limits(x = fortified_polygons$long,
                  y = fortified_polygons$lat) +
    coord_equal() + 
    coord_map(projection="mollweide") +
    labs(title = paste(project, "pageviews, by country\n(log-scaled)"),
         x = "", y = "") +
    scale_fill_gradientn(colours=brewer.pal(9, "Blues")[3:8], name = "Percentage of pageviews",
                         trans = log10_trans(),
                         guide = guide_colourbar(title.position = "top", label.position="bottom")) +
    theme(plot.title = element_text(size=14, color = color.axis.title, face = "bold")) +
    theme(axis.text=element_blank(), axis.ticks=element_blank()) +
    theme(legend.position = "bottom")
    
}

#Load and format dataset
country_data <- read.delim("./data/language_pageviews_per_country.tsv", as.is = TRUE, header = TRUE)

shinyServer(function(input, output, session) {
  output$downloadAll <- downloadHandler(
    filename = "all_country_data.tsv",
    content = function(file){
      write.table(country_data, file, row.names = FALSE, sep = "\t", quote = TRUE)
    }
  )
    output$downloadCountrySubset <- downloadHandler(
    filename = "country-subset.tsv",
    content = function(file){
      write.table(country_data[country_data$project == input$project,], file, row.names = FALSE, sep = "\t", quote = TRUE)
    }
  )
  
  height_to_use <- reactive({
    height <- session$clientData$output_country_distribution_height
    if(is.null(height)){
      "auto"
    } else {
      height*1.5
    }
  })
  
  output$country_distribution <- renderPlot({
    per_project_plot(country_data[country_data$project == input$project,c("country_iso","pageviews_percentage")], input$project)
  }, height = isolate(height_to_use()))
  
  output$project_output <- renderText(
    paste0("Data for ", input$project)
  )
  
  output$table <- renderDataTable(
    expr = {
      cd <- country_data[country_data$project == input$project,c("country","language","project","pageviews_percentage")]
      cd[order(cd$pageviews_percentage, decreasing = TRUE),]
      },
    options = list(paging = FALSE, searching = FALSE)
  )
})
