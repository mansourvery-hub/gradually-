# Development Workflow

Development rules for humans and AI coding agents working on 渐入.

`AGENTS.md` contains the rules that must be remembered for every task. This file contains the practical Git, worktree, testing, and repository workflow.

## 1. Repository model

The repository uses a simple model:

```text
main
  ↑
feature / fix branches
  ↑
optional isolated worktrees for parallel work
```

`main` represents the stable integrated project state.

Do not introduce GitFlow, `develop`, staging branches, release branches, or other branch systems unless the project explicitly requires them later.

## 2. Branches

### `main`

- Stable integrated branch.
- Agents must not work directly on `main` unless explicitly instructed.
- Do not force-push `main`.

### Task branches

Use one branch for one coherent task.

Examples:

```text
feature/content-selector
feature/reader
feature/beginner-review
fix/tokenization-offsets
refactor/learner-state
test/selector-regressions
```

Branch names should describe the work, not the agent.

## 3. Worktrees

When multiple agents or independent tasks are active simultaneously, prefer one Git worktree per task.

Example:

```bash
git worktree add .worktrees/content-selector -b feature/content-selector
git worktree add .worktrees/beginner-review -b feature/beginner-review
```

This prevents agents from modifying the same working tree simultaneously.

Recommended structure:

```text
project/
├── .git/
├── .worktrees/
│   ├── content-selector/
│   └── beginner-review/
├── lib/
├── test/
└── content/
```

A worktree is disposable; the branch contains the actual work.

Do not create worktrees unnecessarily for a single sequential task.

## 4. Before changing code

Before modifying anything:

```bash
git status
git branch --show-current
```

When relevant, inspect recent history:

```bash
git log --oneline -10
```

Never assume the working tree is clean.

Existing uncommitted changes may belong to the user or another task. Do not overwrite, revert, or "clean up" unrelated work.

## 5. Git safety

Never use destructive commands against existing work unless explicitly instructed.

Avoid:

```bash
git reset --hard
git clean -fd
git restore .
git checkout -- .
```

Do not delete, revert, or rewrite unrelated changes merely to make tests pass.

If unrelated changes prevent a task from being completed safely, preserve them and work around them.

## 6. Commits

One logical change should normally result in one coherent commit, or a small number of coherent commits.

Good examples:

```text
feat: add learner vocabulary repository
feat: add V1 content selector
fix: preserve story reading position
test: add selector progression fixtures
refactor: isolate scheduler adapter
```

Do not mix unrelated refactors into feature work.

A commit should be reasonably easy to review and revert.

Agents should normally commit completed work on their task branch.

Agents must not push to GitHub unless explicitly instructed.

## 7. Pull requests / integration

Before merging a branch into `main`:

```bash
flutter analyze
flutter test
git diff main...HEAD
```

Review the complete diff for:

- accidental unrelated changes
- debug code
- temporary files
- changed product behavior
- generated files
- secrets
- learner data
- content changes that were not intentional

Merge only a coherent, tested change.

## 8. Testing

At minimum, run the tests relevant to the changed subsystem.

For changes affecting shared learning infrastructure, prefer the broader suite:

```bash
flutter analyze
flutter test
```

Changes to any of these are learning-system changes and require appropriate regression testing:

- learner-state logic
- known vocabulary rules
- tokenization
- acquisition/promotion
- SRS behavior
- content-selection logic
- curated content metadata
- curriculum ordering

See `ARCHITECTURE.md` §7 for the product-critical test categories.

## 9. Content is code-equivalent

Curated Chinese content is part of the learning algorithm.

A content change can alter:

```text
tokenization
→ vocabulary knowledge
→ acquisition
→ i+1 selection
→ curriculum progression
```

Therefore content changes should be reviewed and tested with the same seriousness as code changes.

Do not casually edit vocabulary metadata, tokenization data, prerequisites, or curriculum ordering.

When a task involves critical decisions that require human intervention—such as selecting which stories, books, or texts to include in the curriculum—agents are free and expected to ask the user, who will respond.

## 10. Learner data and database safety

Never commit a user's local learner database or private learner state.

Do not reset or delete persisted learner data simply to make development easier.

Once the persistence technology is chosen, schema changes must preserve existing learner state through an explicit migration strategy.

Important learner data includes:

- known vocabulary
- known Hanzi
- SRS state
- acquisition candidates
- exposure records
- completion state
- reading position

## 11. Generated and local files

Do not commit:

- build output
- IDE/editor state
- temporary files
- local databases
- machine-specific configuration
- generated caches
- credentials or secrets

Generated files that are explicitly part of the product or build process may be committed only when the repository deliberately treats them as source artifacts.

## 12. Secrets

Never commit:

- API keys
- passwords
- access tokens
- signing credentials
- private certificates
- service-account credentials
- `.env` files containing secrets

Do not place fake credentials that resemble real secrets into committed configuration.

## 13. Dependency changes

Do not add a package simply because it is convenient.

Before adding a dependency, verify that it solves a real project requirement and does not unnecessarily complicate:

- offline operation
- Web compatibility
- iOS/Android builds
- local persistence
- tokenizer portability
- long-term maintainability

Prefer keeping dependencies replaceable when they sit behind an important architectural boundary.

## 14. Refactoring rule

Do not perform broad architectural refactors while implementing an unrelated feature.

Refactor when:

1. it is necessary for the current task, or
2. the refactor is itself the explicit task.

This is especially important when multiple agents are working in parallel.

## 15. Agent completion checklist

Before declaring a task complete:

```text
[ ] Correct branch / worktree
[ ] No unrelated changes overwritten
[ ] Product behavior still follows AGENTS.md
[ ] Relevant tests run
[ ] flutter analyze run when appropriate
[ ] git diff reviewed
[ ] No secrets or local learner data included
[ ] Content changes checked for curriculum impact
[ ] Commit is coherent
[ ] Push only if explicitly requested
```

## 16. Worktree cleanup

After a task is integrated and the worktree is no longer needed:

```bash
git worktree remove .worktrees/<name>
```

Do not remove a worktree that contains uncommitted work without explicitly confirming that the work is no longer needed.

## 17. Guiding principle

Git and development tooling exist to make agentic development safer and more reversible.

Do not create process for its own sake.

Prefer:

```text
isolated work
→ targeted changes
→ tests
→ reviewable commit
→ controlled integration
```

over elaborate branching or release machinery.