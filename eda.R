###############################################################################

# PERFORMING EXPLORATORY DATA ANALYSIS #

###############################################################################

set.seed(123)


# Import data
trains <- read_csv("data/trains_df.csv") %>% dplyr::select(-1) %>% 
  mutate(year_commencing = as.double(year_commencing),
         yQ = as.factor(yQ),
         operator = as.factor(operator),
         region = as.factor(region)) 


# DESCRIPTIVES

trains %>% summary()

trains %>% 
  group_by(yQ) %>% 
  summarise(mean(ppm))

trains %>% 
  group_by(year_commencing) %>% 
  summarise(mean(ppm))

trains %>% 
  dplyr::select(-year_commencing) %>% 
  select_if(is.numeric) %>% 
  map(., .f = sd) 


# CORRELATION MATRIX 
correlations <- cor(trains[,5:16], use = "pairwise.complete.obs") %>% melt() %>% 
  filter(as.numeric(Var1) <= as.numeric(Var2))

correlations %>% 
  ggplot(aes(x = Var1, y = Var2, fill = value)) + 
  geom_tile() + 
  geom_text(aes(label = round(value, 2)), size = 3) +
  scale_fill_gradient2(low = "blue", mid = "white", high = "red", midpoint = 0) +
  coord_fixed()


# HISTOGRAMS 
trains %>% dplyr::select(-year_commencing) %>% select_if(is.numeric) %>% 
  na.omit() %>% 
  gather(cols, value) %>% 
  ggplot(aes(x = value)) + 
  geom_histogram() + 
  facet_wrap(.~cols, scales = "free")

# K-S TEST, SIGNIFICANT = NOT NORMAL DISTRUBTION
trains %>% 
  dplyr::select(-year_commencing) %>% 
  select_if(is.numeric) %>% 
  map(., .f = ks.test, "pnorm") 


#  QQ PLOTS 
trains %>% 
  dplyr::select(-year_commencing) %>% 
  select_if(is.numeric) %>% 
  na.omit() %>% 
  pivot_longer(where(is.numeric)) %>%
  ggplot(aes(sample = value)) +
  stat_qq() +
  stat_qq_line(colour = "red") +
  facet_wrap(~ name, scales = "free")
