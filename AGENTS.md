# MClassrooms

Ruby on Rails 8.1 application for University of Michigan classroom management/directory.

## Cursor Cloud specific instructions

### Runtime versions

Managed via `mise` (reads `.tool-versions`): Ruby 3.4.7, Node.js 20.19.6. After VM startup, `mise install` is run automatically via the update script.

### Services

| Service | How to start | Notes |
|---|---|---|
| PostgreSQL | `pg_ctlcluster 16 main start` | Must be running before Rails. Three databases per env (primary, queue, cable). |
| Rails + Tailwind + Jobs | `bin/dev` | Uses foreman; runs Puma on port 3000, Tailwind CSS watcher, and Solid Queue worker. |

### Key commands

- **Lint:** `bundle exec standardrb` (Ruby Standard Style). Exit code 1 = style warnings (13 pre-existing); use `--fix` to auto-fix.
- **Security:** `bundle exec brakeman` (1 pre-existing weak warning).
- **Tests:** `bundle exec rspec` (181 specs).
- **DB prepare:** `bin/rails db:prepare` (creates all 3 databases + loads `db/structure.sql`).
- **DB seed:** `bin/rails db:seed` (creates Announcement records).
- **Dev server:** `bin/dev` (foreman: web + css + jobs).

### Test login (non-production)

Set env vars to enable a bypass login in development:

```
ENABLE_TEST_LOGIN=true TEST_LOGIN_TOKEN=testtoken123 TEST_LOGIN_EMAIL=test@umich.edu bin/dev
```

Then visit `http://localhost:3000/test_login?token=testtoken123` to log in. Defaults to admin role.

### Gotchas

- The app uses `config.active_record.schema_format = :sql`, so migrations produce `db/structure.sql` (not `schema.rb`). When running `db:prepare` on a fresh database it loads this SQL file automatically.
- `bundle exec standardrb` currently has 13 pre-existing style offenses. Do not attempt to fix them unless explicitly asked.
- `brakeman` exits with code 3 (warnings present) due to 1 pre-existing HTTP Verb Confusion warning. This is expected.
- Tailwind CSS watcher logs `sh: 1: watchman: not found` — this is harmless; it falls back to polling.
- No Redis required. Solid Queue and Solid Cable both use PostgreSQL.
