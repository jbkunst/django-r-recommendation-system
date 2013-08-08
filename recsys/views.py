# -*- coding: utf-8 -*-
from django.template import RequestContext
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404, redirect
from recsys.forms import *


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
	rec = [ str(i) for i in Recommendation.objects.filter(buy__pk__in=prods).values_list('rec__name', flat = True)]

	def remove_values_from_list(the_list, val):
		return [value for value in the_list if value != val]

	for p in prods:
		rec  = remove_values_from_list(rec, Product.objects.get(pk=p).name)

	from collections import Counter
	c = Counter(rec).most_common()
	data = [ i[0] for i in c]
	
	
	return HttpResponse(simplejson.dumps(data), mimetype='application/json')