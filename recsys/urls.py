from django.conf.urls import patterns, include, url
from django.conf import settings
# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()


urlpatterns = patterns('',
	(r'^admin/', include(admin.site.urls)),
	
	url(r'^buy/$', 'recsys.views.buy', name = 'buy'),
	url(r'^recommned/$', 'recsys.views.recommned', name = 'recommned'),

	(r'^media/(?P<path>.*)$', 'django.views.static.serve',{'document_root':  settings.MEDIA_ROOT,'show_indexes': True}),
	(r'^static/(?P<path>.*)$', 'django.views.static.serve',{'document_root':  settings.STATIC_ROOT,'show_indexes': True}),
)
