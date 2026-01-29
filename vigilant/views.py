from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny
from django.shortcuts import get_object_or_404
from django.db import transaction
from django.contrib.auth import get_user_model
from .models import Vigilant
from .serializers import VigilantSerializer

User = get_user_model()


class VigilantListCreateAPIView(APIView):
    """
    GET: Lista todos os vigilantes
    POST: Cria um novo vigilante (e automaticamente cria um User associado)
    """
    permission_classes = [AllowAny]
    
    def get(self, request):
        vigilants = Vigilant.objects.all()
        serializer = VigilantSerializer(vigilants, many=True)
        return Response(serializer.data)
    
    def post(self, request):
        name = request.data.get('name')
        mobile = request.data.get('mobile')
        
        if not name or not mobile:
            return Response(
                {'error': 'Os campos name e mobile são obrigatórios'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            with transaction.atomic():
                # 1. Criar o User
                user = User.objects.create_user(
                    mobile=mobile,
                    name=name,
                    password=mobile  # senha padrão = mobile (você pode mudar isso)
                )
                
                # 2. Criar o Vigilant associado ao User
                vigilant = Vigilant.objects.create(
                    user=user,
                    name=name,
                    mobile=mobile
                )
                
                serializer = VigilantSerializer(vigilant)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
                
        except Exception as e:
            return Response(
                {'error': f'Erro ao criar vigilante: {str(e)}'},
                status=status.HTTP_400_BAD_REQUEST
            )


class VigilantDetailAPIView(APIView):
    """
    GET: Retorna detalhes de um vigilante específico
    PUT: Atualiza completamente um vigilante
    PATCH: Atualiza parcialmente um vigilante
    DELETE: Remove um vigilante
    """
    permission_classes = [AllowAny]
    
    def get(self, request, pk):
        vigilant = get_object_or_404(Vigilant, pk=pk)
        serializer = VigilantSerializer(vigilant)
        return Response(serializer.data)
    
    def put(self, request, pk):
        vigilant = get_object_or_404(Vigilant, pk=pk)
        serializer = VigilantSerializer(vigilant, data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def patch(self, request, pk):
        vigilant = get_object_or_404(Vigilant, pk=pk)
        serializer = VigilantSerializer(vigilant, data=request.data, partial=True)
        if serializer.is_valid():
            serializer.save()
            return Response(serializer.data)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    def delete(self, request, pk):
        vigilant = get_object_or_404(Vigilant, pk=pk)
        vigilant.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)

# Create your views here.
