# Regras de Negócio — API de Assinaturas (diario-premium)

Documentação voltada a QA: traduz o comportamento implementado em `main.ts` para regras de negócio e comportamentos esperados, módulo a módulo. Pontos marcados com ⚠️ são ambiguidades ou inconsistências identificadas no código que ainda não foram confirmadas com o time.

## Subscriptions

**Objetivo:** criar uma assinatura vinculando um usuário a um plano, definindo o preço cobrado e as datas do primeiro ciclo de cobrança.

**Regras de negócio:**
- `user_id` e `plan_id` são obrigatórios — mas isso não é validado explicitamente no código, apenas pelas constraints `NOT NULL`/`FOREIGN KEY` do banco.
- O preço cobrado é fixo em R$ 100, **independente do plano escolhido** — não consulta `plans.price_monthly`/`price_yearly`.
- Cupom: só reconhece o valor literal e exato `"DESCONTO"` no campo `coupon_code` → aplica preço fixo de R$ 50. Qualquer outro valor (inclusive um código real cadastrado em `coupons`) é ignorado silenciosamente.
- Toda assinatura nasce com status `active` — não passa por `trialing`, mesmo que o plano tenha `trial_days` configurado.
- O ciclo de cobrança é sempre `monthly` (valor default da coluna) — o body da requisição não permite escolher `yearly`.
- `current_period_start` = hoje; `current_period_end` = hoje + 1 mês corrido — sempre, independente do plano ou tipo de cobrança.
- Não há checagem de assinatura ativa duplicada: o mesmo usuário pode ter múltiplas assinaturas `active` simultâneas.
- Não valida se o plano está com `status = 'active'` na tabela `plans` — é possível assinar um plano `inactive`/`archived`.
- Nenhum registro é criado em `subscription_history` — não fica trilha de auditoria da criação.

**Comportamento esperado - caminho de sucesso:**
Com `user_id` e `plan_id` válidos (existentes no banco) e `coupon_code` opcional, a API calcula o preço (R$ 100, ou R$ 50 se `coupon_code` for exatamente `"DESCONTO"`), define as datas do ciclo e insere a assinatura com status `active`. Responde com status 200 e `{ id: <id gerado> }`.

**Comportamento esperado - caminhos de erro:**
- Único caminho de erro tratado no código: qualquer exceção — seja `user_id`/`plan_id` ausente, inexistente (violação de FK), ou falha de conexão — cai no mesmo bloco `catch` genérico. Resposta: status 500, `{ error: "Erro ao criar assinatura" }`. Não há diferenciação de mensagem por tipo de falha, nem status 400/404 específicos.
- `coupon_code` inválido ou inexistente: NÃO gera erro. É tratado como "sem cupom" — a assinatura é criada normalmente com preço cheio, sem aviso ao cliente de que o cupom não foi aplicado.

**Casos de borda identificados no código:**
- ⚠️ Precisa confirmação: o preço fixo (100/50) ignora completamente a tabela `plans`. Parece um placeholder/mock de desenvolvimento, não uma regra de negócio real — se confirmado como bug, qualquer plano com preço diferente de R$ 100 está sendo cobrado errado.
- ⚠️ Precisa confirmação: a validação de cupom é uma comparação de string exata (`=== "DESCONTO"`), sensível a maiúsculas/minúsculas, e não consulta `coupons` (ignora `max_uses`, `expires_at`, `is_active`, `discount_type`/`discount_value`). Não fica claro se isso é um mock temporário para testes ou se é o comportamento esperado.
- Erros de FK do MySQL (`user_id`/`plan_id` inexistentes) são mascarados pelo catch genérico como "Erro ao criar assinatura" — dificulta diagnosticar se o problema foi usuário inexistente, plano inexistente, ou outra falha.
- `billing_cycle` nunca é definido explicitamente no INSERT — não há como testar/criar assinatura anual pela API hoje, mesmo o schema suportando.
- ⚠️ Precisa confirmação: múltiplas assinaturas ativas simultâneas para o mesmo usuário são permitidas sem nenhuma restrição — não está claro se é intencional (ex: multi-plano) ou uma regra ausente.
- `coupon_id` (coluna que existe em `subscriptions`) nunca é preenchido, mesmo quando o desconto de R$ 50 é aplicado — quebra a rastreabilidade de qual cupom gerou o desconto.

