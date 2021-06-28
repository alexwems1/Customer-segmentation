library(DBI)
library(plot3D)

connect_own<-function() {
  
  options(mysql = list(
    "host" = "127.0.0.1", 
    "port" = 3306,
    "user" = "alexwems",
    "password" = "T77vqlra$"
    
  ))
  
  
  db <- RMySQL::dbConnect(RMySQL::MySQL(), dbname = "base", host = options()$mysql$host, 
                          port = options()$mysql$port, user = options()$mysql$user, 
                          password = options()$mysql$password)  
  
  
  
  return(db)
}

con_own <- connect_own()
heart_data<-dbReadTable(con_roberto, "segmentacionclientes")
dbSendQuery(con_own, "SET GLOBAL local_infile = true;")
dbWriteTable(con_own, "segmentacion_clientes", heart_data, overwrite = TRUE, row.names=FALSE)
dbListTables(con_own)
datos <- dbReadTable(con_own, "segmentacion_clientes")
write.csv(datos, "/home/alexwems1/Documentos/R/datos.csv", row.names = FALSE)

#Exploracion de datos
str(datos)
names(datos)
head(datos)
summary(datos)
sd(datos$Spending.Score..1.100.)
summary(datos$Annual.Income..k..)
sd(datos$Annual.Income..k..)
summary(datos$Age)
barplot(table(datos$Gender), main = "Comparacion de  generos", names.arg = c("Hombres", "Mujeres"))
library(plotrix)
porcentaje <-(table(datos$Gender)/sum(table(datos$Gender))*100)
pie3D(table(datos$Gender), labels = paste(row.names(porcentaje),porcentaje, "%"))
hist(datos$Age, main = "Histograma de edades", xlab = "Edades", ylab = "Frecuencia", col = "deepskyblue2")
boxplot(datos$Age)
#Visualizacion de ingresos 
hist(datos$Annual.Income..k.., xlab = "Ingresos anuales", col = "steelblue1")
plot((density(datos$Annual.Income..k..,)))
polygon(density(datos$Annual.Income..k..), col = "springgreen")
#Visualizacion de spending score
boxplot(datos$Spending.Score..1.100.)
hist(datos$Spending.Score..1.100., col = "grey", main = "Histograma Spending Score", xlab = "Spending Score")
#-----------------------------Algoritmo K-means---------------------------------------------
#-------------------Determinar el numero de clusters
#Elbow Method 
library(purrr)
set.seed(123)
data_clustering <- cbind.data.frame(datos$Annual.Income..k.., datos$Spending.Score..1.100.)
clusters <- c()
for (i in c(1:10)) {
  clusters[i] <- kmeans(data_clustering, i, iter.max = 100, nstart = 100, algorithm = "Lloyd")$tot.withinss
  
}
clusters
plot(x = c(1:10), y = clusters, lines(c(1:10),clusters), xlab = "Numero de clusters", ylab = "Total intra-clusters sum of squares")
library(cluster)
library(gridExtra)
library(grid)
library
average_sil <- c()
for (i in c(2:10)) {
  k<-kmeans(data_clustering,i,iter.max=100,nstart=50,algorithm="Lloyd")
  silh_plot<-plot(silhouette(k$cluster,dist(data_clustering,"euclidean")))
  s <- silhouette(k$cluster,dist(data_clustering,"euclidean"))
  average_sil[i-1] <- mean(s[,3])
}
average_sil
length(average_sil)
plot(c(2:10), average_sil, type = "o")
final <- kmeans(data_clustering,6,iter.max=100,nstart=50,algorithm="Lloyd")
fviz_cluster(final, data = data_clustering)

