#!/bin/bash

# Update and deploy container
docker compose pull
docker compose down
docker compose up -d