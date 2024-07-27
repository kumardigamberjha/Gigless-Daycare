from django.contrib import admin

# Register your models here.
from .models import Child, Attendance, DailyActivity, ChildMedia, LearningResource, Rooms

class ChildAdmin(admin.ModelAdmin):
    list_display = ('id','first_name', 'last_name', 'date_of_birth', 'gender', 'emergency_contact_name', 'emergency_contact_number')
    search_fields = ('id','first_name', 'last_name', 'emergency_contact_name', 'emergency_contact_number')


admin.site.register(Child, ChildAdmin)
admin.site.register(Attendance)
admin.site.register(DailyActivity)
admin.site.register(ChildMedia)
admin.site.register(LearningResource)
admin.site.register(Rooms)