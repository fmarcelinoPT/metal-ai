# AI Server with Ollama and OpenWebUI

## Overview

This repository contains a comprehensive AI server built using Ollama for backend processing and OpenWebUI for frontend interaction. The project aims to leverage state-of-the-art machine learning models to provide advanced AI capabilities, including natural language understanding and generation, image classification, and more.

## Project Goal

The primary goal of this project is to create a versatile and scalable AI server that can interact with users through an intuitive web interface. By integrating various pre-trained models, including `LLama3:8b`, `Mistral:7b`, `Gemma2:9b`, `DeepSeek-Coder-V2:16b`, `CodeGemma:7` and `Granite3.1-Dense:8b`, the server aims to offer a wide range of AI services tailored for diverse applications including research, education, and business use cases.

## Models Included

- **LLama3:8b** - A powerful language model capable of handling complex natural language tasks.
- **Mistral:7b** - Known for its versatility in various NLP tasks, it enhances the server's capability to understand and generate human-like text.
- **Gemma2:9b** - Specialized in dense retrieval systems, ideal for enhancing the search efficiency within large datasets.
- **DeepSeek-Coder-V2:16b** - Focused on code generation and understanding, this model is crucial for developers seeking AI support with high accuracy and speed.
- **CodeGemma:7** - A lightweight yet powerful language model designed to handle Ruby and similar programming languages efficiently.
- **Granite3.1-Dense:8b** - Optimized for dense vector computations, it improves the performance of similarity searches and data analytics within the server's scope.

## Technologies Used

- **Proxmox**: Proxmox VE is an open-source server virtualization platform to manage two virtualization technologies: Kernel-based Virtual Machine (KVM) for virtual machines and LXC for containers - with a single web-based interface.
- **Docker**: For containerizing and deploying the application environment efficiently in various cloud providers.
- **GitLab CI/CD**: Ensures seamless integration, testing, and deployment pipelines for the project through DevOps methodology.
- **Ollama**: A backend framework that handles model inference requests from OpenWebUI.
- **OpenWebUI**: An interactive web interface built on React which allows users to interact with AI models seamlessly.

## Getting Started

To run this server locally or deploy it on your preferred cloud service, follow these steps:

### Prerequisites

1. Ensure GPU passthrough on Proxmox:
   - [Configure Proxmox GPU Passthrough (Step-by-Step Tutorial)](https://www.youtube.com/watch?v=IE0ew8WwxLM)
   - [GPU Passthrough to a Virtual Machine on Proxmox Server (Ubuntu VM)](https://medium.com/@cactusmccoy/gpu-access-from-a-virtual-machine-on-proxmox-server-ubuntu-vm-903bb9783cb3)
1. Create VM (I used Ubuntu flavour)
1. Install graphics drivers
1. Install [NVidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/)
   - [Linux post-installation steps for Docker Engine](https://docs.docker.com/engine/install/linux-postinstall/)
1. :bulb: Create new HDD on the VM (to hold the models; useful to ease the backup process) and map it to `/data`

### Deploy containers

1. Clone the repository to your local machine.
1. Install Portainer: `sh portainer/execute-update.sh`
1. Install OpenWebUI: `sh open-webui/execute-update.sh`
1. Install Ollama: `sh ollama/execute-update.sh`
1. Install models in Ollama:

   ```bash
   docker exec -it ollama bash

   ollama pull llama3:8b
   ollama pull mistral:7b
   ollama pull gemma2:9b
   ollama pull deepseek-coder-v2:16b
   ollama pull codegemma:7b
   ollama pull granite3.1-dense:8b
   ```

1. Navigate to the Open WebUI interface in your browser at `http://[server]:8080`
   - [Open WebUI Getting Started](https://docs.openwebui.com/getting-started/quick-start)

## Future Enhancements

Planned enhancements include:

- Integration with more AI models and functionalities.
- Performance optimization across all services.
- Expanding the web interface with additional interactive features.
- Implementing DevSecOps practices to secure and automate deployment pipelines.
