---
description: Write and run API integration tests (real HTTP pipeline + EF in-memory DB) for an endpoint or feature.
argument-hint: <endpoint or feature, e.g. "GET /api/requests search">
---

Write integration tests for: $ARGUMENTS

Integration tests call the real API over HTTP in-process – routing, headers, controller,
service, repository and EF together – unlike unit tests, which test one service with fakes.

## Setup (first time only – ask before doing it)

If `server/tests/Requests.IntegrationTests` does not exist, propose creating it and explain
each piece, then wait for approval:
- New xUnit project `tests/Requests.IntegrationTests` (net8.0), added to `Requests.sln`,
  referencing `src/Requests.Api`.
- Package `Microsoft.AspNetCore.Mvc.Testing` (version matching .NET 8) – provides
  `WebApplicationFactory<Program>`, which starts the API in memory.
  (`Program.cs` already has `public partial class Program { }` for this.)
- A `RequestsApiFactory : WebApplicationFactory<Program>` that replaces the
  `RequestsDbContext` registration with an in-memory database with a **unique name per test
  class**, so tests don't share data.
- A small helper to create an `HttpClient` with `X-User-Id` / `X-Is-Admin` headers.

## Writing the tests

1. Read the controller, service and DTOs for the endpoint, and `CLAUDE.md`.
2. Each test seeds **its own** data (don't rely on `DbSeeder` data – it may change).
3. Cover, for the endpoint:
   - happy path: status code and response body (deserialize to the DTO, assert fields),
   - every business rule through HTTP (e.g. admin sees all, user sees only owned/assigned),
   - each query parameter / filter, alone and combined; sorting and paging if present,
   - invalid input → expected status code (400/404),
   - missing or invalid headers → the documented behaviour.
4. Naming: `Endpoint_Condition_Expected`, e.g. `GetRequests_RegularUser_ReturnsOnlyOwnedOrAssigned`.
   Arrange / Act / Assert, one behaviour per test.
5. Don't duplicate unit tests – integration tests check the pieces work together
   and the HTTP contract, not every branch of the service.

## Run and report

`cd server && dotnet test` – report the real output. If a test fails because of a bug in the
code (not the test), report the bug and ask before changing production code.
Do NOT commit.
