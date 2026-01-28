from django.db import models
from vigilant.models import Vigilant
from branch.models import Branch


class History(models.Model):
    vigilant = models.ForeignKey(
        Vigilant, 
        on_delete=models.CASCADE, 
        related_name='histories'
    )
    branch = models.ForeignKey(
        Branch, 
        on_delete=models.CASCADE, 
        related_name='histories'
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    
    class Meta:
        verbose_name = 'Histórico'
        verbose_name_plural = 'Históricos'
        ordering = ['-created_at']
