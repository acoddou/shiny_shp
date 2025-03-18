# Cargar librerías necesarias
library(tidymodels)  # Modelado
tidymodels_prefer()
library(readr)       # Lectura de CSV
library(dplyr)       # Manipulación de datos
library(ggplot2)     # Gráficos

# Cargar datos limpios
glimpse(datos_limpios)

# Eliminar filas con NA en FC y PWP
datos_limpios <- datos_limpios %>% 
  filter(!is.na(FC), !is.na(PWP))

# Partición de datos
set.seed(42)
new_split <- initial_split(datos_limpios, prop = 3/4, strata = FC)
new_train <- training(new_split) 
new_test <- testing(new_split)

# Crear recetas
receta_fc <- recipe(FC ~ sand + silt + clay + bulk_density + organic_matter, data = new_train) |> 
  step_normalize(all_numeric_predictors())

receta_pwp <- recipe(PWP ~ sand + silt + clay + bulk_density + organic_matter, data = new_train) |> 
  step_normalize(all_numeric_predictors())

# Definir el modelo de Random Forest
tune_spec <- rand_forest(mtry = tune(), trees = tune(), min_n = tune()) %>% 
  set_mode("regression") %>% 
  set_engine("ranger")

# Validación cruzada
set.seed(100)
cv_folds <- vfold_cv(new_train, v = 3)

# Definir la grilla de hiperparámetros
grid <- grid_random(
  mtry(range = c(4, 8)),
  trees(range = c(500, 1000)),
  min_n(range = c(10, 20)),
  size = 5)

# Crear workflows
workflow_fc <- workflow() |> add_model(tune_spec) |> add_recipe(receta_fc)
workflow_pwp <- workflow() |> add_model(tune_spec) |> add_recipe(receta_pwp)

# Ajustar hiperparámetros
tune_results_fc <- tune_grid(
  workflow_fc,
  resamples = cv_folds,
  grid = grid,
  control = control_grid(save_pred = TRUE, verbose = TRUE)
)

tune_results_pwp <- tune_grid(
  workflow_pwp,
  resamples = cv_folds,
  grid = grid,
  control = control_grid(save_pred = TRUE, verbose = TRUE)
)

# Seleccionar los mejores hiperparámetros
best_params_fc <- select_best(tune_results_fc, metric = "rmse")
best_params_pwp <- select_best(tune_results_pwp, metric = "rmse")

# Finalizar modelos
final_model_fc <- finalize_model(tune_spec, best_params_fc)
final_model_pwp <- finalize_model(tune_spec, best_params_pwp)

# Ajustar los modelos finales
final_fit_fc <- final_model_fc %>% 
  fit(FC ~ sand + silt + clay + bulk_density + organic_matter, data = new_train)

final_fit_pwp <- final_model_pwp %>% 
  fit(PWP ~ sand + silt + clay + bulk_density + organic_matter, data = new_train)

# Guardar los modelos entrenados
saveRDS(final_fit_fc, "shinyapp/modelos/modelo_fc.rds")
saveRDS(final_fit_pwp, "shinyapp/modelos/modelo_pwp.rds")

