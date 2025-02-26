
# Libreria ----------------------------------------------------------------

library("tidyverse")
library("readr")

#Cargar datos
datos_crudos <- read.csv("data/ChSPD_V2.0.csv")

#VIsualizar los datos crudos
glimpse(datos_crudos)

#definir columnas de coordenadas para que no se eliminen luego
cols_coord <- c("x","y")

#transfromar nengativos a ausentes,
datos_limpios <- datos_crudos %>% 
  mutate(across(-all_of(cols_coord), ~ ifelse(.<0, NA, .))) %>% 
  rowwise() %>% 
  mutate(
    suma_textura= sum(c_across(c(sand, silt, clay)), na.rm = TRUE),
    faltante = 100 - suma_textura,
    sand  = ifelse(is.na(sand) & !is.na(faltante), faltante, sand),
    silt  = ifelse(is.na(silt) & !is.na(faltante), faltante, silt),
    clay  = ifelse(is.na(clay) & !is.na(faltante), faltante, clay)
  ) %>%
  ungroup() %>%
  
  # Filtrar solo texturas dentro del rango
  filter(suma_textura >= 98 & suma_textura <= 102) %>%  
  # Eliminar columnas auxiliares
  select(-suma_textura, -faltante) %>%  
  # Filtrar filas sin NA en variables clave
  filter(!if_any(c(FC, PWP, sand, silt, clay, bulk_density, organic_matter), is.na)) 

# Visualizar --------------------------------------------------------------
glimpse(datos_limpios)

# Exportar datos limpios
write_csv(datos_limpios, "data/limpio_ChSPD_V2.0.csv")
