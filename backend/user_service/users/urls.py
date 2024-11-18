from django.urls import path
from users.apis import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    path('user/signup', RegisterUserView.as_view(), name='register'),
    path('hello/', HelloView.as_view()),
    path('auth/login/google',GoogleLogin.as_view(), name='google-login'),
]
