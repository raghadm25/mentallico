from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('chat', '0001_initial'),
    ]

    operations = [
        migrations.AddField(
            model_name='chatsession',
            name='hf_session_id',
            field=models.CharField(
                blank=True,
                default='',
                help_text='Session id on the Hugging Face Mentallico AI Space, '
                'used to keep multi-turn conversation state on the remote model.',
                max_length=255,
            ),
        ),
    ]
