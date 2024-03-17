from django.db import models
from students.models import Child
from django.utils.timezone import now

class Fee(models.Model):
    child = models.ForeignKey(Child, on_delete=models.CASCADE)
    amount = models.DecimalField(max_digits=10, decimal_places=2)
    date_paid = models.DateField(default="1999-10-10")

    def __str__(self):
        return self.child.first_name