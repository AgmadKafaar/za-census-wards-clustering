require(ggplot2)

plotCluster <- function(centers, featureGroup) {
  meltedData <- melt(centers, id.vars = "ClusterId", 
                     measure.vars = grep(featureGroup, names(centers), value = TRUE))
  ggplot(meltedData, aes(x = variable, y = value, group = ClusterId, colour = ClusterId)) +
    geom_line() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
}