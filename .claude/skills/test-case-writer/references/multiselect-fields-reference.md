# Preenchimento de campos multi-select (Módulo, Tipo, Prioridade)

Esses campos variam de projeto para projeto — NÃO existe uma lista fixa de valores válidos entre projetos diferentes.

Antes de criar qualquer página no Notion, siga este processo:

1. **Consulte o schema do database** (via ferramenta do MCP) para descobrir quais opções já existem cadastradas em cada campo multi-select (Módulo, Tipo, Prioridade) daquele projeto específico.

2. **Se o cenário descrito pelo usuário corresponder claramente a uma opção existente**, preencha automaticamente o campo com essa opção.

3. **Se não houver correspondência clara** (ex: o módulo não existe na lista, ou está ambíguo entre duas opções), NÃO crie uma opção nova e NÃO deixe o campo em branco. Em vez disso, pergunte ao usuário qual valor usar, mostrando as opções existentes no database como referência.

4. **Nunca deixe Módulo, Tipo ou Prioridade vazios silenciosamente.** Esses campos são obrigatórios para o fluxo de triagem da equipe — se a informação não está clara, é melhor perguntar do que assumir.

Isso garante que o skill continue reaproveitável entre projetos diferentes (Linus Gallery, Imobza, ou qualquer projeto futuro), sem depender de uma lista de valores fixa no próprio skill.