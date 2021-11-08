install.packages("ggplot2")
install.packages("dplyr")
install.packages("DBI")
install.packages("odbc")
install.packages("factoextra")

library(ggplot2)
library(dplyr)
library(DBI)
library(odbc)
library(factoextra)

#SQL Server connection, had to increase timeout
con <- dbConnect(odbc(), Driver = "SQL Server",
                 Server = "LAPTOP-E8KMOCEO",
                 Database = "RepuestosWeb",
                 timeout = 5000)

#### Exercise 1 ####

## Part b
dfPartsOG <- dbGetQuery(con, "select cat.Nombre, 
  sum(p.Precio*cd.Cantidad) as TotalPorParte,
  sum(cd.Cantidad) as TotalPartesCotizadas,
  avg(cd.cantidad) as PromedioPartesCotizadas
  from
  Cotizacion C left join
  CotizacionDetalle CD on C.IDCotizacion = CD.IDCotizacion inner join
  Partes P on P.ID_Parte = cd.ID_Parte INNER JOIN
  Categoria cat on Cat.ID_Categoria = p.ID_Categoria
  group by cat.Nombre")

# Set column 1 (Nombre) as data frame's rows names
dfPartsRaw <- dfPartsOG[,-1]
rownames(dfPartsRaw) <- dfPartsOG[,1]

dfScaledParts <- scale(dfPartsRaw) # scale dfParts
dfScaledParts <- na.omit(dfScaledParts) # rm bad rows

## Part c

set.seed(123)

clusterk2 <- kmeans(dfScaledParts, 2, nstart = 25)
clusterk3 <- kmeans(dfScaledParts, 3, nstart = 25)
clusterk4 <- kmeans(dfScaledParts, 4, nstart = 25)
clusterk5 <- kmeans(dfScaledParts, 5, nstart = 25)

#Cluster assignation
#clusterk3$cluster
#Each cluster's size
#clusterk5$size
#Cluster's centers
clusterk5$centers

#fviz_cluster(clusterk3, geom = "point", data = dfScaledParts) + ggtitle("k = 2")

grafica1 <- fviz_cluster(clusterk2, geom = "point", data = dfScaledParts) + ggtitle("k = 2")
grafica2 <- fviz_cluster(clusterk3, geom = "point",  data = dfScaledParts) + ggtitle("k = 3")
grafica3 <- fviz_cluster(clusterk4, geom = "point",  data = dfScaledParts) + ggtitle("k = 4")
grafica4 <- fviz_cluster(clusterk5, geom = "point",  data = dfScaledParts) + ggtitle("k = 5")

library(gridExtra)
grid.arrange(grafica1, grafica2, grafica3, grafica4, nrow = 2)

#spot optimum k
fviz_nbclust(dfScaledParts, kmeans, method = "wss") +
  geom_vline(xintercept = 5, linetype = 2)

Cluster5Parts<-as.data.frame(clusterk5$cluster)

mergedParts<-merge(Cluster5Parts,dfPartsRaw,by=0, all=TRUE)

names(mergedParts)[2]<-"clustno"
mergedParts<-subset(mergedParts, select=-c(Row.names))

aggregate(mergedParts,by=list(mergedParts$clustno),FUN=mean)

fviz_cluster(clusterk5, data = dfScaledParts, labelsize = 0, pointsize = 0)
