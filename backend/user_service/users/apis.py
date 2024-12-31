from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import AccessToken
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
from datetime import datetime

class RegisterUserView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User registered successfully."}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class UserInfoView(APIView):
    permission_classes = [AllowAny]
    def get(self, request):
        if not request.user.is_authenticated:
            return Response(
                {'error': 'User is not authenticated.'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        user = request.user
        # passport = user.passport_id
        user_info = {
            'id': user.id,
            'email': user.email,
            'phone_number': user.phone_number,
            'username': user.username,
            'gender': user.gender,
            'birthdate': user.birthdate,
            'nationality': user.nationality,
            'passport_id': user.passport_id,
            # 'nation': passport.nation if passport else None,
            # 'expiration': passport.expiration if passport else None,
        }
        print(user.password)
        return Response(user_info, status=status.HTTP_200_OK)
    # permission_classes = [AllowAny]

    # def get(self, request, *args, **kwargs):
    #     email = request.query_params.get('email')  # Get email from query parameters
    #     if not email:
    #         return Response({"error": "Email is required"}, status=status.HTTP_400_BAD_REQUEST)
        
    #     try:
    #         user = User.objects.get(email=email)  # Retrieve the user based on the email
    #     except User.DoesNotExist:
    #         return Response({"error": "User not found"}, status=status.HTTP_404_NOT_FOUND)

    #     serializer = UserSerializer(user)
    #     return Response(serializer.data)
    
class TokenVerifyView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        token = request.data.get('token')
        try:
            # Decode and verify token
            AccessToken(token)
            return Response({"valid": True}, status=200)
        except Exception as e:
            return Response({"valid": False, "error": str(e)}, status=400)
        
class UpdateUserInfoView(APIView):
    permission_classes = [AllowAny]

    def put(self, request):
        user = request.user
        data = request.data
        # print(data)

        # Update fields directly
        username = data.get('username', user.username)
        phone_number = data.get('phoneNumber', user.phone_number)
        email = data.get('email', user.email)
        gender = data.get('gender', user.gender)
        # nationality = data.get('nationality', user.nationality)
        # passport_id = data.get('passport_id', user.passport_id)

        # Convert birthdate from string to date object
        birthdate = data.get('birthDate', user.birthdate)
        print(data.get('birthDate'))
        if birthdate:
            try:
                birthdate = datetime.strptime(birthdate, "%Y-%m-%d").date()
            except ValueError:
                return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)

        # Update user fields
        user.username = username
        user.phone_number = phone_number
        user.email = email
        user.gender = gender
        # user.nationality = nationality
        # user.passport_id = passport_id
        user.birthdate = birthdate

        # Save the user object
        user.save()

        # Construct response
        response_data = {
            "username": user.username,
            "phone_number": user.phone_number,
            "email": user.email,
            # "birthdate": user.birthdate.strftime("%Y-%m-%d") if user.birthdate else None,
            "birthdate":user.birthdate,
            "gender": user.gender,
            "nationality": user.nationality,
            "passport_id": user.passport_id,
        }

        return Response({"message": "User info updated successfully", "user": response_data}, status=status.HTTP_200_OK)
    
class GoogleLogin(APIView):
    permission_classes = [AllowAny]
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
        print(email)
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
        
class VerifyUser(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        user = request.user
        return Response({"message": "User is authenticated", "user_id": user.id}, status=status.HTTP_200_OK)
