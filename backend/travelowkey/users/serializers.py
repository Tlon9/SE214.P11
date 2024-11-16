from rest_framework import serializers
from users.models import User
from django.contrib.auth import authenticate, login

class UserRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['email', 'username', 'password']

    def create(self, validated_data):
        user = User.objects.create(
            email=validated_data['email'],
            username=validated_data['username'],
            password = validated_data['password'],
        )
        user.set_password(validated_data['password'])
        user.save()
        return user

class LoginSerializer(serializers.Serializer):
    # class Meta:
    #     model = User
    #     fields = ['email', 'password']
    email = serializers.EmailField()
    password = serializers.CharField()

    def validate(self, data):
        email = data.get("email", None)
        password = data.get("password", None)
        
        # Use authenticate() method to validate
        user = authenticate(email=email, password=password)
        if user and user.is_active:
            return user
        raise serializers.ValidationError("Invalid login credentials")
