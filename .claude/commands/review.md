---
description: Clean-code review of current changes – duplicates, layer rules, naming, dead code, missing tests. Report only.
argument-hint: "[file, folder or git range – default: all uncommitted changes]"
---

Review code changes for clean code against the rules in `CLAUDE.md`.
Report only. Do NOT edit any files, and do not offer, ask about, or apply fixes.

Scope: $ARGUMENTS
If no scope is given, review all uncommitted changes in the root repo AND inside the
`server/` and `front/` submodules (`git -C server diff HEAD`, `git -C front diff HEAD`,
plus untracked files from `git status` in each).

## What to check

1. **Duplication** – for every new method, type, constant or component, search the codebase
   for something that already does the same or almost the same. Report it with both locations.
   Also flag copy-pasted blocks inside the change itself.
2. **Layer rules (server)** – Domain depends on nothing; no EF Core / ASP.NET in Application;
   controllers are thin (no business logic, no `DbContext`); entities never returned from the API.
3. **Responsibility & size** – methods/components doing more than one thing, deep nesting,
   long parameter lists.
4. **Naming** – unclear or abbreviated names, names that don't match behaviour.
5. **Leftovers** – dead code, commented-out code, unused usings/imports, debug logs, TODOs.
6. **Magic values** – literal strings/numbers that should be constants or enums.
7. **Conventions** – `Async` suffix + `CancellationToken`, no unneeded `sealed`, `_camelCase` fields,
   no `any`, HTTP only via the `src/api/` module, loading/error/empty states handled.
8. **Data access** – filtering in memory instead of in the database; N+1 queries.
9. **Tests** – business rules or edge cases in the change that have no test
   (server: xUnit; front: Vitest – hooks, components' loading/error/empty states, interactions).
10. **Over-engineering** – abstractions or options not needed by the current requirement.

## Specialist agents (if the plugins are installed)

If the `pr-review-toolkit` plugin is available, run these agents in parallel on the same scope,
telling each to follow `CLAUDE.md` and to report only (no edits):
- `pr-review-toolkit:code-reviewer` – project rules and quality
- `pr-review-toolkit:code-simplifier` – complexity and duplication (suggestions only)
- `pr-review-toolkit:pr-test-analyzer` – missing tests
- `pr-review-toolkit:silent-failure-hunter` – swallowed errors, bad error handling
- `pr-review-toolkit:type-design-analyzer` – only if new types/DTOs were added

Merge their findings with your own checklist results, drop duplicates and anything that
contradicts `CLAUDE.md`. If the plugin is not installed, do the checklist yourself.

## Output

A table sorted by severity (High → Medium → Low):

| Severity | File:line | Problem | Suggested fix |

Then one line: overall verdict (ready to commit / fix High items first).
Do not list praise or things that are fine. If nothing is found, say so in one line.
End after the verdict line. Do not ask which items to fix – fixing is a separate request.
