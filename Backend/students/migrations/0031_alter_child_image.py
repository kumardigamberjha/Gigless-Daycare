# Generated by Django 5.0.7 on 2024-10-22 17:59

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('students', '0030_alter_child_image'),
    ]

    operations = [
        migrations.AlterField(
            model_name='child',
            name='image',
            field=models.ImageField(blank=True, null=True, upload_to=''),
        ),
    ]