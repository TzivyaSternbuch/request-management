# request-management

Solution for the "Requests search" candidate test.

| Part | Location |
|---|---|
| Backend (.NET 8 Web API, EF Core, SQLite) | [`server/`](server) – submodule `request-management-server` |
| Frontend (React + Vite + TypeScript) | [`front/`](front) – submodule `request-management-front` |
| Architecture (Part B) | [`docs/architecture.md`](docs/architecture.md) |

## Getting the code

```bash
git clone --recurse-submodules <this-repo-url>
# or, if already cloned:
git submodule update --init
```

## Install and build

Prerequisites: .NET 8 runtime + an SDK that can build `net8.0` (8.0 or newer), Node.js 20+.

**Backend**

```bash
cd server
dotnet restore
dotnet build
```

**Frontend**

```bash
cd front
npm install
npm run build
```

`npm run build` runs the TypeScript check (`tsc -b`) and then the Vite production build into `front/dist`.

## Running


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

### Database

The backend uses **SQLite**. The database file `requests.db` is created next to the Api build output
(`server/src/Requests.Api/bin/Debug/net8.0/requests.db`).

On startup the backend:

1. applies the EF Core migrations (creates the tables and the search indexes),
2. seeds the data if the tables are empty: **50 users** and **100,000 requests**.

100,000 requests is a test amount, not a limit. Search, sorting and paging run in the database with
indexes and return one page at a time, so the same code works with many more rows. To try a larger
amount, change `SeedCount` in `server/src/Requests.Infrastructure/Persistence/DbSeeder.cs` and delete
`requests.db`.

The first start takes a few seconds because of the seeding; later starts reuse the same file.
To start over with fresh data, stop the backend and delete `requests.db`.

### Logging in

There is no password. The login screen asks for a **user id**; the server checks that the user exists
(`GET /api/users/me`) and returns whether they are an administrator. The role is read from the
database, never chosen by the client.

| User id | Role | Sees |
|---|---|---|
| `1`, `2` | Administrator | All requests |
| `3` – `50` | Regular user | Only requests they own or are assigned to |

Any other id is rejected with `401`.

When calling the API directly (Swagger, curl), send the header `X-User-Id: <id>`.
In Swagger use the **Authorize** button.

## Tests

**Backend** – xUnit, Application services and query logic tested with hand-written fakes:

```bash
cd server
dotnet test
```

Covers: who may see which request, every search filter, multi-field sorting and paging order,
and query validation (date range, sort parameters, request number length).

**Frontend** – Vitest + React Testing Library, the `src/api/` module is mocked:

```bash
cd front
npm test
npm run lint
npm run build
```

Covers: loading / error / empty / data states, the filter bar (search, status, type, date range, chips,
clear), sorting by column headers, paging, login, and keeping the user over a page reload.

## Technologies and why

| Technology | Why |
|---|---|
| .NET 8 Web API, layered (Domain / Application / Infrastructure / Api) | Business rules (who sees which request, filters) live in Application, independent of EF and HTTP, so they are tested without a database or a web server. |
| EF Core + SQLite + migrations | A real SQL database with real indexes, so filtering, sorting and paging really run in the database – and nothing to install. |
| React 19 + Vite + TypeScript | Fast dev server and build; TypeScript interfaces mirror the server DTOs, so API mistakes are caught at compile time. |
| Material UI | Ready, accessible table, menus, chips, date fields and pagination – the time goes into behaviour, not CSS. |
| TanStack Query | Caches server data per query and user, keeps the previous page on screen while the next one loads, and handles loading / error states. |
| React Router | Two screens (login, requests) as routes. |
| xUnit, Vitest + React Testing Library | Tests describe behaviour the user sees; fakes are hand-written instead of a mocking library, so tests are easy to read. |
| oxlint | Very fast linter, no configuration needed. |

### Why no global state library

The only data shared across the app is **server data** (the search results) and the **current user**.

- Server data is a cache of what the server has, not app state. TanStack Query already owns it:
  it caches, refreshes and shares it between components. Copying it into Redux/Zustand would create
  a second source of truth to keep in sync.
- The current user is small and changes only on login/logout; it is kept in `sessionStorage`.
- Everything else (filter values, sort order, open menus) belongs to one screen, so it stays as local
  React state in that screen or its hook.

