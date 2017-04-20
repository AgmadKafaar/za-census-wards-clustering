require(ggplot2)

plotCluster <- function(centers, featureGroup, id = "ClusterId") {
  meltedData <- melt(centers, id.vars = c(id, "size"), 
                     measure.vars = grep(featureGroup, names(centers), value = TRUE))
  ggplot(meltedData, aes(x = variable, y = value, group = ClusterId, colour = ClusterId, size = size)) +
    geom_line() + theme(axis.text.x = element_text(angle = 45, hjust = 1))
}