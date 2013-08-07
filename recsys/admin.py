from django.contrib import admin
from recsys.models import *

class ProductAdmin(admin.ModelAdmin):
    pass
admin.site.register(Product, ProductAdmin)


class CartAdmin(admin.ModelAdmin):
    pass
admin.site.register(Cart, CartAdmin)


class RecommendationAdmin(admin.ModelAdmin):
    pass
admin.site.register(Recommendation, RecommendationAdmin)
