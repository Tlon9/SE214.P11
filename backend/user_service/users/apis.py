from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Passport
from .serializers import UserRegistrationSerializer, LoginSerializer, UserSerializer
from django.contrib.auth import authenticate, login
from rest_framework.permissions import IsAuthenticated 
from rest_framework.authentication import SessionAuthentication, BasicAuthentication
# from google.auth.transport import requests
from google.oauth2 import id_token
from rest_framework.permissions import AllowAny
from rest_framework_simplejwt.tokens import RefreshToken

from google.oauth2 import id_token
from google.auth import jwt
from google.auth.transport.requests import Request
from django.contrib.auth import get_user_model
import requests

class RegisterUserView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User registered successfully."}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        

class UserInfoView(APIView):

    def get(self, request, *args, **kwargs):
        email = request.query_params.get('email')  # Get email from query parameters
        if not email:
            return Response({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user = User.objects.get(email=email)  # Retrieve the user based on the email
        except User.DoesNotExist:
            return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

        serializer = UserSerializer(user)
        return Response(serializer.data)
    
class GoogleLogin(APIView):
    def post(self, request):
        access_token = request.data.get("access_token")
        id_token = request.data.get("id_token")
        if not id_token:
            print("id token is required")
            return Response({"error": "id token is required"}, status=status.HTTP_400_BAD_REQUEST)

        User = get_user_model()
        user_info = self.verify_google_id_token(id_token)
        if not user_info:
            print("No user_info")
            return Response({"error": "Invalid access token"}, status=status.HTTP_400_BAD_REQUEST)
        else:
            print(user_info.get("sub"))
        
        google_id = user_info.get("sub")
        email = user_info.get("email")
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # If the user doesn't exist, create a new user
            user = User.objects.create_user(username=google_id, email=email)
            user.set_unusable_password()
            user.save()
        print(user.email)
        tokens = self.get_tokens_for_user(user)
        # return Response({"message": "Login successful", "user_id": user.id, "email": user.email}, status=status.HTTP_200_OK)
        return Response({
            "message": "Login successful",
            "user_id": user.id,
            "email": user.email,
            "access": tokens['access'],
            "refresh": tokens['refresh']
        }, status=status.HTTP_200_OK)
    def get_tokens_for_user(self, user):
        """
        Generate access and refresh tokens for a user.
        """
        refresh = RefreshToken.for_user(user)
        return {
            'refresh': str(refresh),
            'access': str(refresh.access_token),
        }
    def verify_google_id_token(self, id_token_string):
        """
        Verify the Google ID Token and return user info if the token is valid.
        """
        try:
            # Specify the CLIENT_ID of the app that accesses the backend:
            idinfo = id_token.verify_oauth2_token(id_token_string, Request(), '366589839768-l9sbovdpodu1nm7f3hjkivm4e5eq4qou.apps.googleusercontent.com')

            userid = idinfo['sub']
            email = idinfo.get('email')
            return {"userid": userid, "email": email}
        
        except ValueError:
            return None
