# main.tf

# Terraform block to specify required providers
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

# Docker provider configuration
provider "docker" {
  host = "unix:///Users/sammccarthy/.docker/run/docker.sock"
}

# Terraform variables
variable "image_name" {
  type    = string
  default = "node:18-alpine"
}

variable "host_port" {
  type    = number
  default = 3000
}

# Define a Docker volume for data persistence
resource "docker_volume" "nestjs_data" {
  name = "nestjs_data"
}

# Define the Docker image for the NestJS application
resource "docker_image" "nestjs" {
  name         = var.image_name
  keep_locally = false
}

# Define the Docker image for PostgreSQL
resource "docker_image" "postgres" {
  name         = "postgres:13"
  keep_locally = false
}

# Define the Docker container for the PostgreSQL database
resource "docker_container" "db" {
  name  = "postgres_db"
  image = docker_image.postgres.name

  env = [
    "POSTGRES_USER=user",
    "POSTGRES_PASSWORD=password",
    "POSTGRES_DB=nestjs_db"
  ]

  ports {
    internal = 5432
    external = 5432
  }

  volumes {
    host_path      = "/var/lib/postgresql/data"
    container_path = "/var/lib/postgresql/data"
  }
}

# Define the Docker container for the NestJS application
resource "docker_container" "nestjs" {
  name  = "nestjs"
  image = docker_image.nestjs.name

  ports {
    internal = 3000
    external = var.host_port
  }

  volumes {
    # Mount the NestJS application code
    host_path      = "/Users/sammccarthy/code/nestjs"
    container_path = "/app"
  }

  volumes {
    # Attach the Docker-managed volume for persistent data
    volume_name    = docker_volume.nestjs_data.name
    container_path = "/app/data"
  }

  working_dir = "/app"

  command = [
    "npm", "run", "start:dev"
  ]

  env = [
    "NODE_ENV=development",
    "DATABASE_URL=postgres://user:password@db:5432/nestjs_db"
  ]

  depends_on = [
    docker_container.db
  ]
}

# Output the application URL
output "app_url" {
  value = "http://localhost:${var.host_port}"
}

# Output the database connection string
output "db_connection" {
  value = "postgres://user:password@localhost:5432/nestjs_db"
}