## Payments

**Objetivo:** registrar o pagamento de uma fatura, simulando uma chamada a um gateway de pagamento externo.

**Regras de negócio:**
- Recebe `invoice_id` e `amount`, mas nenhum dos dois é validado antes de usar — não checa se foram enviados, se `invoice_id` existe, nem se `amount` corresponde ao valor real da fatura.
- A fatura (`invoices`) é marcada como `status = 'paid'` **antes** de qualquer confirmação de sucesso — inclusive antes da simulação de falha do gateway.
- Existe uma simulação de instabilidade do gateway: em ~30% das chamadas (`Math.random() > 0.7`), a rota lança um erro proposital ("Erro aleatório no Gateway").
- Só quando a simulação "passa" (70% dos casos) é criado um registro em `payments`, sempre com `status = 'succeeded'` — nunca existe um registro `failed` ou `pending`.
- Não existe transação: o UPDATE da fatura e o INSERT do pagamento são operações independentes, sem rollback entre elas.
- Não há checagem de idempotência: a mesma fatura pode ser "paga" repetidas vezes, gerando múltiplos registros de pagamento para o mesmo `invoice_id`.

**Comportamento esperado - caminho de sucesso:**
Segundo o Swagger, ao enviar `invoice_id` e `amount`, a fatura é marcada como paga e um pagamento bem-sucedido é registrado, retornando `{ success: true }` (status 200 implícito).

**Comportamento esperado - caminhos de erro:**
- Não existe bloco `try/catch` nesta rota — é a única rota do sistema sem tratamento de erro nenhum.
- Quando a simulação de falha dispara (~30% das vezes), o erro lançado dentro do handler assíncrono não é capturado por nada — não há middleware de erro registrado em `main.ts`, e o projeto roda em Express 4.19 (`package.json`), que não converte automaticamente rejeições de Promise em resposta HTTP.
- ⚠️ Precisa confirmação (decorre diretamente do código, mas o efeito em runtime depende do ambiente): nesse caso a requisição provavelmente nunca recebe resposta HTTP — fica pendente até o cliente estourar timeout, em vez de retornar um erro 500 como os demais endpoints.
- Mesmo quando a simulação "falha", a fatura já foi marcada `'paid'` no passo anterior — o estado no banco fica inconsistente: fatura paga, sem pagamento de sucesso registrado.

**Casos de borda identificados no código:**
- ⚠️ Precisa confirmação: o `INSERT INTO payments (invoice_id, amount, status) VALUES (?, ?, 'succeeded')` não preenche a coluna `method`, que no schema é `NOT NULL` sem valor default (`ENUM('credit_card','debit_card','pix','boleto')`). Em banco com modo estrito habilitado (padrão do MariaDB usado no `compose.yml`), esse INSERT deveria falhar — ou seja, é possível que o "caminho de sucesso" descrito no Swagger nunca complete de fato, mesmo nos 70% dos casos em que a simulação de gateway "passa".
- Ausência total de `try/catch` deixa esta rota com comportamento diferente de todas as outras do sistema — sem garantia de resposta HTTP em caso de erro.
- `invoice_id` inexistente: o `UPDATE` simplesmente não afeta nenhuma linha (falha silenciosa, sem erro), e o fluxo segue até o `INSERT`, que falharia por violar a FK de `invoice_id` — mascarado pela ausência de tratamento de erro.
- Sem verificação de que `amount` bate com o valor da fatura — é possível "pagar" uma fatura de R$ 100 informando `amount: 1`.
- Pagamentos duplicados na mesma fatura não são bloqueados de nenhuma forma.
