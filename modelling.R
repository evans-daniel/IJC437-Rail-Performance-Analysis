###############################################################################

# PREDICTIVE MODELLING #

###############################################################################

set.seed(123)

# Read data in
trains <- read_csv("data/trains_df.csv") %>% dplyr::select(-1) %>% 
  mutate(year_commencing = as.factor(year_commencing),
         yQ = as.factor(yQ),
         operator = as.factor(operator),
         region = as.factor(region))

# splitting data into training and testing 
trains_split <- initial_split(trains, prop = .8, strata = region)
train_tr <- training(trains_split)
train_test <- testing(trains_split)

# set model metrics 
model_metrics <- metric_set(rmse, rsq)

# create cross validation folds
kfolds <- vfold_cv(train_tr, v = 10)

# create model spec
ppm_model <- linear_reg(penalty = tune(), mixture = tune()) %>%  
  set_engine("glmnet") %>% 
  set_mode("regression")

# create model preprocessing recipe 
ppm_recipe <- recipe(ppm ~., data = train_tr) %>% 
  step_indicate_na(p_journeys_per_station,
                   p_km_per_station,
                   trains_planned_per_station) %>% 
  step_impute_median(p_journeys_per_station, p_km_per_station, trains_planned_per_station) %>% 
  update_role(year_commencing, yQ, operator, region, new_role = "control") %>% 
  step_dummy(all_factor(), one_hot = TRUE) %>% 
  step_zv(all_predictors()) %>% 
  step_YeoJohnson(all_numeric_predictors(), -all_outcomes(), -starts_with("na_ind_"), -matches("year|yQ|operator|region")) %>% 
  step_normalize(all_numeric_predictors(), -all_outcomes(), -starts_with("na_ind_"), -matches("year|yQ|operator|region"))


# Create workflow - combining model spec and recipe for tuning
ppm_workflow_tuning <- workflow() %>% 
  add_model(ppm_model) %>% 
  add_recipe(ppm_recipe)

# Create tune grid
tuning_grid <- grid_regular(parameters(ppm_workflow_tuning), levels = 10)

# Tune
tuning_results <- tune_grid(
  ppm_workflow_tuning,
  grid = tuning_grid,
  resamples = kfolds, 
  metrics = model_metrics
)

# Find statistics of cross-validation fitting and tuning results
tuning_results %>% collect_metrics() %>% group_by(.metric) %>% 
  summarise(mean = mean(mean), median = median(mean), min = min(mean), max = max(mean))

best_tune <- tuning_results %>% select_best(metric = "rmse")


# Final workflow (recipe and spec) using best model parameters from tune
final_ppm_wf <- finalize_workflow(ppm_workflow_tuning, best_tune)

# Last fit - train with training split, test on testing split
ppm_fit <- last_fit(final_ppm_wf, trains_split)


# Collect RMSE
ppm_fit %>% collect_predictions() %>% 
  rmse(.pred, ppm)

# Collect R squared
ppm_fit %>% collect_predictions() %>% 
  rsq(.pred, ppm)


# Visualise model fit 
ppm_fit %>% 
  collect_predictions() %>% 
  ggplot(aes(x = .pred, y = ppm)) + 
  geom_point() + 
  geom_smooth() + 
  geom_abline(slope = 1, intercept = 0, colour = 'red')


# Find coefficients, then remove control variables 

ppm_fit %>% extract_fit_parsnip() %>% tidy() %>% arrange(desc(estimate))
ppm_fit %>% extract_fit_parsnip() %>% tidy() %>% arrange(-desc(estimate))


coeffs <- ppm_fit %>% extract_fit_parsnip() %>% tidy() %>% dplyr::select(-penalty) %>% 
  filter(!str_starts(term, "operator_"),
         !str_starts(term, "yQ_"),
         !str_starts(term, "region_"),
         !str_starts(term, "year_commencing"),
         !str_starts(term, "na_ind")) %>% 
  arrange(desc(estimate))

# Separate coefficients from intercept for plotting
coeff_intercept <- coeffs$estimate[coeffs$term == "(Intercept)"]
coeffs_no_intercept <- coeffs %>% filter(term != "(Intercept)")
coeff_adjusting <- coeffs_no_intercept %>% mutate(adjusted = 88.8 + estimate)


# Visualize coefficients 
ggplot(coeff_adjusting, aes(x = fct_reorder(term, estimate), y = estimate, fill = estimate)) +
  geom_point() +                               
  geom_hline(yintercept = 0,                 
             color = "red", linetype = "dashed", size = 1) +
  coord_flip()

