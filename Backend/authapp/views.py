from django.shortcuts import get_object_or_404
from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import status
from rest_framework.response import Response
from .models import CustomUser
from rest_framework.decorators import api_view
from .serializers import CustomUserSerializer
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from rest_framework.decorators import authentication_classes, permission_classes
from rest_framework_simplejwt.tokens import RefreshToken
from students.models import Child
from students.serializers import ChildSerializer
from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError
from django.db.models import Q
from django.contrib.auth.hashers import make_password
from django.core.mail import send_mail
from Backend.settings import EMAIL_HOST_USER

class TokenValidationView(APIView):
    @authentication_classes([])  # Use an empty list to disable authentication for this view
    @permission_classes([])  # Use an empty list to disable permission checks for this view
    def post(self, request):
        token = request.data.get('token')  # Get the token from the request data

        if not token:
            return Response({'error': 'Token not provided'}, status=400)

        try:
            decoded_token = AccessToken(token)
            # You can access token claims using decoded_token.payload
            # For example: user_id = decoded_token.payload.get('user_id')

            return Response({'valid': True, 'message': 'Token is valid'})
        except TokenError as e:
            return Response({'valid': False, 'error': str(e)}, status=400)


class HomeView(APIView):
     
    permission_classes = (IsAuthenticated, )
    def get(self, request):
        content = {'message': 'Welcome to the Pace Leaderboard'}
        return Response(content)
    


class CustomTokenObtainPairView(TokenObtainPairView):
    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        if serializer.is_valid():
            user = serializer.user
            # You can perform additional checks or actions here
            # before sending the response.
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_401_UNAUTHORIZED)
    

@api_view(['POST'])
def register_user(request):
    if request.method == 'POST':
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email')
        mobile = request.data.get('mobile_number')
        usertype = request.data.get('usertype')

        print("Username: ", username)
        print("Password: ", password)

        # Check if a user with the same username, email, or mobile number exists
        if CustomUser.objects.filter(username=username).exists():
            return Response({"error": "Username already registered"}, status=status.HTTP_400_BAD_REQUEST)
        
        if CustomUser.objects.filter(email=email).exists():
            return Response({"error": "Email already registered"}, status=status.HTTP_400_BAD_REQUEST)
        
        if CustomUser.objects.filter(mobile_number=mobile).exists():
            return Response({"error": "Mobile number already registered"}, status=status.HTTP_400_BAD_REQUEST)

        try:
            # Create the new user
            create = CustomUser.objects.create(
                username=username,
                # password=make_password(password),
                email=email,
                mobile_number=mobile,
                usertype=usertype,
                is_active=True,
            )
            create.set_password(password)
            create.save()
            # Send confirmation email
            send_mail(
                "User Credentials", 
                f'Hey! Your credentials for the Giggles Daycare App are:\n\nUsername: {username}\nPassword: {password}\nRegistered Mobile Number: {mobile}\nRegistered Email: {email}.\n\nThanks for being a valuable member at Giggles Daycare.', 
                EMAIL_HOST_USER, 
                [email], 
                fail_silently=False
            )
            
            print("User Created and Mail Sent")
            return Response("User Created", status=status.HTTP_201_CREATED)
        except Exception as e:
            print("Error:", e)
            return Response({"error": str(e)}, status=status.HTTP_400_BAD_REQUEST)
    

@api_view(['GET'])
@permission_classes([])  # No permission classes applied for this example
def user_list(request):
    # Handle GET request - retrieve user list
    if request.method == 'GET':
        users = CustomUser.objects.filter(usertype="Staff")
        serializer = CustomUserSerializer(users, many=True)
        return Response(serializer.data)


@api_view(['DELETE'])
def DeleteUserRecord(request, id):
    if request.method == 'DELETE':
        if not id:
            return Response({"error": "User ID is required"}, status=status.HTTP_400_BAD_REQUEST)

        # Attempt to retrieve and delete the user
        user = get_object_or_404(CustomUser, id=id)
        user.delete()
        return Response({"message": "User deleted successfully"}, status=200)


@api_view(['GET'])
# @authentication_classes([])  # Disable authentication for this view
@permission_classes([]) 
def parent_list(request):
    if request.method == 'GET':
        users = CustomUser.objects.filter(usertype="Parent")
        serializer = CustomUserSerializer(users, many=True)
        return Response(serializer.data)



@api_view(['GET'])
# @authentication_classes([])  # Disable authentication for this view
@permission_classes([]) 
def parent_detail_list(request, parent_id):
    if request.method == 'GET':
        user = CustomUser.objects.get(id=parent_id)
        print("User: ", user)
        childs = Child.objects.filter(Q(parent1_contact_number=user.mobile_number) | 
                                       Q(parent2_contact_number=user.mobile_number))
        print("Children: ", childs)
        
        user_serializer = CustomUserSerializer(user)
        child_serializer = ChildSerializer(childs, many=True)
        
        response_data = {
            "user": user_serializer.data,
            "children": child_serializer.data
        }
        
        return Response(response_data)


@csrf_exempt
@authentication_classes([])  # Disable authentication for this view
@permission_classes([])  # Disable permission checks for this view
def logout_view(request):
    print("Logout View")
    if request.method == 'POST':
        refresh_token = request.POST.get('refresh')

        if refresh_token:
            try:
                # Blacklist the refresh token to invalidate it
                RefreshToken(refresh_token).blacklist()
                logout(request)
                message = 'Logout successful'
            except Exception as e:
                print(f'Error during logout: {e}')
                message = 'Logout failed'
        else:
            message = 'Refresh token not provided'

        response_data = {
            'message': message,
        }

        return JsonResponse(response_data)
    else:
        return JsonResponse({'message': 'Invalid request method'}, status=400)
    

# @login_required
def get_username(request):
    if request.method == 'GET':
        username = request.user  # Get the username of the logged-in user
        print("Username: ", username)
        response_data = {'username': username}
        return JsonResponse(response_data)