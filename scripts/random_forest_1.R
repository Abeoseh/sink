#!/usr/bin/env/Rscript 

#### Goal: preform a random forest with 17 datasets as testing data and the remaining one as the training data ####
# Do this 18 times and generate 18 ROC curves
# Rscript randomForest.R 3 > run3_out.txt

.libPaths( c( .libPaths(), "~/my_R_libs") )
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(randomForest))
suppressPackageStartupMessages(library(pROC))
suppressPackageStartupMessages(library(ggplot2))

args <- commandArgs(trailingOnly = TRUE)
i = as.numeric(args[1])
permutations = as.numeric(args[2])
input = args[3]
output = args[4]

lognorm_out <- read.csv(paste("./csv_files/",input,"/lognorm_data.csv",sep=""), colClasses = c("Phenotype" = "factor"))
phenos <- read.csv("./csv_files/phenotypes.csv") # for naming the graphs

lognorm_out <- lognorm_out[,c(1:3,6:length(lognorm_out))] # remove case and ID columns


#### lognorm permutations testing as a loop ####

IDs <- distinct(lognorm_out, Study_ID)$Study_ID

## create AUC and ROC df
auc.df <- data.frame(matrix(ncol = 4, nrow = 0))
colnames(auc.df) <-   c("Study_ID", "AUC", "Permutation", "DEBIAS")


roc.df <- data.frame(matrix(ncol = 5, nrow = 0))
colnames(roc.df) <- c("Study_ID", "DEBIAS", "Permutation", "sensitivities", "specificities")



png(paste("./output/",output,"/ROC_histograms/pre_DEBIAS-M_RF_lognorm_ROC_", IDs[i], ".png", sep=""))#, height = 24, width = 24)
# par(mar=c(3,3,1,0))#, mfrow=c(2,2))


training <- filter(lognorm_out, Study_ID != IDs[i])
training <- training[, c(2, 4:length(training))] # this is okay because case and ID columns are removed.
testing <- filter(lognorm_out, Study_ID == IDs[i])
testing <- testing[, c(2, 4:length(testing))]

## set seed and run rf
set.seed(100)
RF_fit <- randomForest(Phenotype~., method = "class", data = training)

## predictions
set.seed(100)    
RF_pred <- predict(RF_fit, testing, type = "prob")

## compute ROC      
rf_roc <- roc(testing[,1], RF_pred[,1])

## add AUC from ROC to AUC df
auc.df[nrow(auc.df) + 1,] = c(IDs[i], auc(rf_roc), FALSE, FALSE)

## add ROC to ROC df
df <- data.frame(Study_ID = IDs[i], DEBIAS = FALSE, Permutation = 0, sensitivities = rf_roc$sensitivities, specificities = rf_roc$specificities)
roc.df <- rbind(roc.df, df)


## plot ROC of actual data
p <- plot(rf_roc, add = FALSE, col = "red", print.auc = TRUE)
phen <- filter(phenos, ID == IDs[i])
phen <- phen[1,2]
title(paste("Training without: ", phen, sep=""), line = + 2.5, cex.main=1.5)
 
 ## preform permutations     
 for(j in 1:permutations){
     ## permutate traing and testing labels
     set.seed(100)
     training$Phenotype <- sample(training$Phenotype)
     set.seed(100)
     testing$Phenotype <- sample(testing$Phenotype)
     ## do random forest
     set.seed(100)
     RF_fit <- randomForest(Phenotype~., method = "class", data = training)
     RF_pred <- predict(RF_fit, testing, type = "prob")
     rf_roc <- roc(testing[,1], RF_pred[,1])

     ## plot and add data to AUC and ROC dfs
     p <- plot(rf_roc, print.auc=FALSE, add = TRUE)

     auc.df[nrow(auc.df) + 1,] = c(IDs[i], auc(rf_roc), TRUE, FALSE)

     
     df <- data.frame(Study_ID = IDs[i], DEBIAS = TRUE, Permutation = j, sensitivities = rf_roc$sensitivities, specificities = rf_roc$specificities)
     roc.df <- rbind(roc.df, df)

     print(paste(j, " done", sep=""))
     }
p

dev.off()  

auc.df$AUC <- as.numeric(auc.df$AUC)

png(paste("./output/",output,"/ROC_histograms/pre_DEBIAS-M_RF_lognorm_histogram_", IDs[i], ".png", sep=""))

a <- auc.df[auc.df$Permutation == FALSE,]$AUC
samp <- auc.df[auc.df$Permutation == TRUE,]$AUC
print("samp")
print(samp)
print(auc.df)
z = (a-mean(samp))/(sd(samp)/sqrt(1))
print(z)
for.pval = pnorm(z, lower.tail = FALSE)

g <- ggplot() + geom_histogram(data = filter(auc.df, Permutation == TRUE), aes(x = AUC), bins = 40) +
  geom_vline(filter(auc.df, Permutation == FALSE), mapping = aes(xintercept=AUC), color = "cornflowerblue") +
  labs(title = paste("Training without: ", phen, sep=""), y = "count") +
  annotate("label", x=min(auc.df$AUC)+.01, y=5, size = 3, label = paste("p= ", signif(for.pval, digits=3), sep="")) +
  scale_y_continuous(expand = expansion(mult = c(0, .1))) 


print("done")  

print(g)

dev.off()  


print(paste(i, "of", length(IDs), " done.", IDs[i]))

#### Write to CSV files ####
AUC_filename <- paste("./output/",output,"/AUCs/builtenv_AUCs.csv",sep="")
pval_filename <- paste("./output/",output,"/AUCs/builtenv_AUC_pvals.csv",sep="")
ROC_filename <- paste("./output/",output,"/AUCs/builtenv_ROCs.csv",sep="")


write.csv(auc.df, paste("./output/",output,"/AUCs/builtenv_pre_DEBIAS_",IDs[i],"_AUCs.csv",sep=""), row.names = FALSE)
write.csv(roc.df, paste("./output/",output,"/AUCs/builtenv_pre_DEBIAS_",IDs[i],"_ROCs.csv",sep=""), row.names = FALSE)

## AUC
if(file.exists(AUC_filename)){
  all <- read.csv(AUC_filename)
  all <- rbind(all, auc.df)
  write.csv(all, AUC_filename, row.names = FALSE)
}else{(write.csv(auc.df, AUC_filename, row.names = FALSE))}


## ROC
if(file.exists(ROC_filename)){
  all <- read.csv(ROC_filename)
  all <- rbind(all, roc.df)
  write.csv(all, ROC_filename, row.names = FALSE)
}else{(write.csv(roc.df, ROC_filename, row.names = FALSE))}


## pvals
pval.df <- data.frame(Study_ID = IDs[i], pval = for.pval, DEBIAS = FALSE)


if(file.exists(pval_filename)){
  all <- read.csv(pval_filename)
  all <- rbind(all, pval.df)
  write.csv(all, pval_filename, row.names = FALSE)
}else{(write.csv(pval.df, pval_filename, row.names = FALSE))}

print("done writing to CSVs")
