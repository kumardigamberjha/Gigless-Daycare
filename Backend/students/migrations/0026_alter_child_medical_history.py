# Generated by Django 5.0.7 on 2024-10-13 14:30

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('students', '0025_alter_child_unique_together_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='child',
            name='medical_history',
            field=models.TextField(blank=True, null=True),
        ),
    ]