from django.urls import path

from . import views

app_name = 'Main'
urlpatterns = [
    path('', views.index, name='index'),
    path('contact_submit/', views.contact_submit, name='contact_submit'),
    path('<int:msg_sent_bool>', views.index, name='contact_submitted'),
]