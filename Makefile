# Cores ANSI
RESET=\033[0m
GREEN=\033[32m
YELLOW=\033[33m
BLUE=\033[34m
CYAN=\033[36m
RED=\033[31m

# Python do ambiente pyenv
PYTHON=~/.pyenv/versions/bnb/envs/access/bin/python

.PHONY: help install run db-start db-stop db-clean migrate test setup-env dev

help:
	@echo ""
	@echo "$(CYAN)Comandos disponíveis:$(RESET)"
	@echo ""
	@echo "  $(GREEN)make install$(RESET)      - Instala dependências Python"
	@echo "  $(GREEN)make setup-env$(RESET)    - Cria .env a partir do .env.example"
	@echo "  $(GREEN)make db-start$(RESET)     - Inicia container PostgreSQL"
	@echo "  $(GREEN)make db-stop$(RESET)      - Para container PostgreSQL"
	@echo "  $(GREEN)make db-clean$(RESET)     - Remove container e volume do PostgreSQL"
	@echo "  $(GREEN)make migrate$(RESET)      - Roda migrations do Django"
	@echo "  $(GREEN)make run$(RESET)          - Inicia servidor Django"
	@echo "  $(GREEN)make test$(RESET)         - Roda testes"
	@echo "  $(GREEN)make dev$(RESET)          - Setup completo (install + db-start + migrate + run)"
	@echo ""

install:
	@echo "$(YELLOW)Instalando dependências Python...$(RESET)"
	@pip install --upgrade pip
	@pip install -r requirements.txt
	@echo "$(GREEN) Dependências instaladas com sucesso!$(RESET)"

setup-env:
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "$(GREEN) .env criado a partir do .env.example$(RESET)"; \
	else \
		echo "$(BLUE) .env já existe$(RESET)"; \
	fi

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

migrate:
	@echo "$(YELLOW)Rodando migrations...$(RESET)"
	@$(PYTHON) manage.py makemigrations
	@$(PYTHON) manage.py migrate
	@echo "$(GREEN)✅ Migrations concluídas!$(RESET)"

run:
	@if [ ! -f .env ]; then cp .env.example .env; fi
	@echo "$(CYAN)Iniciando servidor Django...$(RESET)"
	@$(PYTHON) manage.py runserver

test:
	@echo "$(YELLOW)Rodando testes...$(RESET)"
	@$(PYTHON) manage.py test
	@echo "$(GREEN)✅ Testes concluídos!$(RESET)"

dev:
	@echo ""
	@echo "$(CYAN)========================================$(RESET)"
	@echo "$(CYAN)  Iniciando ambiente de desenvolvimento$(RESET)"
	@echo "$(CYAN)========================================$(RESET)"
	@echo ""
	@echo "$(BLUE)📦 Passo 1/4: Instalando dependências...$(RESET)"
	@$(MAKE) install
	@echo ""
	@echo "$(BLUE)⚙️  Passo 2/4: Configurando ambiente...$(RESET)"
	@$(MAKE) setup-env
	@echo ""
	@echo "$(BLUE)🐘 Passo 3/4: Iniciando PostgreSQL...$(RESET)"
	@$(MAKE) db-start
	@echo ""
	@echo "$(BLUE)🚀 Passo 4/4: Iniciando servidor Django...$(RESET)"
	@$(MAKE) run