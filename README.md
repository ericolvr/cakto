# Cakto

API REST para gerenciamento de Branchs, Vigilantes e Histórico com processamento assíncrono de mensagens.

## Stack Tecnológica

- **Django 4.2** + Django REST Framework
- **PostgreSQL** - Banco de dados
- **RabbitMQ** - Message broker
- **Celery** - Processamento assíncrono
- **Gunicorn** - WSGI server (produção)
- **Docker** - Containerização
- **Prometheus** - Métricas da API

## Requisitos

- Python 3.9+
- Docker
- Make

## Instalação Rápida

### 🐳 Opção 1: Docker (Recomendado)

```bash
# 1. Clonar repositório
git clone https://github.com/ericolvr/cakto.git
cd cakto

# 2. Deploy completo (builda imagem + sobe tudo)
make deploy

# Pronto! Todos os serviços estarão rodando
```

**Serviços disponíveis:**
- Django API: http://localhost:8000/api/docs/
- Grafana: http://localhost:3000 (admin/admin)
- Prometheus: http://localhost:9090
- RabbitMQ: http://localhost:15672 (cakto/cakto)

### 🖥️ Opção 2: Desenvolvimento Local

```bash
# 1. Clonar repositório
git clone https://github.com/ericolvr/cakto.git
cd cakto

# 2. Configurar ambiente local
make dev

# 3. Rodar migrations
make migrate

# 4. Iniciar Django
make run

# 5. Em outro terminal, iniciar Celery
make celery-worker
```

Acesse: **http://localhost:8000/api/docs/**

## Comandos Principais

### Desenvolvimento
```bash
make install      # Instalar dependências
make setup-env    # Criar .env
make run          # Iniciar Django
make test         # Rodar testes
make migrate      # Rodar migrations
```

### Containers
```bash
make db-start     # Iniciar PostgreSQL
make rabbit-start # Iniciar RabbitMQ
make db-stop      # Parar PostgreSQL
```

### Celery (Processamento Assíncrono)
```bash
# Terminal 1: Celery Worker
make celery-worker

# Terminal 2: Enviar mensagens mock
make mock
```

### Docker (Produção)
```bash
make deploy       # Deploy completo (build + up)
make docker-build # Build imagem
make docker-run   # Rodar com Gunicorn
```

### Geração de Tráfego (para visualizar métricas)
```bash
# Tráfego moderado (~6 req/s)
./send_events.sh

# Tráfego pesado (~60 req/s)
./send_events_heavy.sh
```

Pressione **Ctrl+C** para parar.

## Endpoints da API

- **Swagger UI**: http://localhost:8000/api/docs/
- **ReDoc**: http://localhost:8000/api/redoc/
- **Métricas Prometheus**: http://localhost:8000/metrics

### Principais endpoints:
- `GET /api/branchs/` - Listar branches
- `POST /api/branchs/` - Criar branch
- `GET /api/vigilants/` - Listar vigilantes
- `GET /api/histories/` - Listar histórico

## Arquitetura

```
┌──────────────┐
│  Mock Script │ ← Envia mensagens
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  RabbitMQ    │ ← Fila de mensagens
│   (5672)     │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│Celery Worker │ ← Processa mensagens
│              │   Cria History no banco
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  PostgreSQL  │ ← Armazena dados
│   (5432)     │
└──────────────┘

┌──────────────┐
│   Django     │ ← API REST (separado)
│   (8000)     │   Consulta/CRUD
└──────┬───────┘
       │
       └─────► PostgreSQL (5432)
```

**Fluxo:**
1. Mock envia mensagens → RabbitMQ
2. Celery Worker consome → Processa → Salva no PostgreSQL
3. Django API consulta dados do PostgreSQL

## CI/CD

GitHub Actions configurado para:
- ✅ Testes automatizados
- ✅ Linting (Black, Flake8, isort)
- ✅ Security scan
- ✅ Docker build

Workflows rodam automaticamente em Pull Requests.

## Variáveis de Ambiente

Copie `.env.example` para `.env` e ajuste:

```bash
SECRET_KEY=your-secret-key
DEBUG=True
DB_NAME=cakto
DB_USER=cakto
DB_PASSWORD=cakto
CELERY_BROKER_URL=amqp://cakto:cakto@localhost:5672//
```

## Desenvolvimento

### Fluxo de trabalho
1. Criar branch: `git checkout -b feature/nova-funcionalidade`
2. Fazer alterações
3. Rodar testes: `make test`
4. Commit e push
5. Abrir Pull Request
6. CI valida automaticamente
7. Merge após aprovação

