# P2 Multivariada
rm(list=ls())
#### Pacotes e Carregamento dos Dados
library(dplyr)
library(MASS)
library(ggplot2)
library(psych)
library(kableExtra)
library(lmtest)
library(gridExtra)
library(reshape2)
library(ggcorrplot)
library(zoo)
library(car)
library(tidyverse)
library(factoextra)
library(FactoMineR)
#install.packages("faraway")
require(faraway)
force(ozone)
data("ozone")
df = ozone

help(ozone)
df %>% glimpse()

#Variáveis
O3 <- ozone$O3
vh <- ozone$vh
wind <- ozone$wind
humidity <- ozone$humidity
temp <- ozone$temp
ibh <- ozone$ibh
dpg <- ozone$dpg
ibt <- ozone$ibt
vis <- ozone$vis
doy <- ozone$doy

# analise descritiva
summary(O3)
summary(vh)
summary(wind)
summary(humidity)
summary(temp)
summary(ibh)
summary(dpg)
summary(ibt)
summary(vis)
summary(doy)


##Plots
df %>% glimpse()
describe(df)
summary(df)[c(1,3,4,6),]


hist(O3, main = "Histograma de O3", xlab = "O3")
boxplot(O3, main = "Boxplot de O3")
ggplot(df, aes(x = "O3", y = O3)) +
  geom_boxplot() +
  labs(title = "Boxplot de O3", y = "O3")

quantile(df$O3)

summary(df$O3)

par(mfrow=c(3,3))

hist(vh, main = "Histograma de vh", xlab = "vh")
boxplot(vh, main = "Boxplot de vh")

hist(wind, main = "Histograma de wind", xlab = "wind")
boxplot(wind, main = "Boxplot de wind")

hist(humidity, main = "Histograma de humidity", xlab = "humidity")
boxplot(humidity, main = "Boxplot de humidity")

hist(temp, main = "Histograma de temp", xlab = "temp")
boxplot(temp, main = "Boxplot de temp")

hist(ibh, main = "Histograma de ibh", xlab = "ibh")
boxplot(ibh, main = "Boxplot de ibh")

hist(dpg, main = "Histograma de dpg", xlab = "dpg")
boxplot(dpg, main = "Boxplot de dpg")

hist(ibt, main = "Histograma de ibt", xlab = "ibt")
boxplot(ibt, main = "Boxplot de ibt")

hist(vis, main = "Histograma de vis", xlab = "vis")
boxplot(vis, main = "Boxplot de vis")

hist(doy, main = "Histograma de doy", xlab = "doy")
boxplot(doy, main = "Boxplot de doy")


par(mfrow=c(1,1))
library(corrplot)

cor_matrix <- cor(ozone[, c("O3", "vh", "wind", "humidity", "temp", "ibh", "dpg", "ibt", "vis", "doy")])
cor_matrix
# Plotando a matriz de correlações

ozone_vars <- ozone[, c("O3", "vh", "wind", "humidity", "temp", "ibh", "dpg", "ibt", "vis", "doy")]

ozone_corr <- cor(ozone_vars)

# plotar a matriz de correlação com os valores das correlações em cada célula
ggcorrplot(ozone_corr, hc.order = TRUE, type = "lower", lab = TRUE, lab_size = 3)

#corr_df <- melt(corr_mat)

#corr_df$value_color <- ifelse(corr_df$value >= 0, "blue", "red")

# Padronização das variáveis
vh_standardized <- scale(vh)
wind_standardized <- scale(wind)
humidity_standardized <- scale(humidity)
temp_standardized <- scale(temp)
ibh_standardized <- scale(ibh)
dpg_standardized <- scale(dpg)
ibt_standardized <- scale(ibt)
vis_standardized <- scale(vis)
doy_standardized <- scale(doy)

df_standardized <- data.frame(
  O3 = O3,
  vh = vh_standardized,
  wind = wind_standardized,
  humidity = humidity_standardized,
  temp = temp_standardized,
  ibh = ibh_standardized,
  dpg = dpg_standardized,
  ibt = ibt_standardized,
  vis = vis_standardized,
  doy = doy_standardized
)


df_standardized

