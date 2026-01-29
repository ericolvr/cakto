# Guia de Queries Prometheus para Grafana

## 📊 Dashboard Recomendado - 6 Painéis

### **Painel 1: Taxa de Requisições por Segundo**
**Tipo:** Graph (Time series)
**Query:**
```promql
sum(rate(django_http_requests_total_by_view_transport_method_total[1m]))
```
**Descrição:** Mostra quantas requisições por segundo a API está recebendo
**Legend:** `Requisições/s`

---

### **Painel 2: Requisições por Endpoint**
**Tipo:** Graph (Time series) ou Bar gauge
**Query:**
```promql
sum by (view) (rate(django_http_requests_total_by_view_transport_method_total[5m]))
```
**Descrição:** Mostra quais endpoints estão sendo mais acessados
**Legend:** `{{view}}`

---

### **Painel 3: Taxa de Erros (4xx e 5xx)**
**Tipo:** Graph (Time series)
**Query 1 (Erros 4xx):**
```promql
sum(rate(django_http_responses_total_by_status_view_method_total{status=~"4.."}[5m]))
```
**Query 2 (Erros 5xx):**
```promql
sum(rate(django_http_responses_total_by_status_view_method_total{status=~"5.."}[5m]))
```
**Descrição:** Mostra a taxa de erros HTTP
**Legend:** `4xx Errors` e `5xx Errors`

---

### **Painel 4: Latência Média (segundos)**
**Tipo:** Graph (Time series)
**Query:**
```promql
rate(django_http_requests_latency_seconds_by_view_method_sum[5m]) / rate(django_http_requests_latency_seconds_by_view_method_count[5m])
```
**Descrição:** Tempo médio de resposta da API
**Legend:** `Latência Média`
**Unit:** `seconds (s)`

---

### **Painel 5: Requisições por Status Code**
**Tipo:** Stat ou Pie chart
**Query:**
```promql
sum by (status) (django_http_responses_total_by_status_view_method_total)
```
**Descrição:** Distribuição de status HTTP (200, 404, 500, etc)
**Legend:** `Status {{status}}`

---

### **Painel 6: Conexões do Banco de Dados**
**Tipo:** Graph (Time series)
**Query:**
```promql
rate(django_db_new_connections_total[5m])
```
**Descrição:** Taxa de novas conexões ao PostgreSQL
**Legend:** `Novas Conexões/s`

---

## 🎯 Como Criar Dashboard no Grafana

### **Passo 1: Acessar Grafana**
1. Acesse: http://localhost:3000
2. Login: `admin` / Senha: `admin`
3. (Opcional) Pule a troca de senha

### **Passo 2: Criar Novo Dashboard**
1. Menu lateral → **Dashboards**
2. Clique em **New** → **New Dashboard**
3. Clique em **Add visualization**
4. Selecione **Prometheus** como datasource

### **Passo 3: Adicionar Cada Painel**

Para cada painel acima:

1. **Cole a query** no campo "Metric browser" ou "Query"
2. **Configure o tipo de visualização:**
   - Clique em **Visualization** no lado direito
   - Escolha o tipo (Graph, Stat, Bar gauge, etc.)
3. **Configure a legenda:**
   - Em **Legend** → **Custom** → Cole o texto da Legend
4. **Configure unidades (se necessário):**
   - Em **Standard options** → **Unit** → Escolha a unidade
5. **Dê um título:**
   - Em **Panel options** → **Title** → Digite o nome do painel
6. Clique em **Apply** no canto superior direito

### **Passo 4: Organizar Dashboard**
1. Arraste os painéis para reorganizar
2. Redimensione clicando e arrastando os cantos
3. Clique em **Save dashboard** (ícone de disquete no topo)
4. Dê um nome: `Django API Metrics`

---

## 📈 Queries Avançadas

### **Latência P95 (95% das requisições)**
```promql
histogram_quantile(0.95, rate(django_http_requests_latency_seconds_by_view_method_bucket[5m]))
```

### **Latência P99 (99% das requisições)**
```promql
histogram_quantile(0.99, rate(django_http_requests_latency_seconds_by_view_method_bucket[5m]))
```

### **Top 5 Endpoints Mais Acessados**
```promql
topk(5, sum by (view) (rate(django_http_requests_total_by_view_transport_method_total[5m])))
```

### **Top 5 Endpoints Mais Lentos**
```promql
topk(5, rate(django_http_requests_latency_seconds_by_view_method_sum[5m]) / rate(django_http_requests_latency_seconds_by_view_method_count[5m]))
```

### **Taxa de Sucesso (% de requisições 2xx)**
```promql
100 * (sum(rate(django_http_responses_total_by_status_view_method_total{status=~"2.."}[5m])) / sum(rate(django_http_responses_total_by_status_view_method_total[5m])))
```
**Unit:** `percent (0-100)`

### **Requisições por Método HTTP**
```promql
sum by (method) (rate(django_http_requests_total_by_view_transport_method_total[5m]))
```

---

## 🚨 Alertas Recomendados

### **Alerta 1: Alta Taxa de Erros**
**Condição:** Taxa de erros 5xx > 5%
```promql
(sum(rate(django_http_responses_total_by_status_view_method_total{status=~"5.."}[5m])) / sum(rate(django_http_responses_total_by_status_view_method_total[5m]))) > 0.05
```

### **Alerta 2: Latência Alta**
**Condição:** Latência média > 1 segundo
```promql
(rate(django_http_requests_latency_seconds_by_view_method_sum[5m]) / rate(django_http_requests_latency_seconds_by_view_method_count[5m])) > 1
```

### **Alerta 3: Queda no Tráfego**
**Condição:** Requisições/s < 1 (API parada?)
```promql
sum(rate(django_http_requests_total_by_view_transport_method_total[5m])) < 1
```

---

## 💡 Dicas

### **Intervalo de Tempo:**
- Use `[1m]` para dados mais recentes e precisos
- Use `[5m]` para dados mais suavizados
- Use `[15m]` para visão de longo prazo

### **Funções Úteis:**
- `rate()` - Taxa de mudança por segundo
- `sum()` - Soma valores
- `sum by (label)` - Agrupa por label
- `topk(N, query)` - Top N resultados
- `histogram_quantile()` - Percentis (P50, P95, P99)

### **Variáveis no Grafana:**
Você pode criar variáveis para filtrar por endpoint:
1. Dashboard settings → **Variables** → **Add variable**
2. Name: `endpoint`
3. Query: `label_values(django_http_requests_total_by_view_transport_method_total, view)`
4. Use na query: `{view="$endpoint"}`

---

## 🎨 Layout Recomendado

```
┌─────────────────────────────────────────────────────┐
│  Taxa de Requisições/s  │  Requisições por Endpoint │
├─────────────────────────────────────────────────────┤
│  Taxa de Erros          │  Latência Média           │
├─────────────────────────────────────────────────────┤
│  Status Codes           │  Conexões DB              │
└─────────────────────────────────────────────────────┘
```

---

## 📝 Testar Queries

Antes de criar no Grafana, teste no Prometheus:
1. Acesse: http://localhost:9090/graph
2. Cole a query
3. Clique em **Execute**
4. Veja se retorna dados

Se não retornar dados, gere tráfego:
```bash
for i in {1..20}; do curl -s http://localhost:8000/api/branchs/ > /dev/null; sleep 0.5; done
```

---

## 🔗 Links Úteis

- **Prometheus:** http://localhost:9090
- **Grafana:** http://localhost:3000
- **Django API:** http://localhost:8000/api/docs/
- **Métricas Raw:** http://localhost:8000/metrics




<!-- ${__field.labels.view} -->
