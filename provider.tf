terraform {
  required_providers {
    google ={
        source = "hashicorp/google"
        version ="4.51.0"
    }
  }
}


provider "google"{
    credentials = file("credential.json")
    region = var.region
    project = var.project
    zone = "us-east1-b"
}