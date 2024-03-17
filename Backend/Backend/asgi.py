"""
ASGI config for Backend project.

It exposes the ASGI callable as a module-level variable named ``application``.

For more information on this file, see
https://docs.djangoproject.com/en/5.0/howto/deployment/asgi/
"""

# import os

# from django.core.asgi import get_asgi_application
# from channels.routing import ProtocolTypeRouter, URLRouter
# from channels.auth import AuthMiddlewareStack
# # from django.urls import path
# from conversation.consumers import ChatConsumer
# import conversation.routing


# os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Backend.settings')

# # application = get_asgi_application()

# # application = ProtocolTypeRouter({
# #     'http': get_asgi_application()
# # })

# application = ProtocolTypeRouter({
#     "http": get_asgi_application(),
#     "websocket": AuthMiddlewareStack(
#         URLRouter(
#         [
#             # path('ws/chat/', ChatConsumer.as_asgi()),
#             # Add more WebSocket routes if needed
#             conversation.routing.websocket_urlpatterns
#         ]
#         )
#     ),
# })


import os
from django.core.asgi import get_asgi_application
from channels.routing import ProtocolTypeRouter
from channels.routing import URLRouter
from channels.auth import AuthMiddlewareStack
import conversation.routing

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'Backend.settings')

application = ProtocolTypeRouter({
    "http": get_asgi_application(),
    "websocket": AuthMiddlewareStack(
        URLRouter(
            conversation.routing.websocket_urlpatterns
        )
    ),
})
