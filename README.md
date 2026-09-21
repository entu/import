# Entu maintenance scripts

Standalone Node scripts that work directly on MongoDB and S3, outside the Entu API and its rights checks.

> **Every script runs against all account databases** on the configured MongoDB (all except `admin`, `analytics`, `config`, `entu` and `local`). To try one on a single database first, uncomment the `dbList = [...]` override near the top of the script.

## Setup

```bash
npm install
```

Copy `.env.example` to `.env` and fill in what the script you run needs:

| Variable | Used by |
|---|---|
| `MONGODB` | every script except `export-database` |
| `ENTU_API_URL` | every script that re-aggregates, and `export-database` |
| `ENTU_API_TOKEN` | `export-database` |
| `DO_SPACES_*` | `check-files`, `export-database` |
| `AWS_S3_*` | `check-files` |
| `DB_OWNERS` | `set-database-owner` — comma-separated user ids |

Entities are never aggregated here — scripts that change properties call the API's aggregate route (`ENTU_API_URL`) for every entity they touch.

## Scripts

Run with `npm run <name>`. The name's first word tells what kind of script it is.

### `check-*` — read-only reports

| Script | What it does |
|---|---|
| `check-aggregation` | Shows per database how much of the aggregation queue is left. |
| `check-files` | Compares file sizes in the database against both S3 buckets and writes `./export/<db>/files.csv`. |
| `check-formulas` | Prints every formula as `database;entity;formula`. |
| `check-string-type` | Finds property types whose `string` value is not a real string. |

### `sync-*` — make a database match a source, overwriting what differs

| Script | What it does |
|---|---|
| `sync-entity-type` | Copies one entity type definition (`ENTITY_TYPE` in the script) and its property definitions from the `template` database. Plain values are overwritten; with `OVERWRITE_CHILDREN`, property definitions missing in the template are deleted. `add_from` → menu and `plugin` → plugin references are added (never removed), creating the menu or plugin when missing. |
| `sync-plugins` | Copies plugins from the `TEMPLATE_DB` database, matched by url, with their entity type links and `add_from` menus. |
| `sync-indexes` | Creates the indexes listed in the script and **drops every other index**. |

### `set-*` — add missing system properties

| Script | What it does |
|---|---|
| `set-database-owner` | Sets the database entity's users to `DB_OWNERS` — **users not listed are removed** — and adds the database entity as `_owner` to every entity. |
| `set-database-parent` | Adds the database entity as `_parent` to every entity type, menu and plugin that lacks it. |

### `clean-*` — soft-delete junk

| Script | What it does |
|---|---|
| `clean-expired-invites` | Removes user invites older than 24 hours. |
| `clean-properties` | Removes exact duplicate properties (keeps the newest) and properties without a value. |

### Other

| Script | What it does |
|---|---|
| `aggregate` | Re-aggregates entities through the API; the entity filter is set in the script. |
| `export-database` | Exports one database (`database` in the script) to CSV and YAML under `./export/<db>/` and downloads its files. |
| `lint` | ESLint with `--fix`. |

Deletes are soft: the property gets a `deleted` stamp and stays in the `property` collection.
