## A simple recommendation system with Django and R

![Alt text](/static/images/demo.jpg)


### This mini app is the combination of:

- A Django app for make purchases (via form) and recommend product (via jquery GET).
- A sqlite3 database to keep the information of products, carts and recommendations
- A R script for generate new recommendations with the `arules` package.

### How it works:

- Every time you add a product (or delete it) the software recommend according the existing rules.
- Every `n` purchases the software generate new rules with the last `m` purchases and update in the database.

### The models.py
```
class Product(models.Model):
  name = models.CharField(max_length=30)

class Cart(models.Model):
	datetime = models.DateTimeField(auto_now=True)
	products = models.ManyToManyField(Product)

class Recommendation(models.Model):
  buy = models.ManyToManyField(Product, related_name="buy+")
  rec = models.ManyToManyField(Product, related_name="rec+")
```


### The Views.py

```
def buy(request):
  if request.method == 'POST':
		form = BuyForm(request.POST) 
		if form.is_valid():
			cart = form.save()
			if Cart.objects.all().count() % 10 == 0:
				generate_new_rules()
			return redirect(buy)
	else:
		form = BuyForm()
	return render_to_response('buy.html', locals(), context_instance=RequestContext(request))

def recommned(request):
	prods =  request.GET.getlist('products')
	rec = [ str(i) for i in Recommendation.objects.filter(buy__pk__in=prods).values_list('rec__name', flat = True)]
	for p in prods:
		rec  = remove_values_from_list(rec, Product.objects.get(pk=p).name)
	c = Counter(rec).most_common()
	data = [ i[0] for i in c]
	return HttpResponse(simplejson.dumps(data), mimetype='application/json')
```

### The function to call the magic

It has a windows path (sorry! :P).

```
def generate_new_rules():
	RScriptCmd = u"C:\\Program Files\\R\\R-3.0.0\\bin\\x64\Rscript.exe"
	Rfilepath = os.path.join(settings.PROJECT_ROOT, 'r', 'generate_new_rules.R')
	Rargs = "--vanilla"
	command = [RScriptCmd, Rfilepath, Rargs]
	output = subprocess.Popen(command, stdout=subprocess.PIPE).stdout.read()
	print output
	return True
```

### The simply magic function

Simply take the `product` and `cart` tables, then run the apriori algorithm and update the 
`recommendation`s tables with the recommendations.


```
add_recommentation <- function(id1 = c(1,2), id2 = c(3,4)){

  db <- dbConnect(SQLite(), dbname="data.db")
  
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
  
  db <- dbConnect(SQLite(), dbname="data.db")
  
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
  
  rules <- apriori(txn2,  parameter = list(supp = 0.03, conf = 0.03))
  rules <- apriori(txn2,  parameter = list(supp = 0.01, conf = 0.01))

  
  write(rules, file = "rules.txt", quote=FALSE, sep = "\t", col.names = TRUE, row.names = FALSE)
  rules <- read.table("rules.txt", sep = "\t", header=TRUE, stringsAsFactors=FALSE)
  rules
  message(rules)
  print(rules)
  dbGetQuery(db, "delete from recsys_recommendation")
  dbGetQuery(db, "delete from recsys_recommendation_buy")
  dbGetQuery(db, "delete from recsys_recommendation_rec")
  
  for(rule in rules$rules){
    buy <- strsplit(rule, " => ")[[1]][1]
    rec <- strsplit(rule, " => ")[[1]][2]
    
    if(buy != "{}") {
      buy <- unlist(strsplit(gsub("^\\{|\\}$", "", buy), "\\,"))
      rec <- unlist(strsplit(gsub("^\\{|\\}$", "", rec), "\\,"))
      add_recommentation(subset(prods, name %in% buy)$id, subset(prods, name %in% rec)$id)      
    }
  }
}

generate_recommentation()
```



