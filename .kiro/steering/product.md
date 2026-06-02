# Product Context

## Visão Geral
API backend do sistema de gerenciamento de cargas de recebimento no CD da Havan. Controla o fluxo de entrada de cargas, conferência, status e rastreamento.

## Funcionalidades Principais
- CRUD de cargas de recebimento
- Gestão de status e fluxo de recebimento
- Conferência de carga (itens, notas)
- Integração com sistemas de transporte e fiscal
- Consulta de histórico e rastreamento

## Consumidores
- RecebimentoCargaReact (frontend)
- Aplicações mobile de conferência
- Sistemas internos de logística

## Regras de Negócio
- Cargas possuem fluxo de status definido
- Conferência vinculada a notas fiscais
- Integração com transportadoras e fornecedores
