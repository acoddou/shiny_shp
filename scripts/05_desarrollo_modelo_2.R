# Librerías
library(tidymodels)  # Modelado
library(readr)       # Lectura de CSV
library(dplyr)       # Manipulación de datos
library(ggplot2)     # Gráficos
library(ggsoiltexture) # graficartexturas de suelo 

# Cargar datos limpios
glimpse(datos_limpios)


# Eliminar filas con NA en FC y PWP
datos_limpios <- datos_limpios %>% 
  filter(!is.na(FC), !is.na(PWP))

grid <- grid_random(mtry(range = c(4, 8)), # Prueba valores más bajos para reducir el tiempo de cómputo
                    trees(range = c(500, 1000)), # No usar demasiados árboles
                    min_n(range = c(10, 20)), size = 5)  # Prueba solo 10 combinaciones

# Definir modelos
tune_spec <- rand_forest(mtry = tune(),
                         trees = tune(),
                         min_n = tune()) %>% set_mode("regression") %>% set_engine("ranger")

# Partición de datos ------------------------------------------------------

set.seed(42)

new_split <- initial_split(datos_limpios, 
                           prop = 3/4, 
                           strata = FC)

new_train <- training(new_split) 
new_test <- testing(new_split)

# Recetas
receta_fc <- recipe(FC ~ sand + silt + clay + bulk_density + organic_matter, data = new_train) |> 
  step_unknown(all_nominal()) |>  
  step_novel(all_nominal(), -all_outcomes()) |> 
  step_dummy(all_nominal()) |> 
  step_zv(all_predictors()) |> 
  step_normalize(all_predictors())

receta_pwp <- recipe(PWP ~ sand + silt + clay + bulk_density + organic_matter, data = new_train) |> 
  step_unknown(all_nominal()) |>  
  step_novel(all_nominal(), -all_outcomes()) |> 
  step_dummy(all_nominal()) |> 
  step_zv(all_predictors()) |> 
  step_normalize(all_predictors())

# Validación cruzada con k-fold
set.seed(100)
cv_folds <- vfold_cv(new_train, v = 3)  # Sin estratificación

# 
# # Crear Workflows
# workflow_fc <- workflow() |> 
#   add_model(tune_spec) |> 
#   add_recipe(receta_fc)
# 
# workflow_pwp <- workflow() |> 
#   add_model(tune_spec) |> 
#   add_recipe(receta_pwp)
# 
# # Evaluar modelos
# fc_results <- workflow_fc |> 
#   fit_resamples(cv_folds) |> 
#   collect_metrics()
# 
# pwp_results <- workflow_pwp |> 
#   fit_resamples(cv_folds) |> 
#   collect_metrics()
# 
# # Mostrar métricas
# fc_results
# pwp_results

tune_results <- tune_grid(
  tune_spec,
  preprocessor = receta_fc,
  # Usa un recipe si tienes
  resamples = cv_folds,
  grid = grid,
  control = control_grid(save_pred = TRUE, verbose = TRUE))

