from django.contrib import admin

from .models import Fee

class FeeAdmin(admin.ModelAdmin):
    list_display = ('id','child', 'amount')

admin.site.register(Fee, FeeAdmin)