from django.urls import path
from django.conf.urls import url

from . import views

app_name = 'FE_project'
urlpatterns = [
    path('', views.fe_project, name='fe_project'),
    url('loads', views.loads ,name='loads'),
    url('boundaries', views.boundaries ,name='boundaries'),
    path('run', views.run_FE_project, name='run'),
]

