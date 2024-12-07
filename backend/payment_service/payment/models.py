# models.py
from django.db import models
from db_connection import db

class MomoCreatePaymentResponse(models.Model):
    request_id = models.CharField(max_length=255)
    error_code = models.IntegerField()
    order_id = models.CharField(max_length=255)
    message = models.TextField()
    local_message = models.TextField()
    request_type = models.CharField(max_length=50)
    pay_url = models.URLField()
    signature = models.TextField()
    qr_code_url = models.URLField(blank=True, null=True)
    deeplink = models.URLField(blank=True, null=True)
    deeplink_web_in_app = models.URLField(blank=True, null=True)

class MomoExecuteResponse(models.Model):
    order_id = models.CharField(max_length=255)
    amount = models.CharField(max_length=20)
    full_name = models.CharField(max_length=255)
    order_info = models.TextField()

transaction_collection = db["transaction"]