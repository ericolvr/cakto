# Cores ANSI
RESET=\033[0m
GREEN=\033[32m
YELLOW=\033[33m
BLUE=\033[34m
CYAN=\033[36m
RED=\033[31m

# Python do ambiente pyenv
PYTHON=~/.pyenv/versions/bnb/envs/access/bin/python

# ============================================
# Help
# ============================================

.PHONY: help install run db-start db-stop db-clean db-logs migrate freeze test setup-env dev mock-dev logs rabbit-start rabbit-stop rabbit-logs celery-worker celery-stop mock create-data docker-build docker-run docker-up docker-down docker-logs prometheus-start prometheus-stop prometheus-logs grafana-start grafana-stop grafana-logs

help:
	@echo ""
	@echo "$(CYAN)========================================$(RESET)"
	@echo "$(CYAN)  Comandos Makefile - Projeto Cakto$(RESET)"
	@echo "$(CYAN)========================================$(RESET)"
	@echo ""
	@echo "$(YELLOW)Setup & Desenvolvimento:$(RESET)"
	@echo "  $(GREEN)make install$(RESET)      - Instala dependências Python"
	@echo "  $(GREEN)make setup-env$(RESET)    - Cria .env a partir do .env.example"
	@echo "  $(GREEN)make test$(RESET)         - Roda testes"
	@echo "  $(GREEN)make run$(RESET)          - Inicia servidor Django"
	@echo "  $(GREEN)make migrate$(RESET)      - Roda migrations do Django"
	@echo "  $(GREEN)make freeze$(RESET)       - Atualiza requirements.txt com dependências instaladas"
	@echo ""
	@echo "$(YELLOW)PostgreSQL Container:$(RESET)"
	@echo "  $(GREEN)make db-start$(RESET)     - Inicia container PostgreSQL"
	@echo "  $(GREEN)make db-stop$(RESET)      - Para container PostgreSQL"
	@echo "  $(GREEN)make db-clean$(RESET)     - Remove container e volume do PostgreSQL"
	@echo "  $(GREEN)make db-logs$(RESET)      - Visualiza logs do PostgreSQL"
	@echo ""
	@echo "$(YELLOW)RabbitMQ Container:$(RESET)"
	@echo "  $(GREEN)make rabbit-start$(RESET) - Inicia container RabbitMQ"
	@echo "  $(GREEN)make rabbit-stop$(RESET)  - Para container RabbitMQ"
	@echo "  $(GREEN)make rabbit-logs$(RESET)  - Visualiza logs do RabbitMQ"
	@echo ""
	@echo "$(YELLOW)Celery Worker & Mock:$(RESET)"
	@echo "  $(GREEN)make celery-worker$(RESET) - Inicia Celery worker"
	@echo "  $(GREEN)make create-data$(RESET)   - Cria dados de teste (2 Branchs e 2 Vigilantes)"
	@echo "  $(GREEN)make mock$(RESET)          - Envia 5 mensagens mock para Celery"
	@echo ""
	@echo "$(YELLOW)Ambiente Completo:$(RESET)"
	@echo "  $(GREEN)make dev$(RESET)          - Setup completo (install + db + migrate + run)"
	@echo ""
	@echo "$(YELLOW)Docker (Produção):$(RESET)"
	@echo "  $(GREEN)make docker-build$(RESET)     - Build da imagem Docker"
	@echo "  $(GREEN)make docker-up$(RESET)        - Sobe TUDO no Docker (Django + Celery + Prometheus)"
	@echo "  $(GREEN)make docker-down$(RESET)      - Para todos os containers"
	@echo "  $(GREEN)make docker-logs$(RESET)      - Visualiza logs de todos os containers"
	@echo ""
	@echo "$(YELLOW)Observabilidade:$(RESET)"
	@echo "  $(GREEN)make prometheus-start$(RESET) - Inicia Prometheus"
	@echo "  $(GREEN)make prometheus-stop$(RESET)  - Para Prometheus"
	@echo "  $(GREEN)make prometheus-logs$(RESET)  - Visualiza logs do Prometheus"
	@echo "  $(GREEN)make grafana-start$(RESET)    - Inicia Grafana"
	@echo "  $(GREEN)make grafana-stop$(RESET)     - Para Grafana"
	@echo "  $(GREEN)make grafana-logs$(RESET)     - Visualiza logs do Grafana"
	@echo ""
	@echo "$(YELLOW)Logs:$(RESET)"
	@echo "  $(GREEN)make logs$(RESET)         - Visualiza todos os logs do Docker Compose"
	@echo ""

install:
	@echo "$(YELLOW)Instalando dependências Python...$(RESET)"
	@pip install --upgrade pip
	@pip install -r requirements.txt
	@echo "$(GREEN) Dependências instaladas com sucesso!$(RESET)"

# ============================================
# Setup & Configuração
# ============================================

setup-env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN) .env criado a partir do .env.example$(RESET)"; \
	else \
		echo "$(BLUE) .env já existe$(RESET)"; \
	fi

migrate:
	@echo "$(YELLOW)Rodando migrations...$(RESET)"
	@$(PYTHON) manage.py makemigrations
	@$(PYTHON) manage.py migrate
	@echo "$(GREEN)Migrations concluídas!$(RESET)"
	@$(MAKE) freeze

freeze:
	@echo "$(YELLOW)Salvando dependências em requirements.txt...$(RESET)"
	@pip freeze > requirements.txt
	@echo "$(GREEN)requirements.txt atualizado!$(RESET)"

run:
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@echo "$(CYAN)Iniciando servidor Django...$(RESET)"
	@$(PYTHON) manage.py runserver

test:
	@echo "$(YELLOW)Rodando testes...$(RESET)"
	@$(PYTHON) manage.py test
	@echo "$(GREEN)Testes concluídos!$(RESET)"

# ============================================
# PostgreSQL Container
# ============================================

db-start:
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@echo "$(YELLOW)Iniciando container PostgreSQL...$(RESET)"
	@docker compose up postgres -d
	@echo "$(GREEN) PostgreSQL iniciado!$(RESET)"

db-stop:
	@echo "$(YELLOW)Parando container PostgreSQL...$(RESET)"
	@docker compose down postgres
	@echo "$(GREEN) PostgreSQL parado!$(RESET)"

db-clean:
	@echo "$(YELLOW)Limpando dados do PostgreSQL...$(RESET)"
	@docker compose down postgres
	@docker volume rm postgres_data_cakto 2>/dev/null || true
	@echo "$(GREEN) Dados limpos!$(RESET)"

db-logs:
	@echo "$(CYAN)Logs do PostgreSQL (Ctrl+C para sair):$(RESET)"
	@docker compose logs -f postgres

logs:
	@echo "$(CYAN)Logs de todos os containers (Ctrl+C para sair):$(RESET)"
	@docker compose logs -f

# ============================================
# RabbitMQ Container
# ============================================

rabbit-clean:
	@echo "$(YELLOW)Limpando RabbitMQ completamente...$(RESET)"
	@docker compose down rabbitmq 2>/dev/null || true
	@docker rm -f cakto-rabbitmq 2>/dev/null || true
	@lsof -ti:5672 | xargs kill -9 2>/dev/null || true
	@lsof -ti:15672 | xargs kill -9 2>/dev/null || true
	@echo "$(GREEN)RabbitMQ limpo!$(RESET)"

rabbit-start:
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@echo "$(YELLOW)Limpando processos anteriores...$(RESET)"
	@lsof -ti:5672 | xargs kill -9 2>/dev/null || true
	@lsof -ti:15672 | xargs kill -9 2>/dev/null || true
	@docker rm -f cakto-rabbitmq 2>/dev/null || true
	@echo "$(YELLOW)Iniciando container RabbitMQ...$(RESET)"
	@docker compose up rabbitmq -d
	@echo "$(GREEN)RabbitMQ iniciado!$(RESET)"
	@echo "$(BLUE)Management UI: http://localhost:15672 (cakto/cakto)$(RESET)"

rabbit-stop:
	@echo "$(YELLOW)Parando container RabbitMQ...$(RESET)"
	@docker compose down rabbitmq
	@echo "$(GREEN)RabbitMQ parado!$(RESET)"

rabbit-logs:
	@echo "$(CYAN)Logs do RabbitMQ (Ctrl+C para sair):$(RESET)"
	@docker compose logs -f rabbitmq

# ============================================
# Celery Worker & Mock
# ============================================

celery-worker:
	@echo "$(YELLOW)Iniciando Celery worker...$(RESET)"
	@$(PYTHON) -m celery -A project worker --loglevel=info

celery-stop:
	@echo "$(YELLOW)Parando Celery workers...$(RESET)"
	@pkill -f 'celery worker' || true
	@echo "$(GREEN)Celery workers parados!$(RESET)"

create-data:
	@echo "$(YELLOW)Criando dados de teste...$(RESET)"
	@$(PYTHON) create_test_data.py
	@echo "$(GREEN)Dados criados com sucesso!$(RESET)"

mock:
	@echo "$(YELLOW)Enviando mensagens mock para Celery...$(RESET)"
	@$(PYTHON) mock_rabbitmq.py --total 5 --interval 1
	@echo "$(GREEN)Mensagens enviadas! Verifique os logs do Celery worker.$(RESET)"

# ============================================
# Ambientes Completos
# ============================================

dev:
	@echo ""
	@echo "$(CYAN)========================================$(RESET)"
	@echo "$(CYAN)  Iniciando ambiente de desenvolvimento$(RESET)"
	@echo "$(CYAN)========================================$(RESET)"
	@echo ""
	@echo "$(BLUE)Passo 1/4: Instalando dependências...$(RESET)"
	@$(MAKE) install
	@echo ""
	@echo "$(BLUE)Passo 2/4: Configurando ambiente...$(RESET)"
	@$(MAKE) setup-env
	@echo ""
	@echo "$(BLUE)Passo 3/4: Iniciando PostgreSQL...$(RESET)"
	@$(MAKE) db-start
	@echo ""
	@echo "$(BLUE)Passo 4/4: Iniciando servidor Django...$(RESET)"
	@$(MAKE) run

mock-dev:
	@echo ""
	@echo "$(CYAN)========================================$(RESET)"
	@echo "$(CYAN)  Setup Completo + Mock$(RESET)"
	@echo "$(CYAN)========================================$(RESET)"
	@echo ""
	@echo "$(BLUE)Passo 1/6: Instalando dependências...$(RESET)"
	@$(MAKE) install
	@echo ""
	@echo "$(BLUE)Passo 2/6: Configurando ambiente...$(RESET)"
	@$(MAKE) setup-env
	@echo ""
	@echo "$(BLUE)Passo 3/6: Iniciando PostgreSQL...$(RESET)"
	@$(MAKE) db-start
	@echo ""
	@echo "$(BLUE)Passo 4/6: Iniciando RabbitMQ...$(RESET)"
	@$(MAKE) rabbit-start
	@echo ""
	@echo "$(BLUE)Passo 5/6: Rodando migrations...$(RESET)"
	@$(MAKE) migrate
	@echo ""
	@echo "$(BLUE)Passo 6/6: Criando dados de teste...$(RESET)"
	@$(MAKE) create-data
	@echo ""
	@echo "$(GREEN)========================================$(RESET)"
	@echo "$(GREEN)  Ambiente pronto!$(RESET)"
	@echo "$(GREEN)========================================$(RESET)"
	@echo ""
	@echo "$(YELLOW)Para processar mensagens, rode em terminais separados:$(RESET)"
	@echo "  1. Terminal 1: $(CYAN)make run$(RESET)              (Django)"
	@echo "  2. Terminal 2: $(CYAN)make celery-worker$(RESET)    (Worker - OBRIGATORIO)"
	@echo "  3. Terminal 3: $(CYAN)make mock$(RESET)             (Envia mensagens)"
	@echo ""
	@echo "$(RED)IMPORTANTE: O Celery worker DEVE estar rodando para processar as mensagens!$(RESET)"
	@echo ""

# ============================================
# Docker (Produção)
# ============================================

docker-build:
	@echo "$(YELLOW)Building Docker image...$(RESET)"
	@docker build -t cakto:latest .
	@echo "$(GREEN)Imagem Docker criada com sucesso!$(RESET)"

docker-run:
	@echo "$(YELLOW)Rodando aplicação com Docker + Gunicorn...$(RESET)"
	@docker run -d \
		--name cakto-app \
		-p 8000:8000 \
		--env-file .env \
		--network cakto_cakto-network \
		cakto:latest
	@echo "$(GREEN)Aplicação rodando em http://localhost:8000$(RESET)"
	@echo "$(CYAN)Logs: docker logs -f cakto-app$(RESET)"

# ============================================
# Docker Compose - Ambiente Completo
# ============================================

docker-up:
	@echo "$(YELLOW)Subindo ambiente completo no Docker...$(RESET)"
	@docker-compose up -d
	@echo "$(GREEN)Ambiente completo rodando!$(RESET)"
	@echo "$(CYAN)Django API: http://localhost:8000$(RESET)"
	@echo "$(CYAN)Prometheus: http://localhost:9090$(RESET)"
	@echo "$(CYAN)Grafana: http://localhost:3000 (admin/admin)$(RESET)"
	@echo "$(CYAN)RabbitMQ Management: http://localhost:15672$(RESET)"
	@echo "$(CYAN)Logs: make docker-logs$(RESET)"

docker-down:
	@echo "$(YELLOW)Parando todos os containers...$(RESET)"
	@docker-compose down
	@echo "$(GREEN)Containers parados!$(RESET)"

docker-logs:
	@echo "$(CYAN)Visualizando logs (Ctrl+C para sair):$(RESET)"
	@docker-compose logs -f

# ============================================
# Prometheus
# ============================================

prometheus-start:
	@echo "$(YELLOW)Iniciando Prometheus...$(RESET)"
	@docker-compose up -d prometheus
	@echo "$(GREEN)Prometheus rodando em http://localhost:9090$(RESET)"
	@echo "$(CYAN)Métricas Django: http://localhost:8000/metrics$(RESET)"

prometheus-stop:
	@echo "$(YELLOW)Parando Prometheus...$(RESET)"
	@docker-compose stop prometheus
	@echo "$(GREEN)Prometheus parado!$(RESET)"

prometheus-logs:
	@docker-compose logs -f prometheus

grafana-start:
	@echo "$(YELLOW)Iniciando Grafana...$(RESET)"
	@docker-compose up -d grafana
	@echo "$(GREEN)Grafana rodando em http://localhost:3000$(RESET)"
	@echo "$(CYAN)Login: admin / Senha: admin$(RESET)"

grafana-stop:
	@echo "$(YELLOW)Parando Grafana...$(RESET)"
	@docker-compose stop grafana
	@echo "$(GREEN)Grafana parado!$(RESET)"

grafana-logs:
	@docker-compose logs -f grafana

# ============================================
# Logs
# ============================================

logs:
	@echo "$(CYAN)Visualizando logs do Docker Compose (Ctrl+C para sair):$(RESET)"
	@docker compose logs -f