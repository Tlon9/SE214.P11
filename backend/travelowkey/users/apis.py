from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .models import User, Passport
from .serializers import UserRegistrationSerializer, LoginSerializer
from django.contrib.auth import authenticate, login
from rest_framework.permissions import IsAuthenticated 
from rest_framework.authentication import SessionAuthentication, BasicAuthentication

class RegisterUserView(APIView):
    def post(self, request):
        serializer = UserRegistrationSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User registered successfully."}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

# class LoginAPIView(APIView):
#     def post(self, request):
#         # serializer = LoginSerializer(data=request.data)
#         email = request.data.get("email", None)
#         password = request.data.get("password", None)
#         user = authenticate(request=request,email=email, password=password)
#         if user is not None:
#             login(request, user)
#             return Response({"message": "Login successful"}, status=status.HTTP_200_OK)
#         else:
#             return Response({'non_field_errors': ['Invalid login credentials']}, status=400)
        

class HelloView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, format=None):
        content = {
            'user': str(request.user),
            'auth': str(request.auth),
        }
        return Response(content)
