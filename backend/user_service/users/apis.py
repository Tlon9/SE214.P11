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
from django.contrib.auth.hashers import check_password

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
            'passport_id': user.passport_id.id if user.passport_id else None,
            'passport_nation': user.passport_id.nation if user.passport_id else None,
            'passport_expiration': user.passport_id.expiration if user.passport_id else None,
            'score': user.score,
        }
        return Response(user_info, status=status.HTTP_200_OK)
    
class CheckPassport(APIView):
    permission_classes = [AllowAny]
    def get(self, request):
        if not request.user.is_authenticated:
            return Response(
                {'error': 'User is not authenticated.'},
                status=status.HTTP_401_UNAUTHORIZED
            )
        user = request.user

        if user.passport_id:
            if user.passport_id.nation and user.passport_id.expiration:
                return Response({"message": "Passport info is updated"}, status=status.HTTP_200_OK)
            else:
                return Response({"message": "Passport info is not updated"}, status=status.HTTP_204_NO_CONTENT)
        else:
            return Response({"message": "Passport info is not updated"}, status=status.HTTP_204_NO_CONTENT)
    
class TokenVerifyView(APIView):
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        token = request.data.get('token')
        email = request.data.get('email')
        checkEmail = User.objects.filter(email=email)
        if checkEmail.exists() == False:
            return Response({"valid": False}, status=400)
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
        passport = user.passport_id
        # print(data)

        # Update fields directly
        username = data.get('username', user.username)
        phone_number = data.get('phoneNumber', user.phone_number)
        email = data.get('email', user.email)
        gender = data.get('gender', user.gender)
        nationality = data.get('nationality', user.nationality)
        passport_nation = data.get('passport_nation', passport.nation)
        passport_expiration = data.get('passport_expiration', passport.expiration)
        # passport_id = data.get('passport_id', user.passport_id)

        # Convert birthdate from string to date object
        birthdate = data.get('birthDate', user.birthdate)
        if birthdate:
            try:
                birthdate = datetime.strptime(birthdate, "%Y-%m-%d").date()
            except ValueError:
                return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)

        if passport_expiration:
            try:
                passport_expiration = datetime.strptime(passport_expiration, "%Y-%m-%d").date()
            except ValueError:
                return Response({"error": "Invalid date format. Use YYYY-MM-DD."}, status=status.HTTP_400_BAD_REQUEST)

        # Update user fields
        user.username = username
        user.phone_number = phone_number
        user.email = email
        user.gender = gender
        user.nationality = nationality
        user.birthdate = birthdate

        passport.nation = passport_nation
        passport.expiration = passport_expiration
        # Save the user object
        user.save()

        passport.save()

        # Construct response
        response_data = {
            "username": user.username,
            "phone_number": user.phone_number,
            "email": user.email,
            "birthdate":user.birthdate,
            "gender": user.gender,
            "nationality": user.nationality,
        }

        return Response({"message": "User info updated successfully", "user": response_data}, status=status.HTTP_200_OK)
    
class UpdatePasswordView(APIView):
    permission_classes = [AllowAny]
    def put(self, request):
        user = request.user
        data = request.data
        # Update fields directly
        print(data.get("newPassword"))
        oldPassword = data.get('oldPassword', "")
        newPassword = data.get('newPassword', "")
        if not check_password(oldPassword, user.password):
            return Response({'error': 'Old password is incorrect'}, status=status.HTTP_400_BAD_REQUEST)
        user.set_password(newPassword)
        user.save()
        return Response({'message': 'Cập nhật mật khẩu thành công'}, status=status.HTTP_200_OK)
    
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
        # print(email)
        try:
            user = User.objects.get(email=email)
        except User.DoesNotExist:
            # If the user doesn't exist, create a new user
            passport = Passport.objects.create(nation=None, expiration=None)
            user = User.objects.create_user(username=google_id, email=email,passport_id = passport)
            user.set_unusable_password()
            user.save()
        # print(user.email)
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


class getScore(APIView):
    permission_classes = [IsAuthenticated]
    def get(self, request):
        user = request.user
        return Response({"score": user.score}, status=status.HTTP_200_OK)

class updateScore(APIView):
    permission_classes = [IsAuthenticated]
    def put(self, request):
        user = request.user
        data = request.data
        score = data.get('score')
        user.score = score
        user.save()
        return Response({"message": "Score updated successfully"}, status=status.HTTP_200_OK)