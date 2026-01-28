from django.db import models
from django.conf import settings


class Vigilant(models.Model):
    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='vigilant'
    )
    name = models.CharField(max_length=100)
    mobile = models.CharField(max_length=15)
    
