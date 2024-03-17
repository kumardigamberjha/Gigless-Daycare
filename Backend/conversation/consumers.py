# messaging/consumers.py
import json
from channels.generic.websocket import AsyncWebsocketConsumer
from django.utils.decorators import method_decorator
from django.views.decorators.csrf import csrf_exempt
from channels.db import database_sync_to_async 


# @method_decorator(csrf_exempt, name="receive")
class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        print("Connecting...")
        await self.accept()
        print("Connected")


    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        data = json.loads(text_data)
        message = data['message']
        print("Received message:", message)
        # await self.send(text_data=json.dumps({'message': message}))

        await self.send(json.dumps({
            'type': 'chat',
            'message': message
        }))


    async def send(self, event):
        # Send a message to the WebSocket.
        print("sending")
        pass