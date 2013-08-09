---
title       : Django+R
subtitle    : y una oportunidad para salir del closet (uyyy!)
author      : Joshua Kunst
job         : Analyst at Foris
date        : Hoy!
logo     : logo_small.png
biglogo     : logo.png
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}


---
## Aclaración
<br>
<br>
<br>
<br>
<small>
Las opiniones vertidas en esta presentación son de exclusiva responsabilidad del autor de esta
y representan necesariamente el pensamiento del mismo.
</small>



---
## ¿Por qué la presentación? I 


---
## ¿Por qué la presentación? II

---
## ¿Por qué la presentación? III
<center>
![](assets/img/batman.jpg)
</center>


---  
## ¿Que haremos?





---  
## La Receta


---  
## El Modelo
<br>

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



---  
## Las Vistas I

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
```

---  
## Las Vistas II
```
def recommned(request):
	prods =  request.GET.getlist('products')
	rec = [ str(i) for i in Recommendation.objects.filter(buy__pk__in=prods).values_list('rec__name', flat = True)]
	for p in prods:
		rec  = remove_values_from_list(rec, Product.objects.get(pk=p).name)
	c = Counter(rec).most_common()
	data = [ i[0] for i in c]
	return HttpResponse(simplejson.dumps(data), mimetype='application/json')
```





---  
## ¿Cómo generar las reglas?




---  
## ¿Queremos verlo?

<br><br><br><br><br><br>
(Ustedes dicen seeeee!!)

<br><br>
...(Luego dicen Ohhhhh)



---  
## Agradecimientos
<br>
> 1. Foris

> 2. (por ende) Ustedes

> 3. Django

> 4. R

> 5. R
