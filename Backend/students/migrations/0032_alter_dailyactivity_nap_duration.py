# Generated by Django 5.0.1 on 2025-04-11 18:22

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('students', '0031_alter_child_image'),
    ]

    operations = [
        migrations.AlterField(
            model_name='dailyactivity',
            name='nap_duration',
            field=models.CharField(blank=True, null=True),
        ),
    ]
