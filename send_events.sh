#!/bin/bash

# Script para gerar TRÁFEGO MODERADO na API Django
# Envia requisições sequenciais para os endpoints
# Útil para visualizar métricas no Grafana
# Pressione Ctrl+C para parar

echo "=========================================="
echo "  TRÁFEGO MODERADO - API Django"
echo "=========================================="
echo ""
echo "Endpoints:"
echo "  • http://localhost:8000/api/branchs/"
echo "  • http://localhost:8000/api/vigilants/"
echo "  • http://localhost:8000/api/histories/"
echo ""
echo "Configuração:"
echo "  • 3 requisições sequenciais por batch"
echo "  • ~6 requisições/segundo"
echo ""
echo "Pressione Ctrl+C para parar"
echo "=========================================="
echo ""

# Contador de requisições
count=0

# Loop infinito até Ctrl+C
while true; do
    count=$((count + 1))
    
    # Envia requisição para cada endpoint
    curl -s http://localhost:8000/api/branchs/ > /dev/null
    curl -s http://localhost:8000/api/vigilants/ > /dev/null
    curl -s http://localhost:8000/api/histories/ > /dev/null
    
    # Mostra progresso
    echo "Batch $count - $(date '+%H:%M:%S') - 3 requisições enviadas"
    
    # Aguarda 0.5 segundos antes do próximo batch
    sleep 0.5
done
