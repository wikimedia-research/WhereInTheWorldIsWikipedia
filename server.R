library(shiny)
library(ggplot2)
library(RColorBrewer)
library(scales)
library(grid)

#Load and format dataset
country_data <- read.delim("./data/lang_pairs.tsv", as.is = TRUE, header = TRUE)
country_data$pageviews <- country_data$pageviews/100
names(country_data) <- c("project", "language", "pageviews percentage", "country")

#Plot for per-project data
per_project_plot <- function(data){
  project_name <- unique(data$project)
  palette <- brewer.pal("Greys", n=9)
  color.background = palette[2]
  color.grid.major = palette[3]
  color.axis.text = palette[6]
  color.axis.title = palette[7]
  color.title = palette[9]
  ggplot(data, aes(reorder(country, `pageviews percentage`), `pageviews percentage` , fill = country)) +
    geom_bar(stat = "identity") +
  theme_bw(base_size=9) +
    theme(panel.background=element_rect(fill=color.background, color=color.background)) +
    theme(plot.background=element_rect(fill=color.background, color=color.background)) +
    theme(panel.border=element_rect(color=color.background)) +
    theme(panel.grid.major=element_line(color=color.grid.major,size=.25)) +
    theme(panel.grid.minor=element_blank()) +
    theme(axis.ticks=element_blank()) +
    theme(legend.position = "none") +
    theme(axis.text.x=element_text(size=10,color=color.axis.text)) +
    theme(axis.text.y=element_text(size=10,color=color.axis.text)) +
    theme(axis.title.x=element_text(size=12,color=color.axis.title, vjust=0)) +
    theme(axis.title.y=element_text(size=12,color=color.axis.title, vjust=1.25)) +
    theme(plot.title = element_text(size=14, color = color.axis.title, face = "bold")) +
    theme(plot.margin = unit(c(0.35, 0.2, 0.3, 0.35), "cm")) +
  coord_flip() +
  scale_y_continuous(labels = percent, breaks = c(0.01,seq(0.10,round(max(data$`pageviews percentage`),1),0.10)),
                     limits = c(0,round(max(data$`pageviews percentage`),1))) +
  labs(title = paste("Per-country pageviews for", paste0(project_name,".org"), "(2014)"),
       y = "Percentage of pageviews",
       x = "Country")
  
}


shinyServer(function(input, output) {
  output$downloadAll <- downloadHandler(
    filename = "all_country_data.tsv",
    content = function(file){
      write.table(country_data, file, row.names = FALSE, sep = "\t", quote = TRUE)
    }
  )
    output$downloadCountrySubset <- downloadHandler(
    filename = paste0("country-subset-",input$project,".tsv"),
    content = function(file){
      write.table(country_data[country_data$project == input$project,], file, row.names = FALSE, sep = "\t", quote = TRUE)
    }
  )
  output$country_distribution <- renderPlot({
    per_project_plot(country_data[country_data$project == input$project,])
  })
  output$project_output <- renderText(
    paste0("Data for ", input$project, ".org")
  )
  output$table <- renderDataTable(
    expr = country_data[country_data$project == input$project,]
  )
})