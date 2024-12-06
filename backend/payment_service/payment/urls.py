# urls.py
from django.urls import path
from . import views

urlpatterns = [
    path('create/', views.create_payment, name='create_payment'),
    path('callback/', views.payment_callback, name='payment_callback'),
    path('notify/', views.payment_notify, name='payment_notify'),
]
