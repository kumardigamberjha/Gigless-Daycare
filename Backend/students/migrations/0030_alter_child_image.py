# Generated by Django 5.0.7 on 2024-10-22 17:58

from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('students', '0029_roommedia_media_file_roommedia_uploaded_at_and_more'),
    ]

    operations = [
        migrations.AlterField(
            model_name='child',
            name='image',
            field=models.FileField(blank=True, null=True, upload_to=''),
        ),
    ]
