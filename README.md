# Diário Premium — API de Assinaturas

API REST em Express + TypeScript que simula uma plataforma de assinaturas: usuários se cadastram, escolhem planos, pagam via cartão/Pix/boleto e têm acesso a conteúdo enquanto a assinatura estiver ativa. Suporta upgrades, cancelamentos, reembolsos, cupons e histórico de cobrança.

## Funcionalidades

- Cadastro, listagem (com filtros por nome, e-mail, CPF e status) e remoção de usuários
- Listagem de planos disponíveis
- Criação de assinaturas
- Processamento de pagamentos
- Relatório de receita (`/reports/revenue`)
- Documentação interativa via Swagger UI

## Pré-requisitos

- [Node.js](https://nodejs.org/) 20+
- [Docker](https://www.docker.com/) e Docker Compose (opcional, para subir a API junto com o banco)
- Uma instância MariaDB/MySQL acessível, caso não use o Docker Compose

## Instalação

### Com Docker Compose (recomendado)

Sobe a API e o banco MariaDB juntos, com o banco já populado a partir de `bkp.sql`:

```bash
docker compose up
```

A API fica disponível em `http://localhost:3000`.

### Local (sem Docker)

```bash
npm install
cp .env.example .env
# edite o .env e aponte DB_HOST para o seu banco local
npm run dev
```

## Configuração

As variáveis de ambiente são carregadas via `dotenv` a partir de um arquivo `.env` (veja `.env.example`):

| Variável      | Descrição                                  | Exemplo           |
|---------------|---------------------------------------------|--------------------|
| `PORT`        | Porta em que a API é servida                | `3000`             |
| `DB_HOST`     | Host do banco MariaDB/MySQL                 | `localhost`        |
| `DB_PORT`     | Porta do banco                              | `3306`             |
| `DB_USER`     | Usuário do banco                            | `root`             |
| `DB_PASSWORD` | Senha do banco                              | `root`             |
| `DB_NAME`     | Nome do banco de dados                      | `diario_premium`   |
| `NODE_ENV`    | Ambiente de execução                        | `development`      |

> **Nota:** ao rodar via `docker compose up`, o serviço `app` usa `DB_HOST: localhost` mesmo o banco rodando em um container separado (`banco`), e o pool `mysql2` é configurado com `connectionLimit: 1`. Fique atento a isso ao depurar problemas de conexão.

## Uso

Com a API rodando, a documentação completa dos endpoints (Swagger UI) fica disponível em:

```
http://localhost:3000/api-docs
```

Principais rotas expostas em `main.ts`:

| Método | Rota                | Descrição                                   |
|--------|----------------------|----------------------------------------------|
| GET    | `/users`             | Lista usuários (filtros: nome, e-mail, CPF, status) |
| GET    | `/users/:id`         | Detalha um usuário                            |
| POST   | `/users`              | Cria um usuário                               |
| DELETE | `/users/:id`         | Remove um usuário                             |
| GET    | `/plans`              | Lista planos disponíveis                      |
| POST   | `/subscriptions`      | Cria uma assinatura                           |
| POST   | `/payments`           | Processa um pagamento                         |
| GET    | `/reports/revenue`   | Relatório de receita                          |

## Banco de dados

O schema tem 12 tabelas organizadas em quatro grupos funcionais: **Identidade** (`users`, `user_addresses`, `user_sessions`), **Catálogo** (`plans`, `features`, `plan_features`, `coupons`), **Assinatura** (`subscriptions`, `subscription_history`) e **Financeiro** (`invoices`, `payments`, `payment_methods`, `refunds`). Detalhes completos em [`DATABASE_EXPLANATION.md`](./DATABASE_EXPLANATION.md); o dump de seed está em [`bkp.sql`](./bkp.sql).

## Comandos disponíveis

| Comando          | Descrição                                         |
|-------------------|----------------------------------------------------|
| `npm run dev`     | Roda a API com hot reload (`ts-node-dev`)          |
| `npm run start`   | Roda a API via `ts-node` (sem reload)              |
| `npm run build`   | Verifica tipos e compila com `tsc`                 |

## Licença

ISC
