from django.contrib import admin
from .models import ParentAppointment, ParentModel


# Register your models here.
admin.site.register(ParentAppointment)
admin.site.register(ParentModel)
