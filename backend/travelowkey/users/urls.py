from django.urls import path
from users.apis import *
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

urlpatterns = [
    # path('user/login', TokenObtainPairView.as_view(), name='login'),
    path('user/signup', RegisterUserView.as_view(), name='register'),
    # path('user/login/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('hello/', HelloView.as_view()),
    #  path('user/hello', HelloView.as_view(), name ='hello'), 
]
