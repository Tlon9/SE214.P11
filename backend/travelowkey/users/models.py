from django.db import models

# Create your models here.
from django.contrib.auth.models import AbstractBaseUser, BaseUserManager, PermissionsMixin

class Passport(models.Model):
    id = models.AutoField(primary_key=True)
    nation = models.CharField(max_length=50, null=True, blank=True)
    expiration = models.DateField(null=True, blank=True)

    class Meta:
        db_table = 'passport'

class UserManager(BaseUserManager):
    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Users must have an email address')
        email = self.normalize_email(email)
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)

        return self.create_user(email, password, **extra_fields)

class User(AbstractBaseUser, PermissionsMixin):
    id = models.AutoField(primary_key=True)
    username = models.CharField(max_length=255, null=True, blank=True)
    gender = models.CharField(max_length=10, null=True, blank=True)
    birthdate = models.DateField(null=True, blank=True)
    phone_number = models.CharField(max_length=20, null=True, blank=True)
    email = models.CharField(max_length=60, unique=True)
    nationality = models.CharField(max_length=255, null=True, blank=True)
    passport_id = models.ForeignKey(Passport, on_delete=models.CASCADE, db_column='passport_id',null=True, blank=True)
    password = models.TextField(max_length=128)
    is_active = models.BooleanField(default=True)
    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    objects = UserManager()

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    class Meta:
        db_table = 'user'
