---
name: code-reviewer
description: Conduz revisões de código estruturadas com feedback categorizado.
Use quando o usuário pedir para "revisar esse código", "confere meu PR", "dá uma
olhada nessa função" ou "me dá feedback dessa implementação". Produz uma saída
estruturada separando problemas bloqueantes de sugestões.
---

# Code Reviewer

## Processo de revisão

### Passo 1: Entender o contexto

Antes de revisar, estabelecer:
- O que esse código deveria fazer?
- Qual linguagem e framework está sendo usado?
- É uma funcionalidade nova, correção de bug, ou refatoração?

### Passo 2: Rodar a revisão

Pros critérios detalhados de cada categoria, ver [references/criteria.md](references/criteria.md).

Percorrer cada categoria em ordem. Não pular nenhuma, mesmo que pareça improvável ter problema ali.

### Passo 3: Estruturar a saída

```
## Resumo
[2-3 frases de visão geral e avaliação geral]

## Problemas bloqueantes
[Problemas que precisam ser corrigidos: falhas de segurança, erros de lógica,
riscos de perda de dados. Se não tiver nenhum, escrever "Nenhum encontrado."]

## Sugestões
[Melhorias não-bloqueantes, numeradas. Incluir onde, por quê e como corrigir cada uma.]

## Pontos positivos
[O que o código faz bem. Sempre incluir pelo menos um.]
```