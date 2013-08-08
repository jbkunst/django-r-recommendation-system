rm(list=ls())

if(!require(RSQLite)){ install.packages("RSQLite"); library(RSQLite) }
if(!require(DBI)){ install.packages("DBI"); library(DBI) }
if(!require(plyr)){ install.packages("plyr"); library(plyr) }
if(!require(arules)){ install.packages("arules"); library(arules) }


add_recommentation <- function(id1 = c(1,2), id2 = c(3,4)){

  db <- dbConnect(SQLite(), dbname="../data.db")
  
  recommendation <- dbReadTable(db, "recsys_recommendation")
  if(nrow(recommendation)==0){
    recommendation_id <- 1
  } else {
    recommendation_id <- max(recommendation$id)+1
  }
  
  recommendation_up <- data.frame(id=recommendation_id)
  dbWriteTable(db, "recsys_recommendation", recommendation_up, append=TRUE, row.names = FALSE)
  
  
  recomendation_buy <- dbReadTable(db, "recsys_recommendation_buy")
  if(nrow(recomendation_buy)==0){
    recomendation_buy_id <- 0
  } else {
    recomendation_buy_id <- max(recomendation_buy$id)
  }
  
  recommendation_buy_up <- data.frame(id = recomendation_buy_id + seq(1:length(id1)),
                                      recommendation_id = recommendation_id,
                                      product_id = id1)
  dbWriteTable(db, "recsys_recommendation_buy", recommendation_buy_up, append=TRUE, row.names = FALSE)
  
  
  recomendation_rec <- dbReadTable(db, "recsys_recommendation_rec")
  if(nrow(recomendation_rec)==0){
    recomendation_rec_id <- 0
  } else {
    recomendation_rec_id <- max(recomendation_rec$id)
  }
  
  recommendation_rec_up <- data.frame(id = recomendation_rec_id + seq(1:length(id2)),
                                      recommendation_id = recommendation_id,
                                      product_id = id2)
  dbWriteTable(db, "recsys_recommendation_rec", recommendation_rec_up, append=TRUE, row.names = FALSE)
  
}



generate_recommentation <- function(n_buys= 3000){
  
  db <- dbConnect(SQLite(), dbname="../data.db")
  
  prods <- dbReadTable(db, "recsys_product")
  carts <- dbReadTable(db, "recsys_cart")
  carts <- carts[order(carts$datetime, decreasing=TRUE),]
  carts <- head(carts, n_buys)
  
  txn <- dbReadTable(db, "recsys_cart_products")
  txn <- subset(txn, cart_id %in% carts$id)
  
  txn2 <- ldply(unique(carts$id), function(cart){
    # cart <- sample(unique(carts$id), size = 1)  
    names_prod <- subset(prods, id %in% subset(txn, cart_id == cart)$product_id)$name
    d <- data.frame(t(rep(1, length(names_prod))))
    names(d) <- names_prod
    d
  }, .progress="text")
  
  txn2 <- as.matrix(ifelse(is.na(txn2), 0, 1))
  txn2 <- as(txn2, "transactions")
  
#   rules <- apriori(txn2,  parameter = list(supp = 0.03, conf = 0.03))
  rules <- apriori(txn2,  parameter = list(supp = 0.01, conf = 0.01))
#   rules
#   inspect(rules)
  
  write(rules, file = "rules.txt", quote=FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
  rules <- read.table("rules.txt", sep = "\t", header=TRUE, stringsAsFactors=FALSE)
  rules
  
  dbGetQuery(db, "delete from recsys_recommendation")
  dbGetQuery(db, "delete from recsys_recommendation_buy")
  dbGetQuery(db, "delete from recsys_recommendation_rec")
  
  
  for(rule in rules$rules){
    # rule <- sample(rules$rules, size = 1)
#     rule
    buy <- strsplit(rule, " => ")[[1]][1]
    rec <- strsplit(rule, " => ")[[1]][2]
    
    if(buy != "{}") {
      buy <- unlist(strsplit(gsub("^\\{|\\}$", "", buy), "\\,"))
      rec <- unlist(strsplit(gsub("^\\{|\\}$", "", rec), "\\,"))
      add_recommentation(subset(prods, name %in% buy)$id, subset(prods, name %in% rec)$id)      
    }
  }
}


add_products <- function(){
  data(Groceries)
  db <- dbConnect(SQLite(), dbname="../data.db")
  dbGetQuery(db, "delete from recsys_product")
  items <- Groceries@itemInfo$labels
  prods <- data.frame(id=seq(length(items)), name = items)
  dbWriteTable(db, "recsys_product", prods, append=TRUE, row.names = FALSE)
}


add_transactions <- function(){
  db <- dbConnect(SQLite(), dbname="../data.db")
  data(Groceries)
  transactions <- t(as.matrix(Groceries@data))
  transactions <- ifelse(transactions, 1, 0)
  transactions <- as.data.frame(transactions)
  
  items <- Groceries@itemInfo
  names(transactions) <- items$labels
  
  dbGetQuery(db, "delete from recsys_cart")
  dbGetQuery(db, "delete from recsys_cart_products")
  
  add_transaction <- function(id = c(1,2)){
    db <- dbConnect(SQLite(), dbname="../data.db")
    transaction <- dbReadTable(db, "recsys_cart")
    
    if(nrow(transaction)==0){
      transaction_id <- 1
    } else {
      transaction_id <- max(transaction$id) + 1
    }
    
    transaction_up <- data.frame(id = transaction_id,
                                 datetime = paste(gsub("CLT", "", Sys.time()), ".000000", sep  = ""))
    dbWriteTable(db, "recsys_cart", transaction_up, append=TRUE, row.names = FALSE)
    
    transactions <- dbReadTable(db, "recsys_cart_products")
    
    if(nrow(transactions)==0){
      transactions_id <- 0
    } else {
      transactions_id <- max(transactions$id)
    }
    
    transactions_up <- data.frame(id = transactions_id + seq(1, length(id)),
                                  cart_id = transaction_id,
                                  product_id = id)
    dbWriteTable(db, "recsys_cart_products", transactions_up, append=TRUE, row.names = FALSE)
  }
  
  for(row in 1:nrow(transactions)){
    print(row)
    add_transaction(c(which(transactions[row,]==1)))
  }
  
  
}