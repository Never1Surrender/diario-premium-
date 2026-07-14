# Critérios de Revisão

## Segurança (checar primeiro)
- Injeção SQL: as entradas do usuário são parametrizadas?
- XSS: a saída é escapada corretamente antes de ser renderizada?
- Checagens de autenticação: rotas protegidas estão realmente protegidas?
- Segredos: existe API key ou credencial fixa (hardcoded) em algum lugar?
- Validação de entrada: a validação acontece do lado do servidor?

## Corretude
- A lógica bate com a intenção descrita?
- Casos extremos são tratados: arrays vazios, valores nulos, zero, números negativos?
- Estados de erro são exibidos corretamente?
- Operações assíncronas são aguardadas (await) corretamente?

## Legibilidade
- Alguém novo no time entenderia isso em 5 minutos?
- Nomes de variáveis e funções são descritivos?
- Cada função faz uma coisa só, ou várias ao mesmo tempo?

## Performance
- Existe algum padrão óbvio de N+1 queries?
- Operações custosas estão dentro de loops que poderiam estar fora?

## Testes
- Existem testes pro novo comportamento?
- Casos extremos são testados, não só o caminho feliz?