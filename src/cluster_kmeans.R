require(data.table)

features <- grep("(^age)|(language)|(population_)|(employment)|(income)|(internet)|(scaledPopulation)",
                 names(wards), value = TRUE)

completeWards <- wards[complete.cases(wards)]

set.seed(20170215)
wardClustersKmeans15 <- kmeans(completeWards[, features, with=FALSE], centers = 15)
wardClusters <- data.table(geo_code = completeWards$geo_code, 
                           cluster_id = wardClustersKmeans15$cluster)

dbWriteTable(sqliteCon, 
             name = "ward_clusters", 
             value = wardClusters, 
             row.names = FALSE)