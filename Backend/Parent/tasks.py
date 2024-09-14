from celery import shared_task
from time import sleep

from django.core.mail import send_mail
from Backend.settings import EMAIL_HOST_USER

@shared_task(bind=True)
def SendEmail(self, title, body, EMAIL_HOST_USER, recipient_list, fail_silently=True):
    send_mail(
        title,  # Email title
        body,  # Email body
        EMAIL_HOST_USER,  # From email
        recipient_list,  # List of recipients
        fail_silently=fail_silently  # Fail silently option
    )
    return "Mail Sent"