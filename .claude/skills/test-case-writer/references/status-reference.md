# Status dos casos de teste

Os valores de Status seguem sempre esta convenção fixa, independente do projeto:

- **Em execução** — o caso está sendo testado no momento, ainda sem resultado final.
- **Aprovado** — o teste foi executado e o comportamento observado está de acordo com o esperado/documentado.
- **Aberto/Bug** — o teste foi executado e o comportamento observado viola claramente uma regra conhecida ou documentada.

  *Quando um caso entra em "Aberto/Bug", este é o gatilho natural para rodar o skill `issue-writer`, que cria a issue correspondente no GitHub e preenche o campo de URL da issue de volta nesta página.*

- **Triagem** — o teste foi executado, mas o comportamento observado NÃO pode ser classificado com certeza como bug ou como esperado, porque não há regra de negócio documentada sobre aquele caso específico. Fica pendente de validação com o dev: se ele confirmar que o sistema NÃO deveria permitir aquilo, o caso vira Aberto/Bug; se confirmar que está dentro do esperado, o caso vira Aprovado.

  *Exemplo: o sistema permite cadastro com data retroativa, e não existe documentação dizendo que isso deveria ser bloqueado. Não dá pra classificar como bug com certeza — vai pra Triagem até o dev confirmar a regra.*

- **Corrigido** — selecionado pelo dev para sinalizar que o bug foi corrigido e o caso precisa ser retestado.
- **Revalidado** — depois do reteste pós-correção, o comportamento agora está de acordo com o esperado.

## Regra de preenchimento pelo skill

O skill só define o status **Em execução** no momento da criação do caso de teste (antes de qualquer execução real). Os demais status — Aprovado, Aberto/Bug, Triagem, Corrigido, Revalidado — dependem do resultado real da execução ou de uma ação humana (dev corrigindo, QA revalidando), e nunca devem ser definidos automaticamente pelo skill no momento da criação.