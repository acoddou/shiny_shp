# Librerías
library(tidymodels)  # Modelado
library(readr)       # Lectura de CSV
library(dplyr)       # Manipulación de datos
library(ggplot2)     # Gráficos
library(ggsoiltexture) # graficartexturas de suelo 

# Cargar datos limpios
glimpse(datos_limpios)

cor(datos_limpios %>% select("sand", "silt", "clay", "bulk_density", "organic_matter"), use = "complete.obs")

# Eliminar filas con NA en FC y PWP
datos_limpios <- datos_limpios %>% 
  filter(!is.na(FC), !is.na(PWP))

# Definir modelos
lm_spec <- linear_reg() |> 
  set_engine("lm") |> 
  set_mode("regression")

# Recetas
receta_fc <- recipe(FC ~ PWP + sand + silt + clay + bulk_density + organic_matter, data = datos_limpios) |> 
  step_unknown(all_nominal()) |>  
  step_novel(all_nominal(), -all_outcomes()) |> 
  step_dummy(all_nominal()) |> 
  step_zv(all_predictors()) |> 
  step_normalize(all_predictors())

receta_pwp <- recipe(PWP ~ FC + sand + silt + clay + bulk_density + organic_matter, data = datos_limpios) |> 
  step_unknown(all_nominal()) |>  
  step_novel(all_nominal(), -all_outcomes()) |> 
  step_dummy(all_nominal()) |> 
  step_zv(all_predictors()) |> 
  step_normalize(all_predictors())

# Validación cruzada con k-fold
set.seed(100)
cv_folds <- vfold_cv(datos_limpios, v = 5)  # Sin estratificación

# Crear Workflows
workflow_fc <- workflow() |> 
  add_model(lm_spec) |> 
  add_recipe(receta_fc)

workflow_pwp <- workflow() |> 
  add_model(lm_spec) |> 
  add_recipe(receta_pwp)

# Evaluar modelos
fc_results <- workflow_fc |> 
  fit_resamples(cv_folds) |> 
  collect_metrics()

pwp_results <- workflow_pwp |> 
  fit_resamples(cv_folds) |> 
  collect_metrics()

# Mostrar métricas
fc_results
pwp_results




