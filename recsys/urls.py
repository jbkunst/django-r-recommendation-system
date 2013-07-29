from django.conf.urls import patterns, include, url
from django.conf import settings

# Uncomment the next two lines to enable the admin:
# from django.contrib import admin
# admin.autodiscover()

urlpatterns = patterns('',
	#url(r'^modelo-asistencia/$', 'recsys.views.modelo_asistencia', name = 'modelo_asistencia'),
	#url(r'^asistencia-prob/$', 'recsys.views.asistencia_prob', name = 'asistencia_prob'),


urlpatterns += patterns('',
	url(r'^media/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.MEDIA_ROOT}),
	url(r'^static/(?P<path>.*)$', 'django.views.static.serve', {'document_root': settings.STATIC_ROOT}),
)
