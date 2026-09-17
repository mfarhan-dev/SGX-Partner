# Database schema history

`migrations/` is the **entire** schema history for the `ghojtefwuzubqguqcbwc`
project (currently used as Dev), from the very first table through today --
108 files, pulled directly from Supabase's own
`supabase_migrations.schema_migrations` table on 2026-09-17. Every RPC,
trigger, table, index, and RLS policy in the live database exists here as
plain SQL, in order.

This did not exist in git before today. Every schema change made through the
Supabase dashboard, the SQL editor, or an MCP tool call was real and applied
immediately, but was **only ever recorded inside Supabase itself** -- nothing
about it lived in this repository. If this Supabase project or account were
ever lost, none of the last month of schema work could have been
reconstructed from source control.

## Why this matters now specifically

The plan going forward is Dev and Production as two **separate** Supabase
projects (Supabase's own recommended pattern -- see
https://supabase.com/docs/guides/deployment). This folder is what makes that
possible without hand-recreating 30+ functions and triggers by clicking
through a dashboard: point the CLI at a brand-new, empty Production project
and replay every migration file here, in order, to get an identical schema.

## One-time setup (not done in this session -- needs your own login)

The CLI needs your own Supabase login or a personal access token; neither
was available to generate this file. To actually use it:

```bash
npm install -g supabase   # or `npx supabase <command>` each time, no install
supabase login
supabase link --project-ref ghojtefwuzubqguqcbwc   # links to Dev
```

## Going forward: every new schema change becomes a migration

Whenever a schema change is made from here on (whether via the dashboard,
the SQL editor, or an AI tool), pull it into a real file before considering
it done:

```bash
supabase db pull    # writes any change made outside the CLI as a new
                     # timestamped file in supabase/migrations/
git add supabase/migrations && git commit -m "..."
```

## When Production is created (separate task, not yet done)

```bash
supabase link --project-ref <new-production-project-ref>
supabase db push     # replays every migration in supabase/migrations/
                      # against the new, empty Production project
```

`db push` only applies migrations that project hasn't seen yet, so from that
point on the same `supabase/migrations/` folder is the single source of
truth pushed to both Dev and Production -- never edit one project's schema
by hand and not the other.
