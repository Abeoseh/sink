#!/usr/bin/env/Rscript

.libPaths( c( .libPaths(), "~/my_R_libs") )
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(biomformat))
suppressPackageStartupMessages(library(dada2))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(BSDA))
suppressPackageStartupMessages(library(randomForest))
suppressPackageStartupMessages(library(pROC))

lognorm <- read.csv("csv_files/associated_2192/lognorm_data.csv", colClasses = c("Phenotype" = "factor"))
lognorm <- lognorm[1:30]


c <- lognorm[sample(nrow(lognorm), 300), ]
#sample(rep(unique(data$taste), each = 25))
#c <- sample_n(lognorm, 300, fac = "Study_ID")


#c$Phenotype <- sample(c$Phenotype)
#filter_c <- c %>% group_by(Phenotype) %>% count(Study_ID) %>% filter(n > 5)
#filter_c <- unique(filter_c$Study_ID)
#c <- filter(c, Study_ID %in% filter_c)

IDs <- distinct(c, Study_ID)$Study_ID
print(IDs)

auc.df <- data.frame(matrix(ncol = 3, nrow = 0))
colnames(auc.df) <-   c("Study_ID", "AUC", "Permutation")
 
roc.df <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(roc.df) <-   c("Study_ID", "Permutation", "sensitivities", "specificities")
 
#write.csv(c, "./csv_files/test/rf_test.csv")
 
# pdf("./output/test2.pdf", height = 4, width = 8)
# # par(mar=c(3,3,1,0), mfrow=c(2,2))
# 
# 
for(i in 1:length(IDs[1:2])){
 
   training <- filter(c, Study_ID != IDs[i])
   training <- training[, c(2, 6:length(training))] 
   testing <- filter(c, Study_ID == IDs[i])
   testing <- testing[, c(2, 6:length(testing))]

   #set seed and run rf
   set.seed(100)
   RF_fit <- randomForest(Phenotype~., method = "class", data = training)

   # predictions
   set.seed(100)    
   RF_pred <- predict(RF_fit, testing, type = "prob")
   
   rf_roc <- roc(testing[,1], RF_pred[,1])
   auc.df[nrow(auc.df) + 1,] = c(IDs[i], auc(rf_roc), FALSE)
 
   df <- data.frame(Study_ID = IDs[i], Permutation = 0, sensitivities = rf_roc$sensitivities, specificities = rf_roc$specificities)
   roc.df <- rbind(roc.df, df)
#   phen <- filter(phenos, ID == IDs[i])
#   phen <- phen[1,2]
   
   a <- round(auc(rf_roc), 2)
#   # p <- ggplot() + ggroc(rf_roc, color="red") + 
#   #   annotate("text", x=0.25, y=0.15, label = round(auc(rf_roc), 2)) + 
#   #   labs(title = paste("Training without:", IDs[i], "(", phen, ")"))
#   
#   
   for(j in 1:2){
     training$Phenotype <- sample(training$Phenotype)
     testing$Phenotype <- sample(testing$Phenotype)
     RF_fit <- randomForest(Phenotype~., method = "class", data = training)
     RF_pred <- predict(RF_fit, testing, type = "prob")
     rf_roc <- roc(testing[,1], RF_pred[,1])
     
     df <- data.frame(Study_ID = IDs[i], Permutation = j, sensitivities = rf_roc$sensitivities, specificities = rf_roc$specificities)
     roc.df <- rbind(roc.df, df)
     
     auc.df[nrow(auc.df) + 1,] = c(IDs[i], auc(rf_roc), TRUE)
     
#     # p <- plot(rf_roc, print.auc=FALSE, add = TRUE)
   }
#   
#   p <- ggplot() + 
#     # geom_line(roc.df, aes(x = specificity, y = sensitivity, group=Permutations)) +
#     geom_line(data = filter(roc.df, Permutation == 0), aes(x = specificities, y = sensitivities, group = Permutation), color = "red") +
#     geom_line(data = filter(roc.df, Permutation != 0), aes(x = specificities, y = sensitivities))
#   
#   print(p)
#   current <- auc.df %>% filter(Study_ID == IDs[i])
# 
#   g <- ggplot() + geom_histogram(data = filter(current, Permutation == TRUE), aes(x = AUC), bins = 10) +
#   geom_vline(filter(current, Permutation == FALSE), mapping = aes(xintercept=AUC), color = "cornflowerblue") 
#   # 
#   # plot_grid(p, g)
#   # p
#   # rm(p)  
   print(paste(i, "of", length(IDs[1:4]), " done."))
 }
# 
# dev.off()
write.csv(roc.df, "./csv_files/test/roc_df.csv", row.names=F)


