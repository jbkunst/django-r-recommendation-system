from django.db import models

class Product(models.Model):
	name = models.CharField(max_length=30)
	
	def __unicode__(self):
		return u'%s' % (self.name)

class Cart(models.Model):
	datetime = models.DateTimeField(auto_now=True)
	products = models.ManyToManyField(Product)

	def __unicode__(self):
		return u'%s - %s' % (self.pk, self.datetime)

class Recommendation(models.Model):
  buy = models.ManyToManyField(Product, related_name="buy+")
  rec = models.ManyToManyField(Product, related_name="rec+")
