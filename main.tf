# main.tf
terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 2.15.0"
    }
  }
}

provider "docker" {
  host = "unix:///var/run/docker.sock"
}

resource "docker_image" "nestjs" {
  name         = "node:18-alpine"
  keep_locally = false
}

resource "docker_container" "nestjs" {
  name  = "nestjs"
  image = docker_image.nestjs

  ports {
    internal = 3000
    external = 3000
  }

  volumes {
    host_path      = "/Users/sammccarthy/code/nestjs"
    container_path = "/app"
  }

  working_dir = "/app"

  command = [
    "npm", "run", "start:dev"
  ]
}

