---
name: test-case-writer
description: Gera casos de teste no formato padrão de QA (Objetivo, Pré-condições,
Passos para reproduzir, Resultado esperado) e cria a página correspondente
diretamente no Notion via MCP, preenchendo Status, Módulo, Tipo, Prioridade e ID
automaticamente. Use quando o usuário pedir para "criar um caso de teste", "gerar
casos de teste", "escrever test cases", "documentar teste para essa funcionalidade",
"criar TC para", "subir caso de teste no Notion" ou "criar página de teste no
Notion". Funciona a partir da descrição de uma funcionalidade, do código-fonte, ou
de telas do sistema.
---

# Test Case Writer

## Visão geral

Gerar casos de teste completos, no formato usado pela equipe de QA, e criar
a página correspondente diretamente no Notion (via MCP), com os campos de
Status, Módulo, Tipo, Prioridade e ID preenchidos automaticamente conforme
as regras do projeto. Cada caso de teste deve ser claro o suficiente pra
qualquer pessoa do time reproduzir sem depender de quem escreveu, e deve
respeitar a estrutura de campos já existente no database daquele projeto
específico.

## Passo 1: Levantar o contexto

Descobrir a fonte de informação disponível, verificando na ordem:

1. **Se o usuário descreveu a funcionalidade em texto** → usar essa descrição
   como base.
2. **Se não descreveu, mas existe código relacionado no repositório** → inspecionar
   os arquivos relevantes (rotas, componentes, controllers) pra entender o fluxo.
3. **Se existir print de tela ou referência visual** → usar como apoio pra
   entender os elementos da interface.

Se nenhuma fonte for suficiente pra entender o fluxo completo, perguntar ao
usuário antes de prosseguir — não inventar comportamento não confirmado.

## Passo 2: Definir o database do Notion

Antes de qualquer outra coisa, identificar qual database do Notion será
usado:

1. **Se o usuário já mencionou qual projeto/database usar nessa conversa**
   (ex: "cria isso no database do Linus Gallery"), usar essa informação
   diretamente, sem perguntar de novo.

2. **Se não foi mencionado**, perguntar ao usuário qual database usar,
   mostrando os databases de Casos de Teste conectados à integration como
   opções (consultar via MCP quais databases estão acessíveis).

