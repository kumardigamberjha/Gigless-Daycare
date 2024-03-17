from django.db import models
from students.models import Child
from authapp.models import CustomUser


# Create your models here.
class ParentModel(models.Model):
    first_name = models.CharField(max_length=30)
    last_name = models.CharField(max_length=30)

    mobile_number = models.CharField(max_length=15, blank=True, null=True)
    relation_to_child = models.CharField(max_length=35)
    date_created = models.DateTimeField(auto_now_add=True)
    unique_key = models.ForeignKey(Child, on_delete=models.CASCADE)

    def __str__(self):
        return self.first_name



class ParentAppointment(models.Model):
    parent = models.ForeignKey(CustomUser, on_delete=models.CASCADE)
    appointment_type = models.CharField(max_length=100)
    scheduled_time = models.DateTimeField()
    notes = models.TextField(blank=True)
    status = models.CharField(max_length=30, default=30, blank=True)

    def __str__(self):
        return f"{self.appointment_type} - {self.scheduled_time}"