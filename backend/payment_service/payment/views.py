# views.py
from django.http import  HttpResponse
from django.views.decorators.csrf import csrf_exempt
from .models import transaction_collection, notification_collection
import requests
import qrcode
from io import BytesIO
from django.conf import settings
from db_connection import redis_client

@csrf_exempt
def payment_callback(request):
    if request.method == 'GET':
        message = request.GET.get('message', '')
        transaction_id = request.GET.get('orderId')
        service = request.GET.get('service')    

        # Update transaction status in the database
        if transaction_id:
            status = 'SUCCESS' if message == 'Successful.' else 'FAILED'
            transaction_collection.update_one(
                {'_id': transaction_id},
                {'$set': {'status': status}}
            )

            if status == 'SUCCESS':
                # user_id = transaction_collection.find_one({'_id': transaction_id})['user_id']
                update_url = f"http://127.0.0.1:8080/payment/notification/?transaction_id={transaction_id}"
                access_token = request.headers.get('Authorization').split(' ')[1]
                headers = {'Authorization': f'Bearer {access_token}'}
                try:
                    requests.post(update_url, headers=headers)
                except Exception as e:
                    print(f"Error updating notification for transaction {transaction_id}: {e}")
                user_id = transaction_collection.find_one({'_id': transaction_id})['user_id']
                cache_key = f"user_history:{user_id}" 
                redis_client.delete(cache_key)
                # transaction = transaction_collection.find_one({'_id': transaction_id})
                # notification = {
                #     'user_id': transaction['user_id'],
                #     'service': transaction['service'],
                #     'info': f'Thanh toán thành công cho dịch vụ  ${transaction['service']} với số tiền ${transaction['amount']}',
                #     'created_at': transaction['created_at'],
                #     'status': 'UNREAD'    
                # }
                # notification_collection.insert_one(notification)
            if service == 'flight':
                # Update the flight status  
                order_info = request.GET.get('orderInfo').split('-')
                id = order_info[0]
                passenger = order_info[1]
                update_url = f"http://127.0.0.1:8000/flights/updateFlight?id={id}&passenger={passenger}"
                try:
                    requests.put(update_url)
                except Exception as e:
                    print(f"Error updating flight {order_info[0]}: {e}")

                # Generate a QR code for the transaction
                create_flight_qr(transaction_id,id,passenger)
            elif service == 'hotel':
                # Update the hotel status
                order_info = request.GET.get('orderInfo').split('_')
                hotel_id = order_info[0]
                room_id = order_info[1]
                check_in = order_info[2]
                check_out = order_info[3]
                update_url = f"http://127.0.0.1:8008/hotels/updateRoom?room_id={room_id}&hotel_id={hotel_id}&check_in={check_in}&check_out={check_out}"
                print('update_url:',update_url)
                try:
                    requests.put(update_url)
                except Exception as e:
                    print(f"Error updating hotel {hotel_id}: {e}")
                create_hotel_qr(transaction_id,room_id,check_in,check_out)
        # HTML response with countdown animation
        html_response = f"""
        <html>
        <head>
            <title>Payment Status</title>
            <style>
                body {{
                    display: flex;
                    flex-direction: column;
                    justify-content: center;
                    align-items: center;
                    height: 100vh;
                    margin: 0;
                    font-family: Arial, sans-serif;
                    background-color: #f9f9f9;
                }}
                .countdown {{
                    font-size: 2rem;
                    font-weight: bold;
                    color: #555;
                    margin-top: 20px;
                }}
                .status {{
                    font-size: 1.5rem;
                    color: {{"#4CAF50" if message == "success" else "#F44336"}};
                }}
            </style>
        </head>
        <body>
            <div>
                <p class="status">Transaction {{"succeeded" if message == "Successful." else "failed"}}</p>
                <p>The page will close in <span id="countdown">15</span> seconds...</p>
                <div class="countdown" id="animation">5</div>
            </div>
            <script>
                const countdownElement = document.getElementById('countdown');
                const animationElement = document.getElementById('animation');
                let secondsLeft = 5;

                const interval = setInterval(() => {{
                    secondsLeft--;
                    countdownElement.textContent = secondsLeft;
                    animationElement.textContent = secondsLeft;

                    if (secondsLeft <= 0) {{
                        clearInterval(interval);
                        window.close();
                    }}
                }}, 1000);
            </script>
        </body>
        </html>
        """
        return HttpResponse(html_response)



def create_flight_qr(transaction_id,id,pasenger):
    save_path = settings.MEDIA_ROOT
    flight = requests.get(f"http://127.0.0.1:8000/flights/getFlight?id={id}").json()
    qr_content = f"Transaction ID:{transaction_id}\n Flight ID: {id}\nFrom: {flight['From']}\nTo: {flight['To']}\nDate: {flight['Date']}\nPassenger: {pasenger}\nSeat Class: {flight['SeatClass']}"
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
    file_name = f"flight_{transaction_id}.png"
    # Save the QR code image to the server
    with open(f"{save_path}/{file_name}", "wb") as f:
        f.write(buffer.getvalue())

def create_hotel_qr(transaction_id,room_id,check_in,check_out):
    save_path = settings.MEDIA_ROOT
    room = requests.get(f"http://127.0.0.1:8008/hotels/getRoom?room_id={room_id}").json()
    qr_content = f"Transaction ID:{transaction_id}\n Room ID: {room_id}\nRoom Name: {room['Name']}\nCheck-in: {check_in}\nCheck-out: {check_out}"
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
    file_name = f"hotel_{transaction_id}.png"
    # Save the QR code image to the server
    with open(f"{save_path}/{file_name}", "wb") as f:
        f.write(buffer.getvalue())
