# # childcare_project/routing.py
# from channels.routing import ProtocolTypeRouter, URLRouter
# from django.urls import path
# from conversation.consumers import ChatConsumer

# application = ProtocolTypeRouter({
#     'websocket': URLRouter(
#         [
#             path('ws/chat/', ChatConsumer.as_asgi()),
#         ]
#     ),
# })


from django.urls import re_path
from . import consumers

websocket_urlpatterns = [
    re_path(r'/ws/chat/', consumers.ChatConsumer.as_asgi()),
]