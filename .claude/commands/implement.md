---
description: Implement an approved design step by step, layer by layer, with tests – then verify and self-review. Never commits.
argument-hint: <feature name or path to docs/design/*.md>
---

Implement this feature: $ARGUMENTS

## Before writing code

1. Find the approved design: `docs/design/<feature>.md`, or a `/design` output earlier in this
   conversation. If there is none, stop and suggest running `/design` first.
2. Read `CLAUDE.md` and the existing code the design touches. Reuse existing classes,
   functions and types – do not create a second version of something that exists.
3. Show the ordered list of files you will add/change (per repo: `server/`, `front/`, root)
   and wait for approval.

## Implementation order

Work in small steps, one layer at a time, and briefly report after each:

1. **Domain** – entities/enums (only if the design needs them).
2. **Application** – DTOs, interfaces, service logic.
3. **Unit tests** (`server/tests/Requests.Tests`, xUnit):
   - One test class per service under test, mirroring its name (`RequestServiceTests`).
   - Hand-written fakes for interfaces (like `FakeRequestRepository`); no mocking library.
   - Cover every business rule from the design, plus edge cases: empty results, null/optional
     values, boundaries (first/last page, date ranges), and invalid input.
   - Names: `Subject_Condition_Expected`; Arrange / Act / Assert; one behaviour per test.
   - Assert on the actual values (which items, which fields), not only on counts.
   - Run `cd server && dotnet test`; fix until green. Never weaken a test to make it pass.
4. **Infrastructure** – repository / EF query (filtering in the database), DI registration.
5. **Api** – thin controller action.
6. **Front** – types → `src/api/` function → hook → components (loading / error / empty / data).
7. **Front unit tests** (Vitest + React Testing Library):
   - First time only: if `front/package.json` has no `test` script, propose the setup, explain
     each package, and wait for approval: `vitest`, `jsdom`, `@testing-library/react`,
     `@testing-library/jest-dom`, `@testing-library/user-event`; a `test` block in
     `vite.config.ts` (`environment: 'jsdom'`, a setup file importing `jest-dom`);
     script `"test": "vitest run"`.
   - Test files next to the code: `RequestsTable.test.tsx`, `useRequests.test.ts`.
   - Mock the `src/api/` module with `vi.mock`, never `fetch` or the network.
   - Hooks: test with `renderHook` – loading → data, loading → error.
   - Components: test what the user sees, via `screen.getByRole` / `getByText` and
     `userEvent` – loading, error, empty and data states, and each filter/search interaction.
   - Pure helpers (formatting, building query strings): plain input → output tests.
   - Names: `it('shows an empty message when there are no requests')`.
   - Run `cd front && npm test`; fix until green.

Rules while coding:
- Follow every rule in `CLAUDE.md`; match the style of surrounding code.
- Only what the design asks for – no extra options, abstractions or "nice to haves".
- If the design turns out wrong or unclear, stop and ask instead of improvising.
- No commented-out code, no debug output, no TODOs left behind.

## After coding

1. Verify, and report the real output:
   - `cd server && dotnet build && dotnet test`
   - `cd front && npm run lint && npm test && npm run build`
2. Simplify: if the `code-simplifier` plugin is available, run the
   `code-simplifier:code-simplifier` agent on the files changed in this feature only, following
   `CLAUDE.md`. Otherwise do the same pass yourself (clearer names, less nesting, no duplication).
   Re-run the tests after it.
3. Self-review the change with the checklist in `.claude/commands/review.md` and fix
   any High items.
4. Summarize:
   - files changed per repo, with one line each on what and why,
   - test results,
   - anything left out or assumed (for the README "Assumptions" / "Not done" sections).

Do NOT commit or push. Finish by suggesting `/integration-test` for any new or changed
endpoint, then `/review`, then a commit once the user approves.
