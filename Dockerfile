# Multi-stage Dockerfile para Django com Gunicorn

# Stage 1: Builder
FROM python:3.9-slim AS builder

WORKDIR /app

# Instalar dependências do sistema necessárias para compilação
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements e instalar dependências Python globalmente
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime
FROM python:3.9-slim

WORKDIR /app

# Instalar apenas dependências de runtime
RUN apt-get update && apt-get install -y --no-install-recommends \
    postgresql-client \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar dependências Python do builder
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copiar código da aplicação
COPY . .

# Criar diretório de logs
RUN mkdir -p logs

# Criar usuário não-root para segurança
RUN useradd -m -u 1000 django && chown -R django:django /app
USER django

# Expor porta do Gunicorn
EXPOSE 8000

# Coletar arquivos estáticos
RUN python manage.py collectstatic --noinput || true

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/admin/', timeout=2)" || exit 1

# Comando para rodar com Gunicorn
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "--threads", "2", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-", "project.wsgi:application"]
