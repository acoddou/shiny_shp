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

# Definir modelos
lm_spec <- linear_reg() |> 
  set_engine("lm") |> 
  set_mode("regression")


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
cv_folds <- vfold_cv(new_train, v = 5)  # Sin estratificación

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

last_fit(workflow_fc,split = new_split) |> 
  collect_metrics()



