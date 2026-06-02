# MatterNow

Monorepo do MatterNow contendo backend (.NET 10) e app Flutter.

```
MatterNow/
├── backend/           # API .NET 10 (Clean Architecture)
└── frontend/
    └── matternow_app/ # App Flutter
```

## Backend

Stack: .NET 10, EF Core, JWT, BCrypt, Swagger, HealthChecks. Banco padrão SQLite (arquivo local) — basta trocar `Database:Provider` para `Postgres` em `appsettings.json` para usar PostgreSQL.

```cmd
cd backend
dotnet build
dotnet run --project src\MatterNow.Api
```

- API: http://localhost:5080
- Swagger: http://localhost:5080/swagger
- Health: http://localhost:5080/health

Na primeira execução o banco é criado via `EnsureCreated` e um seed popula a comunidade com anúncios mockados para o feed da home (roda só uma vez por banco).

### Endpoints

Auth (públicos):

- `POST /api/auth/register` — `{ "nome", "email", "senha" }` → 201 + JWT
- `POST /api/auth/login` — `{ "email", "senha" }` → 200 + JWT
- `POST /api/auth/forgot-password` — `{ "email" }` → 204 (sempre, para evitar enumeração de e-mails)
- `POST /api/auth/reset-password` — redefine senha usando o código enviado por e-mail

Autenticados (Bearer JWT):

- `GET  /api/feed/home` — dados consolidados da home (saudação, feed, recomendações)
- `GET/POST/PUT/DELETE /api/filhos` — CRUD de filhos vinculados ao usuário
- `GET  /api/notificacoes` — lista de notificações (mais recentes primeiro)
- `POST /api/notificacoes/marcar-lidas` — marca todas como lidas
- `GET/PUT  /api/usuarios/me` — perfil do usuário
- `PUT  /api/usuarios/me/email` — alterar e-mail
- `PUT  /api/usuarios/me/password` — alterar senha
- `GET/PUT  /api/usuarios/me/notifications` — preferências de notificação
- `DELETE   /api/usuarios/me` — cancelar conta

### Configuração

`appsettings.json`:

- `Jwt.SigningKey` — DEVE ser substituída antes de qualquer ambiente além de dev.
- `Database.Provider` — `Sqlite` (padrão) ou `Postgres`.
- `ConnectionStrings.Default` — connection string de acordo com o provider.
- `Email.Provider` — `Console` (apenas loga no terminal, ideal para dev) ou `Smtp` (envio real, exige `Host`, `Port`, `Username`, `Password`, `UseStartTls`).

CORS está liberado por padrão para facilitar o desenvolvimento do app Flutter.

## Frontend

Stack: Flutter SDK `>=3.4.0 <4.0.0`, `http`, `flutter_secure_storage`, `google_fonts`. Tema replica a paleta do design Figma (verde-água `#21A9B4`, azul `#1A508E`, fonte Sora).

```cmd
cd frontend\matternow_app
flutter pub get
flutter run
```

Por padrão o app aponta para `http://localhost:5080` (e `http://10.0.2.2:5080` em emulador Android). Para sobrescrever:

```cmd
flutter run --dart-define=MATTERNOW_API_URL=http://192.168.0.10:5080
```

Telas implementadas:

- **Autenticação**
  - **Convite** (`/invite`) — tela inicial para usuários não autenticados, replica o frame Figma "1 - cadastro".
  - **Escolha de auth** (`/auth-choice`) — caminho entre cadastro e login.
  - **Login** (`/login`) — replica visual da tela do Figma "2 - cadastro".
  - **Termos** (`/terms`) — aceite de termos antes do cadastro.
  - **Cadastro** (`/register`) — Nome, e-mail, senha e confirmação, integrado ao endpoint `register`.
  - **Confirmação de conta** (`/account-confirmation`) — pós-cadastro.
  - **Esqueci a senha / Redefinir senha** (`/forgot-password`, `/reset-password`) — fluxo completo de recuperação por código.
- **Home** (`/home`) — shell principal pós-login, consome `/api/feed/home`.
- **Comunidade** (`/community`) — feed da comunidade.
- **Perfil** (`/profile`, `/profile/edit`) — visualização e edição.
- **Filhos** (`/children`) — lista e gestão dos filhos do usuário.
- **Notificações** (`/notificacoes`) — lista e ação "marcar como lidas".
- **Anunciar** (`/anunciar/vender`, `/anunciar/doar`, `/anunciar/perguntar`, `/anunciar/indicar`) — fluxos de criação de anúncio.
- **Meus posts** (`/meus-posts`) e **Meus recebidos** (`/meus-recebidos`) — gestão dos próprios anúncios e itens recebidos.

Fluxo: ao abrir o app, `_RootGate` em `main.dart` checa o JWT salvo. Sem token → tela de escolha de autenticação. Com token → Home. O JWT é guardado em `flutter_secure_storage`.
