# -*- coding: utf-8 -*-
from django.forms import ModelForm
from recsys.models import *

class BuyForm(ModelForm):
	class Meta:
		model = Cart



	
	
