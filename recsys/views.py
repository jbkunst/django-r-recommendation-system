# -*- coding: utf-8 -*-
from django.template import RequestContext
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404, redirect
from recsys.forms import *
from django.utils import simplejson
from collections import Counter
import settings
import os
import subprocess

def generate_new_rules():
	# "C:\Program Files\R\R-2.15.2\bin\x64\Rscript.exe"
	RScriptCmd = u"C:\\Program Files\\R\\R-3.0.0\\bin\\x64\Rscript.exe"
	Rfilepath = os.path.join(settings.PROJECT_ROOT, 'r', 'generate_new_rules.R')
	Rargs = "--vanilla"
	command = [RScriptCmd, Rfilepath, Rargs]
	print command
	output = subprocess.Popen(command, stdout=subprocess.PIPE).stdout.read()
	print output
	return True

def remove_values_from_list(the_list, val):
	return [value for value in the_list if value != val]

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