from django.forms import ModelForm
from django import forms
from django.contrib.auth.forms import UserCreationForm
# from django.contrib.auth.models import User
from .models import CustomUser
from django.core.validators import RegexValidator


class CreateUserForm(UserCreationForm):
    phone_no = forms.CharField(max_length = 10)
    class Meta:
        model = CustomUser
        fields = ["first_name","last_name", "username","email","phone_no","password1", 'password2']
