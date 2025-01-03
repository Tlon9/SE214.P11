import os
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .services import MomoService
from .models import transaction_collection, notification_collection
from db_connection import redis_client
import json
import requests
from django.utils.timezone import now
from bson import ObjectId
from threading import Timer
from django.conf import settings
from django.http import FileResponse, HttpResponseNotFound
from rest_framework.views import APIView
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
# from channels.layers import get_channel_layer
# from asgiref.sync import async_to_sync

class CreatePayment(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        data = json.loads(request.body)
        momo_service = MomoService()
        response = None
        user = request.user
        access_token = request.headers.get('Authorization').split(' ')[1]
        use_score = request.GET.get('use_score')
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
            Timer(2, auto_update, args=(transaction_id, access_token, use_score)).start()
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

   
def auto_update(transaction_id, access_token, use_score):
    # Check the transaction status in your database
    transaction = transaction_collection.find_one({'_id': transaction_id})
    if transaction['status'] == 'PENDING':
        # Call the payment_callback endpoint
        callback_url = f"http://127.0.0.1:8080/payment/callback/?use_score={use_score}&service={transaction['service']}&orderId={transaction_id}&message=Successful.&orderInfo={transaction['info']}"
        headers = {'Authorization': f'Bearer {access_token}'}
        try:
            requests.get(callback_url, headers=headers)
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
    
class Notification(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user_id = request.user.id
        response_type = request.query_params.get('type', 'list')  # Default to 'list'

        if response_type == 'count':  # Return unread count
            unread_count = notification_collection.count_documents({'user_id': user_id, 'status': 'UNREAD'})
            return JsonResponse({'unread_count': unread_count})

        # Default: Return the notification list
        notifications = notification_collection.find({'user_id': user_id}).sort([('status', -1), ('created_at', -1)])
        notifications_list = list(notifications)
        for notification in notifications_list:
            notification['_id'] = str(notification['_id'])
        for notification in notifications_list:
            notification['created_at'] = notification['created_at'].isoformat()
        return JsonResponse(notifications_list, safe=False)

    def put(self, request):
        user_id = request.user.id
        notification_id = request.query_params.get('notification_id')
        print('notification_id:',notification_id)
        notification_collection.update_one(
            {'_id': ObjectId(notification_id), 'user_id': user_id},
            {'$set': {'status': 'READ'}}
        )
        return JsonResponse({'message': 'Notification updated successfully'})

    def delete(self, request):
        user_id = request.user.id
        notification_id = request.data.get('notification_id')
        notification_collection.delete_one({'_id': notification_id, 'user_id': user_id})
        return JsonResponse({'message': 'Notification deleted successfully'})

    def post(self, request):
        user_id = request.user.id
        transaction_id = request.GET.get('transaction_id')
        transaction = transaction_collection.find_one({'_id': transaction_id})
        notification = {
            'user_id': user_id,
            'transaction_id': transaction_id,
            'service': transaction['service'],
            'info': f'Thanh toán thành công cho dịch vụ {transaction['service']} với số tiền ${transaction['amount']}',
            'created_at': transaction['created_at'],
            'status': 'UNREAD'
        }
        notification_collection.insert_one(notification)

        # Send notification via WebSocket
        # channel_layer = get_channel_layer()
        # print(channel_layer.group_send)
        # async_to_sync(channel_layer.group_send)(
        #     f"user_{transaction['user_id']}",
        #     {
        #         "type": "send_notification",
        #         "data": notification,
        #     }
        # )

        return JsonResponse({"message": "Notification sent successfully"})

def check_new_user(request):
    user_id = request.GET.get('user_id')
    is_new_user = transaction_collection.count_documents({'user_id': int(user_id)}) == 0
    return JsonResponse({'is_new_user': is_new_user})
