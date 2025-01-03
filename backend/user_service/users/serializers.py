from rest_framework import serializers
from users.models import User, Passport
from django.contrib.auth import authenticate, login

class UserRegistrationSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        # passport_model = Passport
        fields = ['email', 'username', 'password']

    def create(self, validated_data):
        checkEmail = User.objects.filter(email=validated_data['email'])
        if checkEmail.exists() == True:
            raise serializers.ValidationError({"email": "Email is already in use."})
        passport = Passport.objects.create(nation=None, expiration=None)
        user = User.objects.create(
            email = validated_data['email'],
            username = validated_data['username'],
            password = validated_data['password'],
            passport_id = passport,
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
    
class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'email', 'username', 'gender', 'birthdate', 'phone_number', 'nationality', 'passport_id', 'is_active', 'is_staff', 'is_superuser']
