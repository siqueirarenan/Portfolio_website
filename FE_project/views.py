from django.shortcuts import render
from django.http import HttpResponse
from django.template import Context
from django.views.decorators.clickjacking import xframe_options_exempt
from django_ajax.decorators import ajax
from django.views.decorators.csrf import csrf_exempt

def fe_project(request):
    context = {}
    return render(request,'FE_project/index.html',context)

def loads(request):
    return render(request,'FE_project/loads.html')

def boundaries(request):
    return render(request,'FE_project/boundaries.html')

@ajax
@csrf_exempt
def run_FE_project(request):
    Emodul = request.POST['Emodul']
    Poisson = request.POST['Poisson']
    mbb_width = request.POST['mbb_width']
    mbb_height = request.POST['mbb_height']
    mbb_length = request.POST['mbb_length']
    eleSize = request.POST['eleSize']
    Forces = request.POST['Forces']
    Boundaries = request.POST['Boundaries']

    return {'v_test': Emodul}