# Crie um gráfico de histograma para cada variável padronizada
histograms <- lapply(df_standardized, function(x) {
  ggplot(data = df_standardized, aes(x = x)) +
    geom_histogram(binwidth = 0.2, fill = "blue", color = "black", alpha = 0.7) +
    labs(title = paste("Histograma de", deparse(substitute(x))))
})

library(gridExtra)
grid.arrange(grobs = histograms, ncol = 2)


response_variable <- "O3"
vif(df_standardized)

dadox = df_standardized #%>% select(-ibt,-temp)

dadox


### Modelagem 
vars <- dadox[, -1]  # Exlcuindo O3
vars %>% colnames()
### Modelo Sem PCA
# Ajuste o modelo de regressão linear
modelo_regressao <- lm(O3 ~ vh + wind + humidity + temp + ibh + dpg + vis + doy, data = dadox)
summary(modelo_regressao)

### Aplicação do PCA
Y <- dadox$O3

# Variáveis independentes
variaveis_independentes <- dadox[, c( "wind", "humidity","ibh", "dpg", "vis", "doy",'vh','temp')]

# Aplicar PCA às variáveis independentes
pca_result <- prcomp(variaveis_independentes, center = TRUE)
prop_var_explicada <- (pca_result$sdev^2) / sum(pca_result$sdev^2)
prop_var_explicada

par(mfrow=c(2,1))

prop_var_explicada <- (pca_result$sdev^2) / sum(pca_result$sdev^2)
df_prop_var <- data.frame(Componente = 1:length(prop_var_explicada), Proporcao = prop_var_explicada)
ggplot(df_prop_var, aes(x = Componente, y = Proporcao)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  labs(title = "Gráfico de Variância Explicada", x = "Componente Principal", y = "Proporção da Variância")



library(factoextra)
fviz_pca_var(pca_result, col.var = "steelblue")

# Obter os componentes principais
componentes_principais <- pca_result$x

# Ajustar um modelo de regressão linear com os componentes principais
modelo_com_pca <- lm(Y ~ PC1 + PC2 + PC3 + PC4 + PC5  , data = data.frame(Y, componentes_principais))

# Exibir os resultados do modelo com PCA
summary(modelo_com_pca)
anova(modelo_com_pca)
##### Inferencial Sem PCA

# Normalidade
residuos = resid(modelo_regressao)
shapiro.test(residuos)
qqnorm(residuos, main = "Q-Q Plot dos Resíduos do Modelo Sem PCA")
qqline(residuos)

#Heterocedasticidade
bptest(modelo_regressao)
previsoes <- predict(modelo_regressao) # Há heterocedast
plot(previsoes, residuos, xlab = "Previsões", ylab = "Resíduos", main = "Gráfico de Dispersão dos Resíduos")
abline(h = 0, col = "red", lty = 2)


# Inferencial Com PCA
residuos_pca <- resid(modelo_com_pca)
qqnorm(residuos_pca, main = "Q-Q Plot dos Resíduos do Modelo com PCA")
qqline(residuos_pca)

##Inferencial com PCA
anova((modelo_com_pca))

#Normalidade
shapiro.test(residuos_pca)
#Heterocedasticidade
bptest(modelo_com_pca)
previsoes <- predict(modelo_com_pca)
plot(previsoes, residuos, xlab = "Previsões", ylab = "Resíduos", main = "Gráfico de Dispersão dos Resíduos")
abline(h = 0, col = "red", lty = 2)

## Box-Cox
d_box = data.frame(Y, componentes_principais)



boxcox(object=d_box$Y ~ d_box$PC1+d_box$PC2+d_box$PC3+d_box$PC4+d_box$PC5 ,    
       lambda = seq(-2, 2, 1/10), 
       plotit = TRUE)


modelo_box = lm(sqrt(O3) ~ d_box$PC1+d_box$PC2+d_box$PC3+d_box$PC4+d_box$PC5,data=d_box)
modelo_box %>% summary()
modelo_box %>% anova()
par(mfrow=c(1,2))
resid_box = resid(modelo_box) #ok
shapiro.test(resid_box)
bptest(modelo_box) #ok
previsoes <- predict(modelo_box)
plot(previsoes, residuos, xlab = "Previsões", ylab = "Resíduos", main = "Gráfico de Dispersão dos Resíduos")
abline(h = 0, col = "red", lty = 2)
qqnorm(resid_box, main = "Q-Q Plot dos Resíduos do Modelo com PCA")
qqline(resid_box)
