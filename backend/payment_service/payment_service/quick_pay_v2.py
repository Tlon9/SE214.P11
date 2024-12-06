import hmac
import hashlib
import json
import base64
import requests
from uuid import uuid4

def create_signature(data: dict, secret_key: str):
    # Construct the raw data string in the exact order
    raw_signature = '&'.join(f'{key}={data[key]}' for key in sorted(data.keys()))
    print("raw_signature:", raw_signature)  # Log for debugging
    # Compute HMAC-SHA256
    signature = hmac.new(secret_key.encode('utf-8'), raw_signature.encode('utf-8'), hashlib.sha256).hexdigest()
    return signature

def create_payment_momo(request):
    momo_api = {
        "partnerCode": "MOMO",
        "accessKey": "F8BBA842ECF85",
        "secretKey": "K951B6PE1waDMi640xX08PD3vg6EkVlz",
        "ipnUrl": "http://localhost:8000/payment/notify/",
        "redirectUrl": "http://localhost:8000/payment/callback/",
        "partnerName": "Test",
        "storeId": "MoMoTestStore"
    }
    
    order_info = {
        "amount": 30000,  # Amount in VND
        "orderInfo": "Pay with MoMo ATM",
        "extraData": base64.b64encode(json.dumps({"email": "abc@gmail.com"}).encode()).decode(),
    }
    
    # Unique identifiers
    order_id = str(uuid4())
    request_id = str(uuid4())
    
    # Payload
    payload = {
        "accessKey": momo_api['accessKey'],
        "amount": order_info['amount'],
        "extraData": order_info['extraData'],
        "ipnUrl": momo_api['ipnUrl'],
        "orderId": order_id,
        "orderInfo": order_info['orderInfo'],
        "partnerCode": momo_api['partnerCode'],
        "redirectUrl": momo_api['redirectUrl'],
        "requestId": request_id,
        "requestType": "payWithATM",
    }
    
    # Signature
    payload["signature"] = create_signature(payload, momo_api['secretKey'])
    
    # Make API Request
    response = requests.post("https://test-payment.momo.vn/v2/gateway/api/create", json=payload)
    return response.json()



# Usage example
response = create_payment_momo(None)
print(response)
