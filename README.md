# request-management

Solution for the "Requests search" candidate test.

| Part | Location |
|---|---|
| Backend (.NET 8 Web API, EF Core) | [`server/`](server) – submodule `request-management-server` |
| Frontend (React + Vite + TypeScript) | [`front/`](front) – submodule `request-management-front` |
| Architecture (Part B) | [`docs/architecture.md`](docs/architecture.md) |

## Getting the code

```bash
git clone --recurse-submodules <this-repo-url>
# or, if already cloned:
git submodule update --init
```

## Running

Prerequisites: .NET 8 runtime + an SDK that can build `net8.0` (8.0 or newer), Node.js 20+.

**Both at once** (Windows) – opens one window for the backend and one for the frontend:

```powershell
./dev.ps1
```

**Backend** – listens on `https://localhost:60701` / `http://localhost:60702`, Swagger at `/swagger`:

```bash
cd server
dotnet run --project src/Requests.Api
```

**Frontend** – dev server on `http://localhost:5173`; `/api` calls are proxied to the backend:

```bash
cd front
npm install
npm run dev
```

The current user is simulated with request headers: `X-User-Id: <int>` and `X-Is-Admin: true|false`.

## Tests

```bash
cd server
dotnet test
```

## Technologies and why

_TODO_

## Assumptions

_TODO_

## Technical decision with alternatives

_TODO_

## Not done / next steps

_TODO_
