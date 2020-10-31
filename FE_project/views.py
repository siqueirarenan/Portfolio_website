from django.shortcuts import render

def fe_project(request):
    context = {}
    return render(request,'FE_project/index.html',context)