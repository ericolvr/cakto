from rest_framework import serializers
from .models import Vigilant


class VigilantSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vigilant
        fields = ['id', 'name', 'mobile']
        read_only_fields = ['id']
