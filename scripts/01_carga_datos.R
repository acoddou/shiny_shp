
# 01_carga_datos.R --------------------------------------------------------

## Script para importar y explorar los datos iniciales

# Importar librerias necesarias
library(tidyverse)
library(readr)

# Usar file.choose() para que el usuario seleccione el archivo csv 
# Recomendación de tutorial para importar datos si es con objetivo shinyapp
archivo <- file.choose()

# Importar los datos limpios desde 'data' como tibble
datos <- read_csv(archivo, na = c("NA", ".", ""))
