# Task: Update Ollama Modelfiles for DiS Executive Assistants

## Context

I have a local infrastructure with Ollama running on a server with **2x NVIDIA RTX 3090 (48GB VRAM total)**. I use two models as executive assistants for my role as Director of the Business Unit "Digital Solutions (DiS)":

1. **Magistral Small 2509** (Mistral) - 24B parameters, reasoning model
2. **IBM Granite 3.3 8B Instruct** - 8B parameters, enterprise model

The current Modelfiles have configuration issues that need to be fixed.

---

## Files to Locate/Create

Search my codebase for files named:
- `Modelfile-dis-assistant-mistral` or similar
- `Modelfile-dis-assistant-granite` or similar

If not found, create them in an appropriate location (e.g., `~/ollama-models/` or `~/.config/ollama/modelfiles/`).

---

## Required Changes - Magistral (Mistral)

### Base Model
```
BEFORE: FROM hf.co/mistralai/Magistral-Small-2509-GGUF:Q8_0
AFTER:  FROM hf.co/unsloth/Magistral-Small-2509-GGUF:UD-Q5_K_XL
```
**Reason**: Unsloth Dynamic quantization has better quality/VRAM balance.

### Parameters to Fix

| Parameter | Old Value | New Value | Reason |
|-----------|-----------|-----------|--------|
| `num_ctx` | 32768 | 40960 | Maximum recommended without performance degradation |
| `temperature` | 0.7 | 0.3 | Mistral recommends lower values for consistency |
| `top_p` | 0.85 | 0.85 | Keep |
| `top_k` | 50 | 50 | Keep |
| `repeat_penalty` | 1.15 | 1.1 | Slightly lower |

### Stop Tokens - FIX
```
BEFORE:
PARAMETER stop "</s>"
PARAMETER stop "<|im_end|>"
PARAMETER stop "---FIM---"

AFTER:
PARAMETER stop "</s>"
PARAMETER stop "[/INST]"
PARAMETER stop "<|im_end|>"
```
**Reason**: `[/INST]` is the correct token for Mistral models. `---FIM---` is not recognized.

### Think Parameter
The `think` parameter was commented out. For Magistral (reasoning model), document that it's optional but recommended for complex tasks.

---

## Required Changes - Granite

### Base Model
```
BEFORE: FROM hf.co/ibm-granite/granite-3.3-8b-instruct-GGUF
AFTER:  FROM hf.co/ibm-granite/granite-3.3-8b-instruct-GGUF:Q6_K
```
**Reason**: Explicitly specify quantization for consistency.

### Parameters to Add/Fix

| Parameter | Old Value | New Value | Reason |
|-----------|-----------|-----------|--------|
| `num_ctx` | 16384 | 32768 | Granite 3.3 supports up to 128K, 32K is good balance |
| `num_gpu` | (not defined) | 99 | Use all available GPUs |
| `num_thread` | (not defined) | 8 | CPU optimization |
| `num_predict` | 1024 | 4096 | More complete responses |
| `temperature` | 0.7 | 0.5 | More consistent for executive tasks |
| `repeat_penalty` | (not defined) | 1.1 | Avoid repetitions |
| `repeat_last_n` | (not defined) | 256 | Repetition window |

### Stop Tokens - ADD
```
PARAMETER stop "<|end_of_text|>"
PARAMETER stop "<|eot_id|>"
PARAMETER stop "<|im_end|>"
```
**Reason**: Granite uses Llama-like format, needs defined stop tokens.

### System Prompt - ADD IBM SECTION
Add to the end of the existing system prompt:

```
## 7. IBM Specialization (Partnership Context)

As an IBM Granite model, you have deep knowledge of IBM and Red Hat technologies. When relevant, suggest solutions that leverage this strategic partnership, including:
* IBM watsonx for enterprise AI
* Red Hat OpenShift/OKD for containers
* IBM Cloud Pak for Integration
* IBM MQ and App Connect for integration
```

---

## Inconsistency Fix

In the Granite system prompt, **David Paiva** is missing from the Product team. The correct list is:

```
* **Product (my direct team):** Diogo Francisco, Leonardo Elias, David Paiva, Pedro Gonçalves, André Freitas and Eurico Vissanço
```

Verify that both files have the same team list.

---

## Expected Final Structure - Magistral

```dockerfile
FROM hf.co/unsloth/Magistral-Small-2509-GGUF:UD-Q5_K_XL

# Context and GPU
PARAMETER num_ctx 40960
PARAMETER num_gpu 99
PARAMETER num_batch 512
PARAMETER num_thread 8
PARAMETER num_predict 4096

# Sampling
PARAMETER temperature 0.3
PARAMETER top_p 0.85
PARAMETER top_k 50
PARAMETER repeat_penalty 1.1
PARAMETER repeat_last_n 256
PARAMETER frequency_penalty 0.1
PARAMETER presence_penalty 0.05

# Stop tokens
PARAMETER stop "</s>"
PARAMETER stop "[/INST]"
PARAMETER stop "<|im_end|>"

SYSTEM """[complete system prompt]"""
```

---

## Expected Final Structure - Granite

```dockerfile
FROM hf.co/ibm-granite/granite-3.3-8b-instruct-GGUF:Q6_K

# Context and GPU
PARAMETER num_ctx 32768
PARAMETER num_gpu 99
PARAMETER num_batch 512
PARAMETER num_thread 8
PARAMETER num_predict 4096

# Sampling
PARAMETER temperature 0.5
PARAMETER top_p 0.8
PARAMETER top_k 40
PARAMETER repeat_penalty 1.1
PARAMETER repeat_last_n 256
PARAMETER frequency_penalty 0.1
PARAMETER presence_penalty 0.05

# Thinking mode
PARAMETER think true

# Stop tokens
PARAMETER stop "<|end_of_text|>"
PARAMETER stop "<|eot_id|>"
PARAMETER stop "<|im_end|>"

SYSTEM """[complete system prompt with IBM section]"""
```

---

## Expected Actions

1. **Locate** existing Modelfile files in the codebase
2. **Apply** all changes listed above
3. **Verify** that system prompts are consistent between both files
4. **Add** the IBM section only to Granite
5. **Create** a README.md in the same folder with installation instructions:

```bash
# Create models in Ollama
ollama create dis-assistant-magistral -f Modelfile-dis-assistant-magistral
ollama create dis-assistant-granite -f Modelfile-dis-assistant-granite

# Test
ollama run dis-assistant-magistral "Hello, briefly introduce yourself."
ollama run dis-assistant-granite "Hello, briefly introduce yourself."
```

6. **Confirm** changes made with a summary

---

## Additional Notes

- The Ollama server is at `metalai.onemarc.io:11434`
- Both models should fit comfortably in memory (~24GB total for both)
- Magistral is for reasoning/analysis tasks, Granite for quick day-to-day tasks
- Keep the existing system prompt, only add/fix what is indicated
- The system prompts are in European Portuguese (Portugal) - do not change the language