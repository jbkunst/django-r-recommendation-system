# -*- coding: utf-8 -*-
from django.template import RequestContext
from django.contrib.auth.decorators import login_required
from django.http import HttpResponse
from django.shortcuts import render_to_response, get_object_or_404, redirect
from django.conf import settings
from django.utils import simplejson
import os
import subprocess
import datetime


def modelo_asistencia(request):
	return render_to_response('modelo_asistencia_form.html', locals(), context_instance=RequestContext(request))
	
	
def asistencia_prob(request):
	qdict = request.GET
	return HttpResponse(simplejson.dumps(runRModelAsistencia(qdict), sort_keys=False),mimetype='application/json')
	

def runRModelAsistencia(qdict):
	# print qdict
	systemPath = os.path.dirname(os.path.dirname( __file__ ))
	RScriptCmd = "Rscript"  #Rscript debe estar en el Path
	Rfilepath = os.path.join(systemPath, 'r', 'script_asistencia.R')
	Rargs = "--vanilla"
	functionArgs1 = qdict['erdat']
	functionArgs2 = qdict['espagrupadora']
	functionArgs3 = qdict['canal']
	functionArgs4 = qdict['edad']
	functionArgs5 = qdict['aseguradora']
	functionArgs6 = os.path.join(systemPath, 'r', 'nnetmin_asistencia.RData')

	# retcode = subprocess.call([RScriptCmd, Rargs, Rfilepath, functionArgs1, functionArgs2, functionArgs3, functionArgs4, functionArgs5, functionArgs6], shell=False)
	output = subprocess.Popen([RScriptCmd, Rargs, Rfilepath, functionArgs1, functionArgs2, functionArgs3, functionArgs4, functionArgs5, functionArgs6], stdout=subprocess.PIPE).stdout.read()
	output = output.replace("[1] ", "").replace("\n\r", "")
	# print output
	# print qdict
	qdict = qdict.dict()
	qdict['prob'] = float(output)
	qdict['date'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	return qdict


def modelo_captacion(request):
	return render_to_response('modelo_captacion_form.html', locals(), context_instance=RequestContext(request))
	
	
def captacion_prob(request):
	qdict = request.GET
	return HttpResponse(simplejson.dumps(runRModelCaptacion(qdict), sort_keys=False),mimetype='application/json')
	

def runRModelCaptacion(qdict):
	systemPath = os.path.dirname(os.path.dirname( __file__ ))
	RScriptCmd = "Rscript"  #Rscript debe estar en el Path
	Rfilepath = os.path.join(systemPath, 'r', 'script_captacion.R')
	Rargs = "--vanilla"
	functionArgs1 = qdict['espagrupadora']
	functionArgs2 = qdict['edad']
	functionArgs3 = os.path.join(systemPath, 'r', 'nnetmin_captacion.RData')

	# retcode = subprocess.call([RScriptCmd, Rargs, Rfilepath, functionArgs1, functionArgs2, functionArgs3], shell=False)
	output = subprocess.Popen([RScriptCmd, Rargs, Rfilepath, functionArgs1, functionArgs2, functionArgs3], stdout=subprocess.PIPE).stdout.read()
	output = output.replace("[1] ", "").replace("\n\r", "")
	# print qdict
	# print output
	qdict = qdict.dict()
	qdict['prob'] = float(output)
	qdict['date'] = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")
	return qdict