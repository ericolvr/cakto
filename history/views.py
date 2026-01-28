from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from django.shortcuts import get_object_or_404

from .models import History
from .serializers import HistorySerializer


class HistoryListCreateAPIView(APIView):
    """
    GET: Lista todos os históricos
    POST: Cria um novo histórico
    """
    
    def get(self, request):
        histories = History.objects.all()
        serializer = HistorySerializer(histories, many=True)
        return Response(serializer.data)
    
    def post(self, request):
        serializer = HistorySerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class HistoryDetailAPIView(APIView):
    """
    GET: Retorna detalhes de um histórico específico
    PUT: Atualiza completamente um histórico
    PATCH: Atualiza parcialmente um histórico
    DELETE: Remove um histórico
    """
    
    def get(self, request, pk):
        history = get_object_or_404(History, pk=pk)
        serializer = HistorySerializer(history)
        return Response(serializer.data)
    
    def put(self, request, pk):
        history = get_object_or_404(History, pk=pk)
        serializer = HistorySerializer(history, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def patch(self, request, pk):
        history = get_object_or_404(History, pk=pk)
        serializer = HistorySerializer(history, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        history = get_object_or_404(History, pk=pk)
        history.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

# Create your views here.
