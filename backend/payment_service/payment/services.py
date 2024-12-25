# services.py
import hmac
import hashlib
import qrcode
from io import BytesIO
import requests
import uuid
from django.conf import settings
from django.http import JsonResponse

class MomoService:
    @staticmethod
    def compute_hmac_sha256(message, secret_key):
        return hmac.new(
            secret_key.encode('utf-8'),
            message.encode('utf-8'),
            hashlib.sha256
        ).hexdigest()

    def create_qr_payment(self, order_info):
        order_id = str(uuid.uuid4())
        request_id = str(uuid.uuid4())
        save_path = settings.MEDIA_ROOT
        qr_content = f'requestId={request_id}&orderId={order_id}&amount={order_info['amount']}'
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_L,
            box_size=10,
            border=4,
        )
        qr.add_data(qr_content)
        qr.make(fit=True)
        img = qr.make_image(fill='black', back_color='white')
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        file_name = f"qr_{order_id}.png"
        # Save the QR code image to the server
        with open(f"{save_path}/{file_name}", "wb") as f:
            f.write(buffer.getvalue())
        return {'orderId': order_id}
        # momo_api = settings.MOMO_API
        # order_id = str(uuid.uuid4())
        # request_id = str(uuid.uuid4())
        
        # raw_data = (
        #     f"partnerCode={momo_api['PartnerCode']}&accessKey={momo_api['AccessKey']}"
        #     f"&requestId={request_id}&amount={order_info['amount']}&orderId={order_id}"
        #     f"&orderInfo={order_info['info']}&returnUrl={momo_api['ReturnUrl']}"
        #     f"&notifyUrl={momo_api['NotifyUrl']}&extraData="
        # )
        # print("raw_data:",raw_data)
        # signature = self.compute_hmac_sha256(raw_data, momo_api['SecretKey'])

        # payload = {
        #     "partnerCode": momo_api['PartnerCode'],
        #     "accessKey": momo_api['AccessKey'],
        #     "requestType": momo_api['RequestType'],
        #     "notifyUrl": momo_api['NotifyUrl'],
        #     "returnUrl": momo_api['ReturnUrl'],
        #     "orderId": order_id,
        #     "amount": order_info['amount'],
        #     "orderInfo": order_info['info'],
        #     "requestId": request_id,
        #     "extraData": order_info['extraData'],
        #     "signature": signature
        # }
        # print("payload:",payload)
        # return payload
        # # response = requests.post(momo_api['MomoApiUrl'], json=payload)
        # # print(response.json())
        # return response.json()
    
    def create_atm_payment(self, order_info):
        momo_api = settings.MOMO_API
        # Unique identifiers
        order_id = str(uuid.uuid4())
        request_id = str(uuid.uuid4())

        raw_data = (
            f"accessKey={momo_api['AccessKey']}&amount={order_info['amount']}&extraData={order_info['extraData']}"
            f"&ipnUrl={momo_api['IpnUrl']}&orderId={order_id}&orderInfo={order_info['info']}"
            f"&partnerCode={momo_api['PartnerCode']}&redirectUrl={momo_api['ReturnUrl']}"
            f"&requestId={request_id}&requestType=payWithATM"
        )        
        print("raw_data:",raw_data)
        signature = self.compute_hmac_sha256(raw_data, momo_api['SecretKey'])
        # Payload
        payload = {
            "accessKey": momo_api['AccessKey'],
            "amount": order_info['amount'],
            "extraData": order_info['extraData'],
            "ipnUrl": momo_api['IpnUrl'],
            "orderId": order_id,
            "orderInfo": order_info['info'],
            "partnerCode": momo_api['PartnerCode'],
            "redirectUrl": momo_api['ReturnUrl'],
            "requestId": request_id,
            "requestType": "payWithATM",
            "signature": signature
        }
        # Make API Request
        response = requests.post("https://test-payment.momo.vn/v2/gateway/api/create", json=payload)
        # print(response.json())
        return response.json()
