from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView
from rest_framework import status
from rest_framework.response import Response

from rest_framework.decorators import api_view
from .serializers import CustomUserSerializer
from django.contrib.auth import authenticate, login, logout
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.decorators import login_required
from rest_framework.decorators import authentication_classes, permission_classes
from rest_framework_simplejwt.tokens import RefreshToken

from rest_framework_simplejwt.tokens import AccessToken
from rest_framework_simplejwt.exceptions import InvalidToken, TokenError

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
        serializer = CustomUserSerializer(data=request.data)
        print("Username: ", request.data.get('username'))
        print("UserType: ", request.data.get('usertype'))

        if serializer.is_valid():
            user = serializer.save()

            # Log in the user after successful registration
            login(request, user)
            print("Login Done")

            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    

# class LogoutView(APIView):
#     #  permission_classes = (IsAuthenticated,)
#      def post(self, request):
          
#           try:
#                refresh_token = request.data["refresh_token"]
#             #    token = RefreshToken(refresh_token)
#             #    token.blacklist()
#                return Response(status=status.HTTP_205_RESET_CONTENT)
#           except Exception as e:
#                return Response(status=status.HTTP_400_BAD_REQUEST)



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