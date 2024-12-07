# urls.py
from django.urls import path
from . import views
from . import apis

urlpatterns = [
    path('create/', apis.create_payment, name='create_payment'),
    path('callback/', views.payment_callback, name='payment_callback'),
    path('notify/', apis.payment_notify, name='payment_notify'),
    path('status/<str:transaction_id>/', apis.payment_status, name='payment_status'),
    path('transaction/<str:transaction_id>/', apis.get_transaction, name='get_transaction'),
    path('qr_code/<str:transaction_id>/', apis.get_qr_code, name='get_qr_code'),
]
