#!/usr/bin/env/Rscript

.libPaths( c( .libPaths(), "~/my_R_libs") )
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(biomformat))
# suppressPackageStartupMessages(library(dada2))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(randomForest))
suppressPackageStartupMessages(library(pROC))


# DEBIAS_data <- read.csv("./output/sink_nonsink/DEBIAS-M_runs/builtenv_debiased_lognorm_PRJNA878661.csv", colClasses = c("Phenotype" = "factor"))
# 
# DEBIAS_data %>% distinct(Phenotype) %>% print()


df <- read.csv("./csv_files/vetted_ontology/lognorm_data.csv")
dim(df) %>% print()
count(df, Study_ID)

df %>% group_by(Phenotype) %>% count(Study_ID)

# l <- rowSums(df[,6:length(df)])
# print(l[l == 0])

# rows_with_sum_zero <- rowSums(df[,6:length(df)]) == 0
# df[rows_with_sum_zero, ] %>% print()