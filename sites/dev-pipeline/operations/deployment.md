# Deployment & Operations

How the Dev Pipeline project gets from local development to production on Arch.

---

## Local Setup (Mac)

### Clone the repo

```bash
git clone git@github.com:Ruben0372/dev-pipeline.git ~/projects/dev-pipeline
cd ~/projects/dev-pipeline
```

### How site content is generated

Agents (Claude Code sessions) auto-write to `sites/{project}/` based on the conventions defined in each project's `CLAUDE.md`. Each pipeline stage agent reads the project context and outputs its deliverables into the appropriate site directory.

### Pushing changes

Push happens manually or via an agent after commits:

```bash
git add -A
git commit -m "feat: update site content for <project>"
git push origin main
```

---

## Arch Setup (Production)

Host: **RhudeRuben** (100.103.184.98, Arch Linux)

### Initial clone

The Tower API clones the repo into the Dashboard data volume on first onboard:

```
/mnt/WaRlOrD/dashboard-data/dev-pipeline/
```

### Automatic sync

A scheduled task runs `git pull` every 2 minutes to keep production in sync with the remote. No manual intervention needed after the initial clone.

### How the API reads sites

`SiteRecordStore` reads from `/data/dev-pipeline/sites/` inside the container. This path is a Docker volume mount pointing to the host path above:

```
Host:      /mnt/WaRlOrD/dashboard-data/dev-pipeline/sites/
Container: /data/dev-pipeline/sites/
```

### Git safe.directory

The Dockerfile configures `git safe.directory` for `/data/dev-pipeline` so that `git pull` works inside the container without ownership errors.

---

## Scaffolding a New Site

From your local machine:

```bash
cd ~/projects/dev-pipeline
bash scripts/scaffold.sh <slug> "<Project Name>"
```

This does three things:

1. Creates the folder structure under `sites/<slug>/` from `templates/new-site/`
2. Commits the new site
3. Pushes to origin

The production Arch server picks it up on the next 2-minute pull cycle.

---

## Onboarding in The Tower

After scaffolding, register the project with the Tower API:

```bash
curl -X POST http://100.103.184.98:7070/api/pipeline/<notion-project-id>/onboard \
  -H "Content-Type: application/json" \
  -d '{"project_name":"<name>","stage":"ideate","site_slug":"<slug>"}'
```

Replace:
- `<notion-project-id>` -- the Notion page ID for the project
- `<name>` -- display name (e.g. "Vitalis")
- `<slug>` -- the site directory slug (e.g. "vitalis")

---

## Troubleshooting

### Site records not showing in the API

Check that the files are visible inside the container:

```bash
docker exec dashboard-deploy-api-1 ls /data/dev-pipeline/sites/
```

If the directory is empty or missing, verify the Docker volume mount in `docker-compose.yml`.

### Git pull fails on Arch

1. **safe.directory** -- Confirm it is set in the Dockerfile or in the container's global git config:
   ```bash
   docker exec dashboard-deploy-api-1 git config --global --get-all safe.directory
   ```
   Expected output should include `/data/dev-pipeline`.

2. **SSH access** -- The container needs SSH credentials (or a deploy key) to pull from the private repo. Check that the key is mounted and has read access.

3. **Manual pull test** -- Run a pull inside the container to see the actual error:
   ```bash
   docker exec dashboard-deploy-api-1 git -C /data/dev-pipeline pull
   ```

### Scaffold script fails

Ensure the templates directory exists:

```bash
ls ~/projects/dev-pipeline/templates/new-site/
```

If it is missing, the scaffold script has nothing to copy. Restore it from git history or recreate the template structure.
