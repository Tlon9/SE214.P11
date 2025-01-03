# urls.py
from django.urls import path
from . import views
from . import apis

urlpatterns = [
    path('create/', apis.CreatePayment.as_view(), name='create_payment'),
    path('history/', apis.GetHistory.as_view(), name='get_history'),
    path('callback/', views.payment_callback, name='payment_callback'),
    path('notify/', apis.payment_notify, name='payment_notify'),
    path('status/<str:transaction_id>/', apis.payment_status, name='payment_status'),
    path('transaction/<str:transaction_id>/', apis.get_transaction, name='get_transaction'),
    path('qr_code', apis.get_qr_code, name='get_qr_code'),
    path('notification/', apis.Notification.as_view(), name='get_notification'),
    path('new_user', apis.check_new_user, name='new_user'),
]
