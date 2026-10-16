# Segmentación de clientes bancarios
# Ejecutar desde la raíz del repositorio: Rscript scripts/analisis_clientes.R

# Paso 1. Cargar y comprobar los datos
archivo <- file.path("data", "data.csv")
if (!file.exists(archivo)) stop("No se encontró data/data.csv. Ejecuta el script desde la raíz.")
datos <- read.csv(archivo, check.names = FALSE, stringsAsFactors = FALSE)
variables <- c("CreditScore", "Balance", "Age", "Tenure", "NumOfProducts")
necesarias <- c(variables, "Exited")
if (!all(necesarias %in% names(datos))) stop("El CSV no contiene todas las columnas necesarias.")
if (anyNA(datos[necesarias])) stop("Hay valores ausentes en las columnas del análisis.")
if (!all(datos$Exited %in% c(0, 1))) stop("Exited debe contener solo 0 y 1.")
dir.create("results", showWarnings = FALSE)
dir.create("images", showWarnings = FALSE)

cat("Filas:", nrow(datos), "\n")
cat("Columnas:", ncol(datos), "\n")
cat("Tasa general de abandono:", round(100 * mean(datos$Exited), 2), "%\n")

# Paso 2. Explorar las variables que entran en la segmentación
print(summary(datos[variables]))
print(round(cor(datos[variables]), 3))

# Paso 3. Estandarizar y proyectar con PCA para inspección visual
matriz <- scale(datos[variables])
pca <- prcomp(matriz, center = FALSE, scale. = FALSE)
cat("Varianza explicada por PC1 y PC2:",
    round(100 * sum(summary(pca)$importance[2, 1:2]), 2), "%\n")

# Paso 4. Consultar el método del codo; k=2 se usa como segmentación interpretable
set.seed(42)
valores_k <- 1:8
wss <- vapply(valores_k, function(k) {
  kmeans(matriz, centers = k, nstart = 25, iter.max = 1000,
         algorithm = "Lloyd")$tot.withinss
}, numeric(1))
png("images/metodo_codo.png", width = 1000, height = 650, res = 120)
plot(valores_k, wss, type = "b", pch = 19, col = "#245B76",
     xlab = "Numero de grupos (k)", ylab = "Suma de cuadrados intragrupo",
     main = "Metodo del codo para la segmentacion")
dev.off()

# Paso 5. Agrupar sin utilizar Exited
set.seed(42)
modelo <- kmeans(matriz, centers = 2, nstart = 25, iter.max = 100)
datos$grupo_num <- modelo$cluster
balance_por_grupo <- aggregate(Balance ~ grupo_num, datos, mean)
grupo_saldo_alto <- balance_por_grupo$grupo_num[which.max(balance_por_grupo$Balance)]
datos$segmento <- ifelse(datos$grupo_num == grupo_saldo_alto,
                         "Saldo alto", "Saldo bajo")

# Paso 6. Calcular abandono por grupo; Exited no entró al modelo
segmentos <- aggregate(cbind(Balance, Age, CreditScore) ~ segmento,
                      datos, mean)
conteos <- as.data.frame(table(datos$segmento), stringsAsFactors = FALSE)
names(conteos) <- c("segmento", "clientes")
segmentos <- merge(conteos, segmentos, by = "segmento", sort = FALSE)
abandonos <- aggregate(Exited ~ segmento, datos, sum)
names(abandonos)[2] <- "abandonaron"
segmentos <- merge(segmentos, abandonos, by = "segmento", sort = FALSE)
segmentos$permanecieron <- segmentos$clientes - segmentos$abandonaron
segmentos$tasa_abandono_pct <- 100 * segmentos$abandonaron / segmentos$clientes
segmentos <- segmentos[order(segmentos$segmento), ]
names(segmentos)[names(segmentos) == "Balance"] <- "saldo_medio"
names(segmentos)[names(segmentos) == "Age"] <- "edad_media"
names(segmentos)[names(segmentos) == "CreditScore"] <- "puntaje_medio"
write.csv(segmentos, "results/resumen_segmentos.csv", row.names = FALSE)
print(segmentos)
stopifnot(sum(segmentos$clientes) == nrow(datos),
          sum(segmentos$abandonaron) == sum(datos$Exited),
          sum(segmentos$permanecieron) == sum(datos$Exited == 0))
diferencia_pp <- segmentos$tasa_abandono_pct[segmentos$segmento == "Saldo alto"] -
  segmentos$tasa_abandono_pct[segmentos$segmento == "Saldo bajo"]
cat("Diferencia de abandono (saldo alto - saldo bajo):",
    round(diferencia_pp, 2), "puntos porcentuales\n")

# Paso 7. Mostrar el resultado más útil para la decisión
png("images/abandono_por_segmento.png", width = 1100, height = 700, res = 120)
par(mar = c(5, 5, 4, 2))
orden <- match(c("Saldo bajo", "Saldo alto"), segmentos$segmento)
tasas <- segmentos$tasa_abandono_pct[orden]
barras <- barplot(tasas, names.arg = segmentos$segmento[orden],
                  col = c("#81AFC0", "#245B76"), ylim = c(0, max(tasas) * 1.3),
                  ylab = "Clientes que abandonaron (%)",
                  main = "Abandono observado por segmento")
text(barras, tasas, labels = sprintf("%.1f %%", tasas), pos = 3, cex = 1.2)
abline(h = 100 * mean(datos$Exited), lty = 2, col = "#555555")
legend("topleft", legend = "Promedio total", lty = 2, col = "#555555", bty = "n")
dev.off()

# Paso 8. Comparar con un agrupamiento jerárquico sobre una muestra manejable
# La matriz de distancias completa para 10.000 filas sería innecesariamente grande.
set.seed(42)
indices <- sample(seq_len(nrow(matriz)), size = 1000)
jerarquico <- hclust(dist(matriz[indices, ]), method = "complete")
grupos_jerarquicos <- cutree(jerarquico, k = 2)
tabla_comparacion <- table(KMeans = modelo$cluster[indices],
                          Jerarquico = grupos_jerarquicos)
print(tabla_comparacion)
