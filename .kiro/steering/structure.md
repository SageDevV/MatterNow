# Project Structure

```
├── Api/              # Camada de apresentação (Controllers, Program.cs)
├── Application/      # Camada de aplicação (AppServices, DTOs, Interfaces)
├── Domain/           # Camada de domínio (Entidades, Interfaces de repositório)
├── Data/             # Camada de dados (Repositórios, DbContext)
├── Http/             # Clientes HTTP para serviços externos
├── Ioc/              # Injeção de dependência (CrossCutting)
├── Teste/            # Testes unitários e integração
```

## Padrões de Organização
- Clean Architecture com separação clara de camadas
- Controllers delegam para AppServices
- AppServices orquestram lógica de aplicação
- Domain contém regras de negócio e entidades
- Data implementa repositórios e acesso a banco
- Http encapsula chamadas a APIs externas
- Ioc registra todas as dependências (DI container)
- Teste contém testes automatizados
