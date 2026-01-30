###############################################################################

# PLOT CREATION AND PRESENTATION

###############################################################################

# Default plots that are a part of analysis (e.g. histograms) are also present
# in the relevant script. They are duplicated here for formatting and saving.

# Set theme for all plots
theme_set(theme_minimal())

# Neat labelling for correlation matrix
heatmap_labels <- c("Trains Planned per Station", "Passenger KM per Station", "Passenger Journeys per Station", "Trains planned per FTE", "Passenger KM per FTE",
              "Passenger Journeys per FTE", "Yearly FTEs", "Yearly Stations Managed", "Trained Planned", "Passenger KMs (billions)", "Passenger journeys (millions)",
              "Passenger Performance Metric")

# CORRELATION MATRIX HEAT MAP
correlations <- cor(trains[,5:16], use = "pairwise.complete.obs") %>% melt() %>% 
  filter(as.numeric(Var1) <= as.numeric(Var2))

corr_heatmap_plot <- correlations %>% 
  ggplot(aes(x = Var1, y = Var2, fill = value)) + 
  geom_tile() + 
  geom_text(aes(label = round(value, 2)), size = 1.5) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  coord_fixed() + 
  labs(x = "", y = "") + 
  scale_x_discrete(labels = heatmap_labels) +
  scale_y_discrete(labels = heatmap_labels) + 
  theme(legend.position = "",
        axis.text.x = element_text(angle = 45, hjust = 1, size = 9),
        axis.text.y = element_text(size = 9)) + 
  set_fonts()


# HISTOGRAMS
histogram_plot <- trains %>% dplyr::select(-year_commencing) %>% select_if(is.numeric) %>% 
  na.omit() %>% 
  gather(cols, value) %>% 
  mutate(cols = str_replace_all(cols, "_", " ") %>% str_to_title()) %>% 
  ggplot(aes(x = value)) + 
  geom_histogram() + 
  facet_wrap(.~cols, scales = "free", labeller = labeller(cols = heatmap_labels)) + 
  labs(x = "", y = "") + 
  set_fonts()

# Q-Q PLOTS
qq_plot <- trains %>% 
  dplyr::select(-year_commencing) %>% 
  select_if(is.numeric) %>% 
  na.omit() %>% 
  pivot_longer(where(is.numeric)) %>%
  mutate(name = str_replace_all(name, "_", " ") %>% str_to_title()) %>%
  ggplot(aes(sample = value)) +
  stat_qq() +
  stat_qq_line(colour = "red") +
  facet_wrap(~ name, scales = "free") + 
  set_fonts()


# MODEL PREDICTIONS PLOT
model_prediction_plot <- ppm_fit %>% 
  collect_predictions() %>% 
  ggplot(aes(x = .pred, y = ppm)) + 
  geom_point() + 
  geom_smooth(aes(colour = "Predicted Values Line of Best Fit"), show.legend = FALSE) + 
  geom_abline(aes(slope = 1, intercept = 0, color = "Perfect Fit"), show.legend = TRUE) + 
  scale_color_manual(values = c("red", "blue"), name = "") +
  labs(x = "Predicted PPM", y = "Actual PPM") + 
  theme(legend.position = "bottom") +
  set_fonts()


# BETA COEFFICIENTS PLOT
coefficient_plot <- coeff_adjusting %>% 
  ggplot(aes(x = fct_reorder(str_replace_all(term, "_", " ") %>% str_to_title(), estimate), y = estimate)) +
  geom_point(shape = 5) +                          
  geom_hline(yintercept = 0,                  
             color = "red", linetype = "dashed", size = .5) +
  coord_flip() + 
  labs(y = "Beta Coefficient", x = "Variable") + 
  set_fonts()


