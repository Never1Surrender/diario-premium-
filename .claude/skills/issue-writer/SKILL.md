---
name: issue-writer
description: Cria issues no GitHub a partir de casos de teste com status
"Aberto/Bug" no Notion (um caso específico ou todos em lote), e preenche
automaticamente os campos "GitHub issue" e "Title issue" de volta na página
do caso de teste. Use quando o usuário pedir para "criar uma issue", "abrir
issue no GitHub para esse bug", "reportar esse bug", "subir esse caso de
teste como issue" ou "criar issues para todos os bugs abertos". Funciona a
partir de caso(s) de teste já existentes no Notion (com Resultado atual
preenchido, indicando bug real).
---

# Issue Writer

## Visão geral

Transformar um caso de teste que encontrou um bug real (status "Aberto/Bug"
no Notion) em uma issue estruturada no GitHub, com título em inglês (padrão
do time) e corpo detalhado em português, e depois preencher o campo de URL
da issue de volta na página do Notion correspondente — fechando o ciclo
entre QA e o repositório sem precisar copiar/colar manualmente.

## Passo 1: Identificar o(s) caso(s) de teste de origem

1. **Se o usuário pedir por um caso específico** (ex: "cria a issue do
   AUT-6"), buscar essa página no Notion.
2. **Se o usuário pedir em lote** (ex: "cria issue para todos os casos com
   bug aberto"), consultar o database e listar todas as páginas com
   Status = "Aberto/Bug". Processar cada uma seguindo os mesmos passos
   abaixo, uma de cada vez — não pular a checagem de duplicidade (item 4)
   nem a confirmação (Passo 6) para nenhuma delas só por estar em lote.
3. Confirmar que o(s) caso(s) têm `Resultado atual` preenchido — este campo é
   obrigatório aqui, pois indica que um bug real foi confirmado (ver regra
   do `Resultado atual` no skill `test-case-writer`). Se estiver vazio,
   avisar o usuário e não prosseguir, já que não há bug confirmado para
   reportar.
4. Checar se o campo **GitHub issue** já está preenchido nessa página. Se
   já tiver um link, NÃO criar uma nova issue — informar ao usuário que já
   existe uma issue vinculada a esse caso (mostrando o link) e perguntar se
   ele quer prosseguir mesmo assim, criar uma issue adicional, ou cancelar.
   Nunca sobrescrever ou duplicar silenciosamente.

## Passo 2: Definir o repositório do GitHub

1. Se o usuário já mencionou o repositório nessa conversa, usar
   diretamente.
2. Se não mencionou, perguntar em qual repositório a issue deve ser
   aberta — mostrando o repositório do diretório atual (se houver um
   `.git` configurado) como sugestão padrão, mas sem presumir
   automaticamente caso existam múltiplos repositórios possíveis.

REGRA DE SEGURANÇA: se a ferramenta de criação de issue (`gh` CLI ou MCP do
GitHub) não estiver disponível ou não estiver autenticada, NUNCA procurar
por conta própria tokens, credenciais ou chaves de acesso em variáveis de
ambiente, arquivos de configuração, ou qualquer outro lugar do sistema.
Parar e perguntar diretamente ao usuário como ele prefere prosseguir (ex:
instalar a ferramenta, autenticar, ou fornecer um token manualmente). Essa
decisão é sempre do usuário, nunca do skill.

## Passo 3: Traduzir o título para inglês

1. Resumir o problema em um título curto e claro, em **inglês**, seguindo
   o padrão do time.
2. Manter o título objetivo e descritivo do problema (não do teste em si)
   — ex: "Pagination button fails under 'All users' filter", não "Teste de
   paginação".
3. Se não tiver certeza da tradução mais natural de algum termo técnico do
   domínio do projeto, perguntar ao usuário em vez de traduzir literalmente.

## Passo 4: Montar o corpo da issue

Usar esta estrutura, mantendo o conteúdo em português (mesmo idioma do
caso de teste original):

REGRA DE LINGUAGEM: o campo "Resultado atual (bug)" do caso de teste deve
já vir em linguagem simples (essa tradução é feita no `test-case-writer`).
Se, ainda assim, algum log técnico bruto aparecer nessa seção, não copiar
diretamente para o corpo principal da issue — mover esse trecho técnico
para uma seção separada de "Detalhes técnicos" no final, e manter o corpo
principal em linguagem que qualquer pessoa do time entenda.

```
## Objetivo do teste
[Copiar do campo Objetivo do caso de teste]

## Passos para reproduzir
[Copiar os Passos para reproduzir do caso de teste]

## Resultado esperado
[Copiar o Resultado esperado do caso de teste]

## Resultado atual (bug)
[Copiar o Resultado atual do caso de teste — em linguagem simples]

## Impacto observado
[Copiar, se houver]

## Evidências
[Copiar prints/links, se houver]

## Detalhes técnicos (opcional)
[Log de erro, stack trace, ou referência técnica bruta, se disponível —
apenas como complemento, nunca substituindo o resumo acima]

---
Caso de teste original: [link da página do Notion]
```

## Passo 5: Definir labels

1. Consultar as labels já existentes no repositório (via GitHub MCP ou
   `gh label list`) antes de sugerir qualquer uma.
2. Sugerir labels compatíveis com o conteúdo (ex: `bug`, e uma de
   prioridade se o repositório já tiver esse padrão, ex: `priority-high`).
3. Se o repositório não tiver uma label equivalente à Prioridade definida
   no Notion, avisar o usuário em vez de criar uma label nova sem
   confirmação.

## Passo 6: Confirmar antes de criar

Mostrar um resumo: repositório, título (em inglês), labels sugeridas, e um
preview do corpo da issue. Pedir confirmação do usuário antes de criar de
fato — a menos que ele já tenha pedido explicitamente para criar direto.

## Passo 7: Criar a issue e atualizar o Notion

1. Criar a issue no repositório definido, com título, corpo e labels
   confirmados.
2. Pegar a URL e o título da issue criada.
3. Atualizar dois campos na página do caso de teste no Notion:
   - **GitHub issue** (link): a URL da issue criada.
   - **Title issue** (texto): o título da issue, em inglês, exatamente
     como foi criado no GitHub.
4. Se a criação da issue falhar, ou se a atualização de qualquer um dos
   dois campos no Notion falhar, não prosseguir silenciosamente — avisar o
   usuário exatamente em qual etapa o erro ocorreu e quais campos ficaram
   sem preencher.

REGRA PARA LOTES: se estiver processando vários casos de teste (Passo 1,
item 2) e um deles falhar em qualquer etapa, NÃO abortar o lote inteiro
nem pular o caso silenciosamente. Continuar processando os demais casos
normalmente, e ao final apresentar um resumo claro: quais casos tiveram
issue criada com sucesso, e quais falharam (com o motivo de cada falha).

## Passo 8: Confirmar ao usuário

Mostrar o link da issue criada e confirmar que os campos **GitHub issue**
e **Title issue** no Notion foram atualizados com sucesso.