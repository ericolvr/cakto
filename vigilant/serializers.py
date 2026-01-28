from rest_framework import serializers
from .models import Vigilant


class VigilantSerializer(serializers.ModelSerializer):
    user_id = serializers.IntegerField(source='user.id', read_only=True)
    
    class Meta:
        model = Vigilant
        fields = ['id', 'user_id', 'name', 'mobile']
        read_only_fields = ['id', 'user_id']
