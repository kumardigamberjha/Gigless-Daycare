from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('students', '0032_alter_dailyactivity_nap_duration'),
    ]

    operations = [
        migrations.AlterField(
            model_name='dailyactivity',
            name='bathroom_breaks',
            field=models.CharField(blank=True, max_length=20, null=True),
        ),
        migrations.AlterField(
            model_name='dailyactivity',
            name='temperature',
            field=models.CharField(blank=True, max_length=5, null=True),
        ),
    ]
