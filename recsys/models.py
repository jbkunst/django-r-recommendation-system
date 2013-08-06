from django.db import models

class Product(models.Model):
	name = models.CharField(max_length=30)
	
	def __unicode__(self):
		return u'%s' % (self.name)

class Cart(models.Model):
	datetime = models.DateTimeField(auto_now=True)
	product = models.ManyToManyField(Product)

	def __unicode__(self):
		return u'%s - %s' % (self.pk, self.datetime)
