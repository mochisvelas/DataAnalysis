install.packages("ggplot2")
install.packages("dplyr")
install.packages("DBI")
install.packages("odbc")
install.packages("stringr")

library(ggplot2)
library(dplyr)
library(stringr)
library(DBI)
library(odbc)

#SQL Server connection, had to increase timeout
con <- dbConnect(odbc(), Driver = "SQL Server",
                 Server = "LAPTOP-E8KMOCEO",
                 Database = "Admisiones_DWH",
                 timeout = 5000)


#### Part b ####

# Exercise i
dfExamFaculty <- dbGetQuery(con, "select e.*, c.NombreFacultad
                    from Fact.Examen e inner join
                    Dimension.Carrera c on (e.sk_carrera = c.sk_carrera)")

dfExamFacultyCount <- dfExamFaculty %>% count(NombreFacultad)

# Exercise ii
dfExamGender <- dbGetQuery(con, "select e.*, c.Genero
                    from Fact.Examen e inner join
                    Dimension.Candidato c on (e.sk_candidato = c.sk_candidato )")

dfExamGenderCount <- dfExamGender %>% count(Genero)

# Exercise iii
dfExamPrice <- dbGetQuery(con, "select e.*, c.NombreCarrera 
                    from Fact.Examen e inner join
                    Dimension.Carrera c on (e.sk_carrera = c.sk_carrera)")

dfExamPriceSum <- dfExamPrice %>% group_by(NombreCarrera) %>% summarise(PrecioTotal = sum(Precio))


# Exercise iv
dfFacultyMean <- dbGetQuery(con, "select e.*, c.NombreFacultad 
                    from Fact.Examen e inner join
                    Dimension.Carrera c on (e.sk_carrera = c.sk_carrera)")

dfTopFacultyMean <- dfFacultyMean %>% group_by(NombreFacultad) %>% summarise(NotaPromedio = mean(NotaTotal)) %>% arrange(desc(NotaPromedio)) %>% slice(1:2)


#### Part c ####

# Exercise i

ggplot(dfExamFacultyCount, aes(x="", y=n, fill=NombreFacultad)) +
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0)


# Exercise ii
dfCareerMean <- dbGetQuery(con, "select e.*, c.NombreCarrera
                    from Fact.Examen e inner join
                    Dimension.Carrera c on (e.sk_carrera = c.sk_carrera)")

dfGroupedCareerMean <- dfCareerMean %>% group_by(NombreCarrera) %>% summarise(NotaPromedio = mean(NotaTotal))

ggplot(dfGroupedCareerMean, aes(x=NombreCarrera, y=NotaPromedio)) +
  geom_bar(stat="identity") +
  coord_flip()

# Exercise iii
dfExamYear <- dbGetQuery(con, "select e.*, f.Year
                    from Fact.Examen e inner join
                    Dimension.Fecha f on (e.datekey = f.datekey)")

dfExamYearCount <- dfExamYear %>% count(Year)

ggplot(dfExamYearCount, aes(x=Year, y=n, group=1)) +
  geom_line() +
  geom_point()
