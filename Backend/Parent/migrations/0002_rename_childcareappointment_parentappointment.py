# Generated by Django 5.0.2 on 2024-03-06 21:19

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('Parent', '0001_initial'),
    ]

    operations = [
        migrations.RenameModel(
            old_name='ChildcareAppointment',
            new_name='ParentAppointment',
        ),
    ]
