# CLAUDE.md

The repository guide is shared with other coding agents and lives in `AGENTS.md`:

@AGENTS.md

## Claude Code specifics

- A `PostToolUse` hook (`.claude/settings.json`) runs `bin/check-content` and `bin/run-tests --hook` after every Edit,
  Write, MultiEdit and Bash call. If it reports errors, fix them before continuing.
- Check visual changes in the Browser pane with `bundle exec jekyll serve` (port 4000), including a 375px-wide viewport.
