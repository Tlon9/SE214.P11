from channels.routing import ProtocolTypeRouter, URLRouter
from django.core.asgi import get_asgi_application
from channels.auth import AuthMiddlewareStack
from django.urls import path
from payment.consumers import NotificationConsumer
from payment.middleware import TokenAuthMiddleware
import os
# Set the DJANGO_SETTINGS_MODULE environment variable
# os.environ.setdefault("DJANGO_SETTINGS_MODULE", "payment_service.settings")
# application = ProtocolTypeRouter({
#     "http": get_asgi_application(),
#     "websocket": TokenAuthMiddleware(
#     AuthMiddlewareStack(
#         URLRouter([
#             path("ws/notifications/", NotificationConsumer.as_asgi()),
#         ])
#     )),
# })
application = get_asgi_application()
