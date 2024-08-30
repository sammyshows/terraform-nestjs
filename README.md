# Terraform Infrastructure for NestJS Application

This repository contains Terraform configurations to provision a Docker-based infrastructure for a NestJS application. The infrastructure includes a PostgreSQL database container, a NestJS application container, and a Docker-managed volume for persistent storage.

## Infrastructure Overview

The Terraform configuration (`main.tf`) creates the following resources:

- **Docker Volume**:
  - `nestjs_data`: A Docker-managed volume for persistent data storage. This volume is mounted at `/app/data` inside the NestJS container.

- **Docker Containers**:
  - **PostgreSQL Database Container** (`postgres_db`):
    - Runs a PostgreSQL database using the `postgres:13` Docker image.
    - Configured with:
      - Username: `user`
      - Password: `password`
      - Database Name: `nestjs_db`
    - Accessible on port `5432` of the host machine.
  
  - **NestJS Application Container** (`nestjs`):
    - Runs a NestJS application using the `node:18-alpine` Docker image.
    - Application code is mounted from the host machine at `/Users/sammccarthy/code/nestjs` to `/app` inside the container.
    - Persistent data storage is provided by the `nestjs_data` Docker volume, mounted at `/app/data`.
    - Accessible on port `3000` of the host machine.
    - The application connects to the PostgreSQL database using the connection string: `postgres://user:password@db:5432/nestjs_db`.

## Prerequisites

Before you begin, ensure you have the following installed on your machine:

- [Docker](https://www.docker.com/get-started)
- [Terraform](https://www.terraform.io/downloads)
- Access to the `unix:///var/run/docker.sock` (or equivalent for your system).