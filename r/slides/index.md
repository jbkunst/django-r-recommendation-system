---
title       : Django+R
subtitle    : Una breve introducción de que podemos hacer de entrete
author      : Joshua Kunst
job         : Analyst at Foris
date        : Hoy!
biglogo     : logo.png
framework   : io2012        # {io2012, html5slides, shower, dzslides, ...}
highlighter : highlight.js  # {highlight.js, prettify, highlight}
hitheme     : tomorrow      # 
widgets     : []            # {mathjax, quiz, bootstrap}
mode        : selfcontained # {standalone, draft}


---
## Aclaración
<br>
Las opiniones vertidas en esta presentación son de exclusiva responsabilidad del autor de esta
y representan necesariamente el pensamiento del mismo.



---
## ¿Por qué la presentación?
<br>
> 1. Porque se un algo R

> 2. Se un poco menos de Django

> 3. Pero no se nada de como servirlo en un servidor



---  
## ¿Que haremos?
<br>
 
> 1. Sistema de recomendación

> 2. Existen productos y compras (de productos!)

> 3. Al ir realizando una nueva compra nos recomendará que productos podemos comprar de acuerdo al historial de compras ya realizadas


---  


---  
## La Receta
<br>
 
> 1. Empezar a pre-horenear la aplicación en django. Crear el modelo de base de datos, vistas, forularios

> 2. Ir cocinando la funciones de R para poder, a patir de cierta cantidad de compras, generar nuevas reglas y actualizar la tabla de recomendaciones

> 3. Mezclar lo anterior y hornearlo a un servidor

> 4. Servirlo


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
## Las Vistas
<br>

```
def buy(request):
  if request.method == 'POST':
		form = BuyForm(request.POST) 
		if form.is_valid():
			cart = form.save()
			return redirect(buy)
	else:
		form = BuyForm()
	return render_to_response('buy.html', locals(), context_instance=RequestContext(request))

def recommned(request):
	from django.utils import simplejson
	prods =  request.GET.getlist('products')

	data = [ i[0] for i in Product.objects.filter(pk__in=prods).order_by('?').values_list('name')]


	# order_by('?')
	return HttpResponse(simplejson.dumps(data), mimetype='application/json')
```





---  
## ¿Cómo generar las reglas?
<br>

 
> 1. Con R :P y el paquete `arules`

> 2. Extraer las transacciones de la base de datos (el modelo `Cart`) 

> 3. Generar y parsear las reglas

> 4. Actualizar la tabla `Recommendation`


