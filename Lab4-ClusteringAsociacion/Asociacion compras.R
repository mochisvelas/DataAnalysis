install.packages('arules')
library('arules')
install.packages("arulesViz")
library("arulesViz")

#B. I. Leer CSV
setwd("C:\\Users\\derly\\Documents\\Universidad\\8. Octavo ciclo\\AD\\R\\HT#2")
getwd()
txn <- read.transactions("Compras.csv", 
                         rm.duplicates = FALSE, 
                         format="single",sep=",", cols=c(1,2))

#Listado unico del set de transacciones
txn@itemInfo
#Relacion entre los diferenes items por transaccion
image(txn)
#S4
typeof(txn)


##C. II Objeto
#definimos las reglas
basket_rules <- apriori(txn, parameter = list(sup=0.5,conf=0.9, target="rules"))
#Verificacion de reglas
inspect(basket_rules)
objecto_rules <- as(basket_rules, "data.frame")


#C. I
plot(basket_rules)
plot(basket_rules, engine = "plotly")#plot interactivo
#Tabla para visualizar reglas
inspectDT(basket_rules)
#plot grafico
plot(basket_rules, method = "graph", engine = "htmlwidget")
