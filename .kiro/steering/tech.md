# Tech Stack

## Core
- .NET 10 (ASP.NET Core Web API)
- C# com Nullable disable, ImplicitUsings enable

## Banco de Dados
- PostgreSQL (Npgsql)
- SQL Server
- Entity Framework Core (ou Dapper)

## Infraestrutura
- HealthChecks
- Havan.AspNetCore.Swashbuckle (Swagger/OpenAPI)
- Pacotes internos Havan.*

## Arquitetura
- Clean Architecture (Api → Application → Domain ← Data)
- Dependency Injection via CrossCutting/Ioc
- Repository Pattern
- DTOs para transferência entre camadas

## Testes
- Projeto de testes dedicado (Teste/)

## Convenções
- Controllers com sufixo Controller
- AppServices com sufixo AppService
- Interfaces com prefixo I
- Repositórios com sufixo Repository
- Um controller por recurso/entidade
