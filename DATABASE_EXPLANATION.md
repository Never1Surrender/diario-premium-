## Visão geral do sistema

O schema simula uma plataforma do tipo "Diário Premium" — usuários se cadastram, escolhem planos, pagam via diferentes métodos (cartão, Pix, boleto), e têm acesso a conteúdos enquanto a assinatura estiver ativa. O sistema suporta upgrades, cancelamentos, reembolsos, cupons e histórico de cobrança.

---

## Relacionamentos principais

Há quatro grupos funcionais de tabelas:

**Identidade** → `users`, `user_addresses`, `user_sessions`
**Catálogo** → `plans`, `plan_features`, `features`, `coupons`
**Assinatura** → `subscriptions`, `subscription_history`
**Financeiro** → `invoices`, `payments`, `payment_methods`, `refunds`

O fluxo é: um `user` escolhe um `plan`, cria uma `subscription`, que gera `invoices` periódicas, cada `invoice` recebe um `payment`, que pode ter um `refund`. Simples de narrar, mas rico o suficiente para treinar JOINs, subqueries e relatórios.

---

## Estrutura do banco de dados

**12 tabelas** organizadas em 4 grupos:

**Identidade** — `users`, `user_addresses`, `user_sessions`. Usuário é o núcleo. Tem CPF único, status (active/inactive/blocked) e verificação de e-mail.

**Catálogo** — `plans`, `features`, `plan_features` (tabela N:N), `coupons`. Planos têm preço mensal e anual separados, trial_days configurável. Features são independentes e ligadas aos planos via `plan_features.value` (pode guardar limites como "5 downloads/mês").

**Assinaturas** — `subscriptions` e `subscription_history`. A assinatura guarda `price_at_signup` para manter o histórico mesmo se o plano mudar de preço. O `subscription_history` é o log de auditoria de cada evento (criação, ativação, upgrade, cancelamento).

**Financeiro** — `invoices`, `payments`, `payment_methods`, `refunds`. Uma fatura pode ter múltiplas tentativas de pagamento. O pagamento referencia o `payment_method_id` para saber qual cartão/Pix foi usado. Reembolso é separado com motivo tipado.
