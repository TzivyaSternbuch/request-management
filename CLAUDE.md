# request-management

Candidate test: "Requests search". The author must be able to explain every line,
so prefer simple, readable code over clever code.

## Layout

- `server/` – submodule `request-management-server` (.NET 8 Web API, EF Core in-memory, xUnit)
- `front/` – submodule `request-management-front` (React 19 + Vite + TypeScript, oxlint)
- `docs/architecture.md` – Part B (microservices, reliable notifications)
- `dev.ps1` – starts backend and frontend in two windows

Changes inside `server/` or `front/` are commits in those submodule repos;
the root repo then commits the updated submodule pointer.

## Commands

| What | Command |
|---|---|
| Run both | `./dev.ps1` |
| Run backend | `cd server && dotnet run --project src/Requests.Api` (http://localhost:60702, Swagger at `/swagger`) |
| Test backend | `cd server && dotnet test` |
| Run frontend | `cd front && npm run dev` (http://localhost:5173, `/api` proxied to backend) |
| Lint / typecheck frontend | `cd front && npm run lint && npm run build` |
| Test frontend | `cd front && npm test` (Vitest – once set up) |

Current user is simulated with headers `X-User-Id: <int>` and `X-Is-Admin: true|false`.

## How to work in this repo

- Only do what was asked. No feature code unless explicitly requested.
- Keep changes small and focused; one concern per commit.
- Before any commit or push: list the files and target repo, and wait for approval.
- When introducing a new tool, package or pattern, explain what it is and why.
- After changing code: run the tests/lint above and report the real result.
- Match the existing style of the file you are editing.

## Clean code – general

- Names say what a thing is or does; no abbreviations (`request`, not `req`/`r`), except `x` in short lambdas.
- Small methods/functions with one responsibility; early returns instead of deep nesting.
- No dead code, commented-out code, or unused usings/imports.
- No magic strings/numbers – use a named constant or enum.
- Comments explain *why*, not *what*. Keep them rare.
- Don't add abstractions "for the future" – only what the current requirement needs.

## Server (.NET)

### Layers and dependencies

```
Api  ──►  Application  ──►  Domain
 │             ▲
 └──►  Infrastructure (implements Application interfaces)
```

- **Domain** (`Requests.Domain`): entities and enums only. No references to other projects or packages.
- **Application** (`Requests.Application`): use cases (services), interfaces (`IRequestRepository`),
  DTOs. No EF Core, no ASP.NET. Business rules (e.g. who may see which request) live here.
- **Infrastructure** (`Requests.Infrastructure`): EF Core `DbContext`, repositories, seeding,
  DI registration (`AddInfrastructure`). The only place that knows about EF.
- **Api** (`Requests.Api`): controllers, `Program.cs`. Controllers are thin: read the request
  (route/query/headers), call one service method, return the result. No business logic, no `DbContext`.
  Get the current user with `User.ToCurrentUser()` (`Api/Authentication/ClaimsPrincipalExtensions.cs`);
  never read the `X-User-Id` / `X-Is-Admin` headers or the claims directly in a controller.
  All controllers require a user (`MapControllers().RequireAuthorization()` in `Program.cs`);
  mark public endpoints with `[AllowAnonymous]`; don't add `[Authorize]`.

### Conventions

- Feature folders: `Application/Requests/`, `Infrastructure/Repositories/`, etc.
- File-scoped namespaces matching the folder path.
- `record` for DTOs (`RequestDto`). Don't use `sealed` unless there is a concrete reason.
- Constructor injection into `private readonly` fields named `_camelCase`.
- Interfaces start with `I` and sit next to the code that uses them (Application).
- Async all the way: methods end with `Async`, return `Task<...>`, and take
  `CancellationToken cancellationToken = default` as the last parameter, passed down to EF.
- Return read-only types from services (`IReadOnlyList<T>`).
- Never return domain entities from the API – map to DTOs in the Application layer.
- Filtering/searching should run in the database (`IQueryable` in the repository),
  not by loading everything into memory.
- Nullable reference types are enabled – no `!` suppression without a reason.

### Tests (`tests/Requests.Tests`, xUnit)

- Test Application services with hand-written fakes (see `FakeRequestRepository`), not mocks libraries.
- Test names describe the behaviour: `RegularUser_CanSeeOwnedOrAssignedRequests`.
- Arrange / Act / Assert, one behaviour per test; small `Create(...)` helpers for test data.
- Every business rule (permissions, search filters) gets a test.

## Front (React + TypeScript)

- Function components only; one component per file, `PascalCase.tsx`.
- No `any`. Type API data with interfaces that mirror the server DTOs (same field names, camelCase).
- All HTTP calls go through one module (e.g. `src/api/`), never `fetch` directly inside components.
  Use relative `/api/...` URLs (the Vite proxy handles the backend address).
- Logic and data loading in custom hooks (`useRequests`); components focus on rendering.
- Always handle the three states of a request: loading, error, data (including empty).
- Keep state as local as possible; no global state library unless clearly needed.
- `npm run lint`, `npm test` and `npm run build` must pass with no warnings before committing.

### Tests (Vitest + React Testing Library)

- Test files sit next to the code: `Component.test.tsx`, `useHook.test.ts`.
- Mock the `src/api/` module (`vi.mock`), never the network.
- Test behaviour the user sees (`getByRole`, `getByText`, `userEvent`), not implementation details.
- Cover loading, error, empty and data states, and every filter/search interaction.
