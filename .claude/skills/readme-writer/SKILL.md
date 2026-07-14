---
name: readme-writer
description: Cria e atualiza o arquivo README.md do projeto. Use quando o usuário pedir
para "criar um README", "atualizar o readme", "documentar esse projeto", "gerar
documentação do projeto" ou "escrever o README.md". Funciona a partir do código
existente no repositório.
---

# README Writer

## Visão geral

Gerar um README.md completo e profissional, escrevendo o arquivo direto no disco.
O resultado deve ser claro o suficiente pra alguém que nunca viu o projeto conseguir
entender do que se trata, configurar localmente e começar a contribuir.

## Passo 1: Levantar o contexto do projeto

Antes de perguntar qualquer coisa ao usuário, investigar o repositório:

\`\`\`bash
ls -la
cat package.json 2>/dev/null || cat composer.json 2>/dev/null || \
  cat requirements.txt 2>/dev/null || echo "Nenhum manifesto encontrado"
ls .env.example .env.sample 2>/dev/null || echo "Nenhum exemplo de env encontrado"
\`\`\`

Coletar:
- O que o projeto faz? (resumo de 1-2 frases)
- Qual linguagem e principais frameworks usa?
- Como instalar e rodar?
- Precisa de variáveis de ambiente?
- Existe um arquivo LICENSE?

## Passo 2: Escrever o README

Usar essa estrutura. Incluir só as seções relevantes — não deixar seção vazia:

\`\`\`
# Nome do Projeto

Uma frase clara descrevendo o que o projeto faz e pra quem é.

## Funcionalidades
- Funcionalidade 1
- Funcionalidade 2

## Pré-requisitos
O que precisa estar instalado, com versões se for importante.

## Instalação
Passo a passo, todo comando deve poder ser copiado e colado direto.

## Configuração
Se precisar de variáveis de ambiente, mostrar um exemplo e explicar cada uma.

## Uso
Mostrar o caso de uso mais comum primeiro.

## Licença
\`\`\`

## Passo 3: Escrever o arquivo no disco

Depois de pronto, escrever o conteúdo no README.md e confirmar quantas linhas foram
geradas.

## Passo 4: Checagem de qualidade

Antes de finalizar, confirmar:
- [ ] Não sobrou nenhum texto de placeholder tipo "[descrição aqui]"
- [ ] Todo comando na seção de Instalação está correto pro projeto real
- [ ] Pré-requisitos batem com o que o projeto realmente precisa
- [ ] Seção de Licença bate com o arquivo LICENSE, se existir