# views.py
from django.http import JsonResponse, HttpResponseRedirect
from django.views.decorators.csrf import csrf_exempt
from .services import MomoService
import json

@csrf_exempt
def create_payment(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        momo_service = MomoService()
        if data.get('type') == 'qr':
            response = momo_service.create_qr_payment(data)
        elif data.get('type') == 'atm':
            response = momo_service.create_atm_payment(data)
        if response.get('payUrl'):
            return JsonResponse({'url': response['payUrl']})
        return JsonResponse({'error': response.get('message', 'Failed to create payment')})
    return JsonResponse({'error': 'Invalid request method'})

@csrf_exempt
def payment_callback(request):
    if request.method == 'GET':
        params = request.GET
        # Process the callback parameters
        return JsonResponse({'status': 'Callback received', 'params': params})

@csrf_exempt
def payment_notify(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        # Process the notification data
        return JsonResponse({'status': 'Notification received', 'data': data})
