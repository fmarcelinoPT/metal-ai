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
   1. `sudo apt install ubuntu-drivers-common -y`
   1. <https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/index.html>
   1. `sudo ubuntu-drivers list --gpgpu`
   1. `sudo ubuntu-drivers install --gpgpu nvidia:570-server`
   1. `sudo apt install nvidia-utils-570-server`
   1. `sudo apt install nvidia-fabricmanager-570 libnvidia-nscq-570`
1. Install [CUDA Drivers](https://docs.nvidia.com/datacenter/tesla/driver-installation-guide/index.html#ubuntu-installation)
   1. `wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb`
   1. `sudo dpkg -i cuda-keyring_1.1-1_all.deb`
   1. `sudo apt update`
   1. `sudo apt install cuda-drivers -y`
   1. `sudo reboot -h 0`
1. Test GPU connection: `watch -n0.1 nvidia-smi` | `watch -n1 nvidia-smi`
1. Install [NVidia Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
   1. On error `Failed to initialize NVML: Unknown Error`
      1. `sudo nano /etc/nvidia-container-runtime/config.toml`
      1. Set the parameter: `no-cgroups = false`
      1. `sudo systemctl restart docker`
      1. Run test: `sudo docker run --rm --runtime=nvidia --gpus all ubuntu nvidia-smi`
1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/)
   - [Linux post-installation steps for Docker Engine](https://docs.docker.com/engine/install/linux-postinstall/)
1. :bulb: Create new HDD on the VM (to hold the models; useful to ease the backup process) and map it to `/data`

### Deploy containers

1. Clone the repository to your local machine.
1. Install Portainer: `sh ./portainer/execute-update.sh`
1. Install OpenWebUI: `sh ./open-webui/execute-update.sh`
1. Install Ollama: `sh ./ollama/execute-update.sh`
1. Install models in Ollama:

   ```bash
   docker exec -it ollama bash

   # Best Performance (Stable & Fast)
   ollama pull mistral:7b
   ollama pull llama3.1:8b
   ollama pull phi:2.7b
   ollama pull deepseek-r1:8b
   # Personal Management
   ollama pull granite3.2:8b
   # Coding
   ollama pull granite-code:8b
   ollama pull codegemma:7b
   ollama pull starcoder2:7B
   ```

1. Navigate to the Open WebUI interface in your browser at `http://[server]:8080`
   - [Open WebUI Getting Started](https://docs.openwebui.com/getting-started/quick-start)

## Future Enhancements

Planned enhancements include:

- Integration with more AI models and functionalities.
- Performance optimization across all services.
- Expanding the web interface with additional interactive features.
- Implementing DevSecOps practices to secure and automate deployment pipelines.
