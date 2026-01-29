#!/bin/bash

# Script para gerar TRÁFEGO PESADO na API Django
# Envia MUITAS requisições paralelas para os endpoints
# Útil para testes de carga e stress
# Pressione Ctrl+C para parar

echo "=========================================="
echo "  TRÁFEGO PESADO - API Django"
echo "=========================================="
echo ""
echo "⚠️  ATENÇÃO: Este script gera MUITAS requisições!"
echo ""
echo "Endpoints:"
echo "  • http://localhost:8000/api/branchs/"
echo "  • http://localhost:8000/api/vigilants/"
echo "  • http://localhost:8000/api/histories/"
echo ""
echo "Configuração:"
echo "  • 10 requisições paralelas por endpoint"
echo "  • 30 requisições por batch"
echo "  • ~60 requisições/segundo"
echo ""
echo "Pressione Ctrl+C para parar"
echo "=========================================="
echo ""

# Contador de requisições
count=0
total_requests=0

# Loop infinito até Ctrl+C
while true; do
    count=$((count + 1))
    
    # Envia 10 requisições paralelas para cada endpoint (30 total)
    for i in {1..10}; do
        curl -s http://localhost:8000/api/branchs/ > /dev/null &
        curl -s http://localhost:8000/api/vigilants/ > /dev/null &
        curl -s http://localhost:8000/api/histories/ > /dev/null &
    done
    
    # Aguarda todas as requisições paralelas terminarem
    wait
    
    total_requests=$((total_requests + 30))
    
    # Mostra progresso
    echo "Batch $count - $(date '+%H:%M:%S') - 30 requisições enviadas (Total: $total_requests)"
    
    # Aguarda 0.5 segundos antes do próximo batch
    sleep 0.5
done
