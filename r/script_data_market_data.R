rm(list=ls())
# install.packages("arules")

library(arules)
library(plyr)
library(stringr)

data(Groceries)
Groceries
str(Groceries)

prods <- as.character(gsub(" ", "_" , str_trim(Groceries@itemInfo$labels)))
prod2 <- str_trim(Groceries@itemInfo$labels)


dim(Groceries@data)
str(Groceries@data)
str(as.matrix(Groceries@data))


mtx <- t(as.matrix(Groceries@data))
head(mtx)

txn <- ldply(seq(nrow(mtx)), function(row){
  d <- data.frame(id_transaction = row, prod = prods[mtx[row,]])
  # d <- subset(d, prod != "whole_milk")
  d
  
}, .progress="text")

head(txn, 60)
write.table(txn, file="tscs.txt", sep="\t", row.names=FALSE, col.names=FALSE, quote=FALSE)


txn <- read.transactions(file="tscs.txt", rm.duplicates= FALSE, format="single",sep="\t", cols =c(1,2))
txn
str(txn)


itemFrequencyPlot(txn)
basket_rules <- apriori(txn,parameter = list(supp = 0.025, conf = 0.05, target = "rules"))



# Check the generated rules using inspect
inspect(basket_rules)
write(basket_rules)
#If huge number of rules are generated specific rules can read using index
inspect(basket_rules[1]);



#To visualize the item frequency in txn file
itemFrequencyPlot(txn);
#To see how the transaction file is read into txn variable.
inspect(txn)





