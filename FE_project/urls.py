from django.urls import path

from . import views

app_name = 'FE_project'
urlpatterns = [
    path('', views.fe_project, name='fe_project'),
]