install.packages("ggplot2")
install.packages("dplyr")
install.packages("DBI")
install.packages("odbc")
install.packages('arules')

library(ggplot2)
library(dplyr)
library(DBI)
library(odbc)
library(arules)

#### Exercise 2 ####

## Part a
setwd("C:\\Users\\velas\\OneDrive - Universidad Rafael Landivar\\2021\\URL\\8C\\ANÁLISIS DE DATOS\\GIT\\Lab4-ClusteringAsociacion")

#read csv
comprasCsv <- read.transactions ("Compras.csv",rm.duplicates = FALSE,format="single",sep=",",cols=c(1,2))
comprasCsv@itemInfo
image(comprasCsv)


