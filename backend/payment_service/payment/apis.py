import os
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .services import MomoService
from .models import transaction_collection
import json
import requests
from django.utils.timezone import now, timedelta
from threading import Timer
from django.conf import settings
from django.http import FileResponse, HttpResponseNotFound

@csrf_exempt
def create_payment(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        momo_service = MomoService()
        response = None

        # Call MoMo API
        if data.get('type') == 'qr':
            response = momo_service.create_qr_payment(data)
        elif data.get('type') == 'atm':
            response = momo_service.create_atm_payment(data)
        
        if response and response.get('payUrl'):
            transaction_id = response.get('orderId')

            # Save the transaction with PENDING status
            transaction = {
                '_id': transaction_id,
                'info': data['info'],
                'amount': data['amount'],
                'type': data['type'],
                'status': 'PENDING',
                'created_at': now(),
            }
            transaction_collection.insert_one(transaction)

            # Set a timeout to auto-update after 15 seconds
            Timer(5, auto_update, args=(transaction_id,)).start()

            return JsonResponse({'url': response['payUrl'], 'transaction_id': transaction_id})

        return JsonResponse({'error': response.get('message', 'Failed to create payment')})
    return JsonResponse({'error': 'Invalid request method'})


def get_transaction(request,transaction_id):
    transaction = transaction_collection.find_one({'_id': transaction_id}, {'_id': 0,'type': 0,'status': 0})
    return JsonResponse(transaction)
   
def get_qr_code(request, transaction_id):
    # Construct the file path
    file_name = f"flight_{transaction_id}.png"  # Assuming QR codes are saved as PNG
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
        callback_url = f"http://127.0.0.1:8080/payment/callback/?orderId={transaction_id}&message=Successful.&orderInfo={transaction['info']}"
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