# Contributing

## Reporting Issues

- Use GitHub Issues on this private repo
- For agy-cli bugs (not workshop docs): report to the agy-cli team directly

## Updating Docs

1. Edit files in `docs/` or `exercises/`
2. Run `make serve` to preview locally
3. Verify `make test-structure` passes
4. Submit a PR

## Updating for New agy-cli Versions

1. Run through all exercises against the new version
2. Note any command changes or broken flows
3. Update docs and add an entry to `CHANGELOG.md`
4. Flag any exercises that required workarounds in the facilitator guide

## Sections with Known Placeholders

These sections intentionally have placeholder content awaiting post-Google I/O clarity:

| File | Section | Placeholder |
|---|---|---|
| `docs/setup.md` | Step 2: Authentication | Auth flow TBD |
| `docs/plugin-ecosystem.md` | Section 2.3 | Marketplace URL TBD |
