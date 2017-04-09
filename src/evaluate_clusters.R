require(ggplot2)

plotWardFeature <- function(wardCodes, data, feature, facetRows = 4) {
  selectedWardData <- data[geo_code %in% wardCodes]
  meltedData <- melt(selectedWardData, 
                     id.vars = "geo_code", 
                     measure.vars = grep(x = names(data), pattern = feature, value = TRUE))
  ggplot(meltedData, aes(y = value, x = variable, fill = geo_code)) + 
    geom_bar(stat = "identity") + 
    facet_wrap(~ geo_code, nrow = facetRows) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) + 
    theme(legend.position="none")
}