###############################################################################

# MASTER SCRIPT #

###############################################################################


# Library imports
library(tidyverse)
library(tidymodels)
library(vip)
library(reshape2)
library(GGally)
library(broom)
library(janitor)
library(readxl)
library(lubridate)
library(data.table)
library(zoo)

options(warn = -1)

# Source data files and run
source("funs.R")
source("data.R")
source("eda.R")
source("modelling.R")
source("plots.R")

options(warn = 0)
# Save plots
ggsave("figures/corr_heatmap_plot.png", plot = corr_heatmap_plot)
ggsave("figures/histogram_plot.png", plot = histogram_plot, height = 12, width = 15)
ggsave("figures/qq_plot.png", plot = qq_plot, height = 12, width = 15)
ggsave("figures/model_prediction_plot.png", plot = model_prediction_plot)
ggsave("figures/coefficient_plot.png", plot = coefficient_plot)