3. **Nunca presumir** um database por padrão (ex: "o último usado" ou "o
   primeiro da lista") — cada projeto tem seu próprio database, e usar o
   errado pode criar um caso de teste no lugar errado silenciosamente.

Esse database escolhido é o que será consultado em todos os passos
seguintes (prefixo, schema de Módulo/Tipo/Prioridade, numeração de ID).

## Passo 3: Definir o prefixo do módulo

1. Consultar o database (definido no Passo 2) no Notion para descobrir quais prefixos de ID já
   existem em uso (ex: AUT-, GAL-, USU-, TAG-).

2. Se o cenário descrito pelo usuário corresponder claramente a um módulo
   com prefixo já existente, usar esse prefixo automaticamente.

3. Se não houver correspondência clara, ou se for o primeiro caso de teste
   de um módulo novo, perguntar ao usuário qual prefixo usar — mostrando
   os prefixos já existentes como referência, pra ele decidir se é um
   módulo novo ou já cadastrado.

Não presumir um prefixo genérico — cada projeto/módulo tem o seu.

*O número sequencial (NN) que completa o ID é definido separadamente, no
Passo 6, item 3 — este passo cuida apenas da letra do prefixo.*

## Passo 4: Escrever o caso de teste

Usar exatamente essa estrutura:

```
ID: [PREFIXO-NN]
Título: [até 60 caracteres, resumindo o objetivo do teste]

🎯 Objetivo
[Descreva brevemente o que este teste pretende validar.]

🔧 Pré-condições
- [condição necessária antes de iniciar o teste]
- [outra condição, se houver]

📋 Passos para reproduzir
1. [passo objetivo e verificável]
2. [próximo passo]
[...]

✅ Resultado esperado
[Texto corrido, em prosa — sem numerar ou rotular passos aqui dentro. O que
deveria acontecer se o sistema estivesse funcionando 100%.]

❌ Resultado atual (preencher apenas se houver bug)
REGRA OBRIGATÓRIA: este campo só deve conter texto se o teste foi executado
E um bug foi identificado. Em qualquer outro caso — teste ainda não
executado, teste executado com sucesso, ou você não tem informação sobre
o resultado real — este campo deve ficar EXATAMENTE vazio (sem texto, sem
"N/A", sem "não testado ainda", sem nenhum preenchimento).

Antes de escrever qualquer coisa neste campo, pergunte-se: "Eu tenho uma
confirmação real de que um erro ocorreu?" Se a resposta for não, deixe em
branco.

✅ Checklist de Validação
- [ ] Web: Testado no fluxo principal da funcionalidade.
- [ ] Mobile: Testado em dispositivos móveis (Android/iOS), quando aplicável.
- [ ] Browsers: Testado em Chrome.
- [ ] Rede: Validado com latência (Slow 3G), quando relevante.
- [ ] Regressão: A correção não afetou outras funções.
- [ ] Evidência: Print/vídeo anexado.
- [ ] Resultado esperado: Validado com sucesso.
- [ ] Resultado atual: Preenchido apenas se houver bug.

🌐 Impacto observado:
[Preencher se houver impacto em outras áreas do sistema]

📎 Evidências
[Cole aqui prints ou links de vídeos]
```

## Passo 5: Checagem de qualidade

Antes de entregar, confirmar:
- [ ] Título tem 60 caracteres ou menos
- [ ] "Resultado esperado" está em prosa corrida, sem rótulos de passo
- [ ] Passos para reproduzir são objetivos e na ordem correta
- [ ] Pré-condições cobrem tudo que é necessário pro teste ser executado
      isoladamente
- [ ] "Resultado atual" segue a REGRA OBRIGATÓRIA do Passo 4: está vazio,
      a menos que haja confirmação real de bug identificado
- [ ] Nenhum comportamento foi presumido sem confirmação (ex: mensagens de
      erro específicas, textos exatos) — se não tiver certeza, sinalizar como
      suposição em vez de afirmar
- [ ] Checklist de Validação incluído completo, com todos os itens desmarcados
      por padrão (o usuário marca depois de executar)

## Passo 6: Definir status inicial e campos do Notion

Antes de criar a página no Notion, definir os seguintes campos, nesta ordem
(sempre referentes ao database definido no Passo 2):

1. **Status**: sempre "Em execução" na criação. Ver `references/status-reference.md`.
2. **Módulo, Tipo, Prioridade**: consultar o schema do database e preencher
   ou perguntar conforme necessário. Ver `references/multiselect-fields-reference.md`.
3. **ID/número sequencial**: consultar o database para descobrir o último
   número usado com aquele prefixo e usar o próximo disponível.
4. **Colunas ausentes**: se alguma coluna esperada não existir no database
   desse projeto, avisar o usuário em vez de criar ou ignorar silenciosamente.

## Passo 7: Confirmar antes de criar no Notion

Mostrar um resumo dos campos que serão preenchidos (Título, Módulo, Tipo,
Prioridade, Status) e pedir confirmação do usuário antes de criar a página
de fato — a menos que o usuário já tenha pedido explicitamente para criar
direto, sem revisão.

Se o usuário pedir ajuste em algum campo, aplicar o ajuste e mostrar o
resumo novamente antes de prosseguir.

## Passo 8: Criar a página no Notion

Com a confirmação obtida (Passo 7), usar a ferramenta do MCP para criar a
página no database correto, com todos os campos definidos nos Passos 4 e 6.

Se a criação falhar (erro de permissão, campo inválido, database não
encontrado, etc.), não tentar contornar o erro criando a página com campos
incompletos ou em outro database. Mostrar o erro ao usuário e perguntar
como prosseguir.

Após criar com sucesso, confirmar ao usuário com o link da página criada.

## Passo 9: Perguntar se há mais casos a cobrir

Perguntar ao usuário se há outros cenários ou casos de teste da mesma
funcionalidade que ainda precisam ser documentados, antes de encerrar.