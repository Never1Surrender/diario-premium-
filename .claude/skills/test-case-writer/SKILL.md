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

## Passo 2: Definir o prefixo do módulo

Perguntar ao usuário (se ainda não tiver sido informado nessa conversa) qual é
o prefixo de ID usado nesse projeto para esse módulo (ex: AUT-, USU-, GAL-,
TAG-). Não presumir um prefixo genérico — cada projeto/módulo tem o seu.

## Passo 3: Escrever o caso de teste

Usar exatamente essa estrutura:
ID: [PREFIXO-NN]
Título: [até 60 caracteres, resumindo o objetivo do teste]
🎯 Objetivo
[Descreva brevemente o que este teste pretende validar.]
🔧 Pré-condições

[condição necessária antes de iniciar o teste]
[outra condição, se houver]

📋 Passos para reproduzir

[passo objetivo e verificável]
[próximo passo]
[...]

✅ Resultado esperado
[Texto corrido, em prosa — sem numerar ou rotular passos aqui dentro. O que
deveria acontecer se o sistema estivesse funcionando 100%.]
❌ Resultado atual (preencher apenas se houver bug)
[REGRA OBRIGATÓRIA: este campo só deve conter texto se o teste foi executado
E um bug foi identificado. Em qualquer outro caso — teste ainda não
executado, teste executado com sucesso, ou você não tem informação sobre
o resultado real — este campo deve ficar EXATAMENTE vazio (sem texto, sem
"N/A", sem "não testado ainda", sem nenhum preenchimento).

Antes de escrever qualquer coisa neste campo, pergunte-se: "Eu tenho uma
confirmação real de que um erro ocorreu?" Se a resposta for não, deixe em
branco.]
✅ Checklist de Validação

 Web: Testado no fluxo principal da funcionalidade.
 Mobile: Testado em dispositivos móveis (Android/iOS), quando aplicável.
 Browsers: Testado em Chrome.
 Rede: Validado com latência (Slow 3G), quando relevante.
 Regressão: A correção não afetou outras funções.
 Evidência: Print/vídeo anexado.
 Resultado esperado: Validado com sucesso.
 Resultado atual: Preenchido apenas se houver bug.

🌐 Impacto observado:
[Preencher se houver impacto em outras áreas do sistema]
📎 Evidências
[Cole aqui prints ou links de vídeos]

## Passo 4: Checagem de qualidade

Antes de entregar, confirmar:
- [ ] Título tem 60 caracteres ou menos
- [ ] "Resultado esperado" está em prosa corrida, sem rótulos de passo
- [ ] Passos para reproduzir são objetivos e na ordem correta
- [ ] Pré-condições cobrem tudo que é necessário pro teste ser executado
      isoladamente
- [ ] "Resultado atual" segue a REGRA OBRIGATÓRIA do Passo 3: está vazio,
      a menos que haja confirmação real de bug identificado
- [ ] Nenhum comportamento foi presumido sem confirmação (ex: mensagens de
      erro específicas, textos exatos) — se não tiver certeza, sinalizar como
      suposição em vez de afirmar
- [ ] Checklist de Validação incluído completo, com todos os itens desmarcados
      por padrão (o usuário marca depois de executar)

## Passo 5: Definir status inicial e campos do Notion

Antes de criar a página no Notion:

Antes de criar a página no Notion, definir os seguintes campos, nesta ordem:

1. **Status**: sempre "Em execução" na criação. Ver `references/status-reference.md`.
2. **Módulo, Tipo, Prioridade**: consultar o schema do database e preencher
   ou perguntar conforme necessário. Ver `references/multiselect-fields-reference.md`.
3. **ID/número sequencial**: consultar o database para descobrir o último
   número usado com aquele prefixo e usar o próximo disponível.
4. **Colunas ausentes**: se alguma coluna esperada não existir no database
   desse projeto, avisar o usuário em vez de criar ou ignorar silenciosamente.

## Passo 6: Confirmar antes de criar no Notion

Mostrar um resumo dos campos que serão preenchidos (Título, Módulo, Tipo,
Prioridade, Status) e pedir confirmação do usuário antes de criar a página
de fato — a menos que o usuário já tenha pedido explicitamente para criar
direto, sem revisão.

## Passo 7: Perguntar se há mais casos a cobrir

Para os valores válidos de Status e quando usar cada um, consulte
`references/status-reference.md`.

Para o processo de preenchimento de Módulo, Tipo e Prioridade, consulte 
`references/multiselect-fields-reference.md`.