A global store would add code and indirection without solving a problem the app has.

## Assumptions

- **Current user** – simulated by the `X-User-Id` header; there is no real login or password.
  The user must exist in the `Users` table, and the administrator flag comes from the database.
- **Visibility** – an administrator sees all requests. A regular user sees requests where they are
  the owner (`OwnerId`) **or** the assignee (`AssignedToUserId`).
- **Request number search** – partial match (`contains`), case-insensitive, up to 50 characters.
  The requirement asked for "contains", so it was kept even though a `LIKE '%term%'` query cannot use
  the index on `RequestNumber`.
- **Status and type** – several values can be chosen. Values of one filter are combined with OR,
  different filters with AND.
- **Created date** – whole calendar days in UTC, both ends included. `createdFrom` after `createdTo`
  is a validation error (`400`).
- **Sorting** – by request number, status, type and created date, by several fields at once in the
  order they were chosen. Default: newest first. `Id` is always added as the last sort key so rows with
  equal values keep a fixed order and pages never overlap or skip rows.
- **Paging** – page size 20 by default, at most 100 **rows per page** (`pageSize`); the number of pages
  is not limited.
- **Customer** – shown in the results but not filtered or sorted by, as the requirements do not ask for it.
- **Seed data** – 50 users (ids 1–2 administrators), 1,000 customer ids, 100,000 requests spread over the
  last 3 years; every 7th request is unassigned. The random seed is fixed, so every database gets the
  same data. 100,000 is enough to test the search; a real system can hold many more requests.

## Technical decision with alternatives

### SQLite instead of the EF Core InMemory provider

The project started with EF Core InMemory and was switched to SQLite.

| Option | Why not |
|---|---|
| EF Core InMemory | Not a relational database: queries are not translated to SQL and there are no indexes, so it cannot show that searching 100,000 rows really runs in the database. |
| SQL Server / PostgreSQL (e.g. in Docker) | Realistic, but the reviewer would need to install and run a database server. |
| Plain in-memory lists | Same problems as InMemory, and no EF at all. |

**Chosen: SQLite** – a real SQL database with migrations and indexes, stored in one file, started with
`dotnet run`. The cost: some behaviour differs from a production database (e.g. text collation,
date storage), and it is not meant for many concurrent writers.

### Other decisions that had alternatives

**Offset paging (`page` / `pageSize`) instead of keyset (cursor) paging.**
Offset paging lets the user jump to any page and show "1–20 of 4,213", which a results table needs.
Keyset paging (`WHERE (CreatedAt, Id) < (last seen)`) stays fast on very deep pages but only allows
next/previous. At this data size offset is fast enough; the stable `Id` tie-breaker keeps pages consistent.

**Searching automatically after a short pause (400 ms debounce) instead of a "Search" button.**
Results update while the user types or picks a filter, without an extra click, and the pause means a
request is sent only when typing stops, not on every keystroke. The previous results stay on screen
with a thin progress bar while the new ones load. A "Search" button is simpler and sends fewer requests,
but is slower to use for a filter-heavy screen.

## Not done / next steps


**UI / UX**

- The presentation needs improvement: the screens are functional but basic. A design pass on
  layout, spacing, colors, typography and the look of the table and filters would make it clearer
  and more pleasant to use.
- Paging controls also at the top of the table, not only at the bottom.
- "Go to page" input, first / last page buttons.
- Let the user choose the page size (20 / 50 / 100).
- Keep filters, sort and page in the URL, so a search can be bookmarked, shared and survives a reload.

**Security**

- Real authentication (JWT / OpenID Connect) instead of the `X-User-Id` header. Only the authentication
  handler would change – controllers get the user through `User.ToCurrentUser()`.
  The Identity Provider for this is described in [Part B](docs/architecture.md).


## Claude Code skills and commands

`.claude/commands/` holds a few commands used while building this project
(`design`, `implement`, `review`, `integration-test`, `update-projects`), and `CLAUDE.md` holds the
coding rules they follow.

They are **very basic** – a first version written at the start of the project to get going. They need a lot
of improvement: clearer steps, better checks, examples, and tuning from real use.
