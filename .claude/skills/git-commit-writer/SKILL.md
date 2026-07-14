---
name: git-commit-writer
description: Gera mensagens de commit padronizadas seguindo o padrão conventional
commits. Use quando o usuário pedir para "escrever uma mensagem de commit", "me
ajuda a commitar", "resume minhas mudanças", "o que devo colocar no commit" ou
"sugere um commit". Analisa o diff das mudanças pra propor uma mensagem no
formato tipo(escopo): descrição.
---

# Git Commit Message Writer

## Formato
tipo(escopo): descrição curta
[corpo opcional]
[rodapé opcional]

Tipos permitidos: feat, fix, docs, style, refactor, test, chore, perf, ci, build

## Instruções

### Passo 1: Pegar o diff

```bash
git diff --staged
```

Se não tiver nada no staging:
```bash
git diff HEAD
```

### Passo 2: Analisar as mudanças

Observar:
- Quais arquivos mudaram e a que categoria pertencem
- Se é uma funcionalidade nova (feat), correção de bug (fix), ou atualização de docs/config/teste
- O escopo: qual módulo, componente ou área foi afetada

### Passo 3: Escrever a mensagem

- Manter a linha de assunto com menos de 72 caracteres
- Usar modo imperativo: "adiciona funcionalidade", não "adicionou funcionalidade"
- Não terminar a linha de assunto com ponto final
- Adicionar corpo se a mudança precisar de mais contexto do que cabe no assunto

### Checagem de qualidade

- [ ] Tipo é um dos permitidos
- [ ] Linha de assunto tem menos de 72 caracteres
- [ ] Modo imperativo foi usado
- [ ] Escopo é específico o suficiente pra ser útil

## Exemplos

**Diff:** novo endpoint `POST /coupons` em `main.ts`, com bloco `@swagger` e validação de campos obrigatórios.
**Mensagem:**
```
feat(coupons): adiciona endpoint de criação de cupons
```

**Diff:** correção em `main.ts` onde `pool.query` concatenava o CPF diretamente na string SQL em vez de usar `?`.
**Mensagem:**
```
fix(users): usa parâmetro preparado na busca por CPF

Corrige concatenação direta do CPF na query, que abria brecha
para injeção SQL.
```

**Diff:** atualização do `DATABASE_EXPLANATION.md` descrevendo a tabela `refunds`.
**Mensagem:**
```
docs(database): documenta estrutura da tabela refunds
```

**Diff:** mudanças em `compose.yml` e `.env.example` ajustando `DB_HOST` do serviço `app`.
**Mensagem:**
```
chore(docker): ajusta DB_HOST do serviço app no compose
```