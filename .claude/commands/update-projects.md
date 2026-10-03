---
description: Pull the latest server/front submodule commits and update the root repo's pointers. Never commits without approval.
---

Update the `server/` and `front/` submodules to the latest commit of their remote branch.

## Steps

1. For each submodule (`server`, `front`):
   - `git -C <sub> status --porcelain` – if there are uncommitted changes, STOP for that
     submodule and report them. Never discard or stash them.
   - `git -C <sub> fetch origin`
   - Show what is new: `git -C <sub> log --oneline HEAD..origin/main`
     (use the submodule's default branch if it isn't `main`).
   - If nothing is new, say "up to date" and move on.
2. Ask for approval, then update: `git submodule update --remote --merge server front`.
   If the merge conflicts, stop and show the conflicting files.
3. Check the updated code still works and report the real output:
   - `cd server && dotnet build && dotnet test`
   - `cd front && npm install && npm run lint && npm run build`
     (`npm install` only if `package.json` / `package-lock.json` changed)
4. Show `git status` and `git diff --submodule` in the root repo.

## Output

Per submodule: old commit → new commit, the list of new commits, build/test result.
Then propose a root commit message like `Bump server and front submodules`
and wait for approval. Do NOT commit or push without a yes.
