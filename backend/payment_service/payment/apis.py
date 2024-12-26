import os
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .services import MomoService
from .models import transaction_collection
from db_connection import redis_client
import json
import requests
from django.utils.timezone import now
from threading import Timer
from django.conf import settings
from django.http import FileResponse, HttpResponseNotFound
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

class CreatePayment(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = json.loads(request.body)
        momo_service = MomoService()
        response = None
        user = request.user

        # Call MoMo API
        if data.get('type') == 'qr':
            response = momo_service.create_qr_payment(data)
        elif data.get('type') == 'atm':
            response = momo_service.create_atm_payment(data)
        
        if response:
            transaction_id = response.get('orderId')
            # Save the transaction with PENDING status
            transaction = {
                '_id': transaction_id,
                'user_id': user.id,
                'service': data['service'],
                'info': data['info'],
                'amount': data['amount'],
                'type': data['type'],
                'status': 'PENDING',
                'created_at': now(),
            }
            transaction_collection.insert_one(transaction)

            # Set a timeout to auto-update after 50 seconds
            Timer(10, auto_update, args=(transaction_id,)).start()
            if data.get('type') == 'atm':
                return JsonResponse({'url': response['payUrl'], 'transaction_id': transaction_id})
            else:
                return JsonResponse({'url': 'QR_code','transaction_id': transaction_id})

        return JsonResponse({'error': response.get('message', 'Failed to create payment')})
    
class GetHistory(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        cache_key = f"user_history:{user.id}"  # Unique key for user history

        # Check if data exists in Redis
        cached_data = redis_client.get(cache_key)

        if cached_data:
        # Data exists, return cached data
            transactions = json.loads(cached_data)
            return JsonResponse(transactions, safe=False)
        transactions = transaction_collection.find({'user_id': user.id}, {'user_id': 0, 'info': 0}).sort('created_at', -1)

        transactions_list = list(transactions)
        for transaction in transactions_list:
            transaction['created_at'] = transaction['created_at'].isoformat()
         # Cache the result in Redis
        redis_client.set(cache_key, json.dumps(transactions_list), ex=60)  # Cache for 10 minutes

        return JsonResponse(list(transactions_list), safe=False)


def get_transaction(request,transaction_id):
    transaction = transaction_collection.find_one({'_id': transaction_id}, {'_id': 0,'type': 0,'status': 0})
    return JsonResponse(transaction)
   
def get_qr_code(request):
    transaction_id = request.GET.get('transactionId')
    service = request.GET.get('service')
    # print('transaction_id:',transaction_id)
    # print('service:',service)
    if service == 'flight':
    # Construct the file path
        file_name = f"flight_{transaction_id}.png"  # Assuming QR codes are saved as PNG
    elif service == 'hotel':
        file_name = f"hotel_{transaction_id}.png"
    else:
        file_name = f"qr_{transaction_id}.png"
    file_path = os.path.join(settings.MEDIA_ROOT, file_name)  # Adjust subdirectory as needed

    # Check if the file exists
    if os.path.exists(file_path):
        # Serve the file as a response
        return FileResponse(open(file_path, 'rb'), content_type='image/png')
    else:
        # File not found
        return HttpResponseNotFound(f"QR code for transaction {transaction_id} not found.")

   
def auto_update(transaction_id):
    # Check the transaction status in your database
    transaction = transaction_collection.find_one({'_id': transaction_id})
    if transaction['status'] == 'PENDING':
        # Call the payment_callback endpoint
        callback_url = f"http://127.0.0.1:8080/payment/callback/?service={transaction['service']}&orderId={transaction_id}&message=Successful.&orderInfo={transaction['info']}"
        try:
            requests.get(callback_url)
        except Exception as e:
            print(f"Error triggering auto-update for transaction {transaction_id}: {e}")

def payment_status(request, transaction_id):
    # Retrieve the transaction from the database
    transaction = transaction_collection.find_one({'_id': transaction_id})
    status = transaction['status'] if transaction else 'NOT_FOUND'
    return JsonResponse({'status': status})

@csrf_exempt
def payment_notify(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        # Process the notification data
        return JsonResponse({'status': 'Notification received', 'data': data})