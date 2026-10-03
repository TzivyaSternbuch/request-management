---
description: Design a feature before coding – layers, files, API contract, tests. No code is written.
argument-hint: <feature or requirement to design>
---

Design the following feature for this project. Do NOT write or edit any code files.

Feature: $ARGUMENTS

## Steps

1. Read `CLAUDE.md` and the requirements doc (`docs/requirements*` if it exists) for the rules that apply.
2. Read the existing code this feature touches in `server/` and `front/`. Reuse what exists –
   name the classes/functions you plan to extend instead of creating new ones.
3. If anything in the requirement is unclear, list the questions first, with the assumption
   you would make for each.

## Output (in chat, in this order)

1. **Summary** – what the feature does, in 2–3 sentences.
2. **API contract** – endpoint(s), method, query/body parameters, response shape (JSON example),
   status codes and error cases.
3. **Server changes by layer** – Domain / Application / Infrastructure / Api: for each, the
   files to add or change and what goes in them (signatures only, no bodies).
   Check the dependency direction from `CLAUDE.md`.
4. **Data access** – how the query runs in the database (filtering, sorting, paging, indexes).
5. **Front changes** – components, hook, API module function, types; loading/error/empty states.
6. **Tests** – list of test names (`Subject_Condition_Expected`) covering every business rule
   and edge case.
7. **Alternatives** – 1–2 other approaches, their trade-offs, and your recommendation with why.
   (These feed the README section "Technical decision with alternatives".)
8. **Open questions / assumptions** (these feed the README section "Assumptions").

Keep it short and concrete. End by asking whether to save the design to
`docs/design/<feature-name>.md`.
