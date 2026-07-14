# Drupal with Docker - Final Project

**Student:** נועה עמר  
**Student ID:** 213959406  
**Course:** Development Tools, semester B 2026

## My project

In this project I built a small Docker environment for Drupal and PostgreSQL.
My goal was to make every important operation repeatable: starting the system,
creating a backup, restoring it, and cleaning the environment.

I wrote the scripts in this repository from scratch after studying the course
requirements and reviewing a reference implementation. This repository is an
independent project and does not contain another repository's Git history or
Drupal backup.

## Project structure

| File | Purpose |
| --- | --- |
| `setup.sh` | Creates the Docker network, PostgreSQL container and Drupal container |
| `backup.sh` | Saves the database and Drupal `sites` directory |
| `restore.sh` | Restores both backup parts into running containers |
| `cleanup.sh` | Removes only this project's containers, volumes and network |
| `backups/` | Location where my own generated backups are stored |

## Main configuration

| Setting | Value |
| --- | --- |
| Docker network | `noa-drupal-net` |
| PostgreSQL container | `noa-postgres` |
| Drupal container | `noa-drupal` |
| Database | `drupal` |
| Database user | `root` |
| Database password | `my-secret-pw` |
| Drupal address | `http://localhost:8080` |

The password is intentionally simple because this is a local course exercise.
It must not be used for a real public system.

## How I run the project

Clone the repository and enter its directory:

```bash
git clone https://github.com/noaamar010-cell/noa-drupal-final-project.git
cd noa-drupal-final-project
```

Make the scripts executable:

```bash
chmod +x setup.sh backup.sh restore.sh cleanup.sh
```

Start the environment:

```bash
./setup.sh
```

I then open `http://localhost:8080` and complete the Drupal installation. In
the database screen I use the values printed by `setup.sh`. The database host
is the container name `noa-postgres`, not `localhost`.

## Backup and restore

After I finish configuring Drupal and adding my own content, I create a backup:

```bash
./backup.sh
```

This creates:

- `backups/drupal.sql`
- `backups/sites.tar.gz`

The generated files are ignored by Git until I decide that my own final course
backup is ready to submit.

To test the restoration process, I run a clean setup and then:

```bash
./restore.sh
```

Finally, I remove the environment with:

```bash
./cleanup.sh
```

The cleanup script removes only resources whose names belong to this project.
It keeps shared Docker images so it does not damage unrelated environments.

## What I learned

This project helped me understand how containers communicate through a Docker
network, why persistent volumes are needed, and why a backup must include both
the database and Drupal's site files. The most important part for me was making
the complete process reproducible instead of depending on manual steps.
