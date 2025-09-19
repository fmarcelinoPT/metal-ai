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

### Update all models

```bash
docker exec -it ollama /bin/bash
ollama list | awk -F: 'NR>1 && !/reviewer/ {system("ollama pull "$1)}'
ollama list | awk 'NR>1 {print $1}' | xargs -I {} sh -c 'echo "Updating model: {}"; ollama pull {}; echo "---"' && echo "All models updated."
```

## Models decision

### `gpt-oss:20b`

- **Goal**: Assistente Pessoal (Para o dia a dia)
- **Resources**: <https://huggingface.co/openai/gpt-oss-20b>

#### Highlights

- Permissive Apache 2.0 license: Build freely without copyleft restrictions or patent risk—ideal for experimentation, customization, and commercial deployment.
- Configurable reasoning effort: Easily adjust the reasoning effort (low, medium, high) based on your specific use case and latency needs.
- Full chain-of-thought: Gain complete access to the model’s reasoning process, facilitating easier debugging and increased trust in outputs. It’s not intended to be shown to end users.
- Fine-tunable: Fully customize models to your specific use case through parameter fine-tuning.
- Agentic capabilities: Use the models’ native capabilities for function calling, web browsing, Python code execution, and Structured Outputs.
- MXFP4 quantization: The models were post-trained with MXFP4 quantization of the MoE weights, making gpt-oss-120b run on a single 80GB GPU (like NVIDIA H100 or AMD MI300X) and the gpt-oss-20b model run within 16GB of memory. All evals were performed with the same MXFP4 quantization.

#### Install

```bash
# ollama pull hf.co/openai/gpt-oss-20b
ollama pull gpt-oss:20b
```

### `mistralai/Mixtral-8x22B-Instruct-v0.1`

- **Goal**: Brainstorming (Ideias e Criatividade)
- **Resources**: <https://huggingface.co/mistralai/Mixtral-8x22B-Instruct-v0.1>

#### Uso Pretendido (Intended Use)

Este modelo foi criado para ser o "motor" de aplicações que exigem alto desempenho e precisão, com especial foco em:

Chatbots e Assistentes Virtuais: O seu design e o fine-tuning "instruct" tornam-no ideal para conversas complexas, onde é necessário manter o contexto, responder a perguntas detalhadas e seguir a lógica do utilizador.

Geração de Conteúdo: É excelente a gerar texto de alta qualidade, desde resumos técnicos e documentação até conteúdo criativo.

Aplicações de Raciocínio Lógico: Pode ser usado em cenários que exigem pensamento estruturado, como análise de dados, planeamento de projetos ou até mesmo resolução de problemas de matemática e de código.

Modernização de Tecnologia: A sua capacidade de "function calling" permite-lhe integrar-se com APIs externas e bases de dados, tornando-o um pilar para a criação de soluções que automatizam fluxos de trabalho ou interagem com sistemas existentes.

Em resumo, é um modelo para developers, arquitetos e engenheiros que pretendem criar soluções robustas e inteligentes, seja para uso interno, seja para produtos comerciais.

#### Capacidades-Chave (Capabilities)

As suas capacidades destacam-se em várias frentes, principalmente devido à sua arquitetura Sparse Mixture-of-Experts (SMoE) e ao seu tamanho:

Raciocínio e Conhecimento Avançado: Embora seja um modelo de 8 experts de 22 mil milhões de parâmetros, usa apenas 39 mil milhões de parâmetros ativos em qualquer momento. Isto permite-lhe ter a capacidade de um modelo muito maior, mas com uma eficiência de processamento superior. É especialmente forte em benchmarks de raciocínio, conhecimento geral, matemática e programação.

Janela de Contexto (Context Window) de 64K Tokens: Esta é uma das suas maiores vantagens. Uma janela de contexto de 64.000 tokens significa que o modelo consegue "lembrar" e processar uma quantidade massiva de texto (o equivalente a dezenas de páginas de um documento ou código). Isto é crucial para tarefas como a sumarização de documentos extensos, a análise de relatórios completos ou a análise de grandes bases de código, algo que te interessa diretamente para resumos executivos.

Competência Multilingue: É fluente em várias línguas, incluindo Português, Inglês, Francês, Italiano, Alemão e Espanhol. Isto torna-o altamente relevante para as tuas operações em Portugal, Angola e Moçambique.

Capacidade Nativas de Function Calling: Esta é uma funcionalidade que o distingue e que permite ao modelo chamar ferramentas ou APIs externas para obter informações ou executar tarefas, indo além da simples geração de texto.

### Install

```bash
# ollama pull hf.co/mistralai/Mixtral-8x22B-Instruct-v0.1
# ollama pull hf.co/mistralai/Mistral-Small-3.2-24B-Instruct-2506
# ollama pull mistral-small:22b-instruct-2409-q4_K_M
ollama pull hf.co/Triangle104/Mistral-Small-24B-Instruct-2501-Q8_0-GGUF
ollama pull hf.co/Triangle104/Mistral-Small-24B-Instruct-2501-Q5_K_M-GGUF
```

### `ibm-granite/granite-3.3-8b-instruct`

- **Goal**: Delegação de Tarefas (Clareza e Estrutura)
- **Resources**: <https://huggingface.co/ibm-granite/granite-3.3-8b-instruct>

#### Intended Use

This model is designed to handle general instruction-following tasks and can be integrated into AI assistants across various domains, including business applications.

#### Capabilities

- Thinking
- Summarization
- Text classification
- Text extraction
- Question-answering
- Retrieval Augmented Generation (RAG)
- Code related tasks
- Function-calling tasks
- Multilingual dialog use cases
- Long-context tasks including long document/meeting summarization, long document QA, etc.

#### Install

```bash
ollama pull hf.co/ibm-granite/granite-3.3-8b-instruct-GGUF
```

## Helpers

### Unload model from memory

```bash
curl http://metalai.onemarc.io:11434/api/generate -d '{"model": "gemma3:12b", "keep_alive": 0}'
curl http://metalai.onemarc.io:11434/api/generate -d '{"model": "hf.co/Triangle104/Mistral-Small-24B-Instruct-2501-Q8_0-GGUF", "keep_alive": 0}'
```

### Pull from hugging faces

Resources: <https://huggingface.co/docs/hub/en/ollama>

Example #1

```bash
ollama pull hf.co/unsloth/Llama-3.3-70B-Instruct-GGUF
ollama pull hf.co/microsoft/phi-4
ollama pull hf.co/microsoft/Phi-4-reasoning
```

## Future Enhancements

Planned enhancements include:

- Integration with more AI models and functionalities.
- Performance optimization across all services.
- Expanding the web interface with additional interactive features.
- Implementing DevSecOps practices to secure and automate deployment pipelines.
