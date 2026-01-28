from django.db import models

class Vigilant(models.Model):
    name = models.CharField(max_length=100)
    mobile = models.CharField(max_length=15)
    
