from rest_framework import serializers
from .models import History
from branch.serializers import BranchSerializer
from vigilant.serializers import VigilantSerializer


class HistorySerializer(serializers.ModelSerializer):
    vigilant_detail = VigilantSerializer(source='vigilant', read_only=True)
    branch_detail = BranchSerializer(source='branch', read_only=True)
    
    class Meta:
        model = History
        fields = ['id', 'vigilant', 'vigilant_detail', 'branch', 'branch_detail', 'created_at']
        read_only_fields = ['id', 'created_at']
