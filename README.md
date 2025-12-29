# IndicXlit Docker Container

A simple Docker container for [AI4Bharat/IndicXlit](https://github.com/AI4Bharat/IndicXlit) - a transformer-based multilingual transliteration library for Indic languages.

## Overview

This Docker image provides a REST API server for the AI4Bharat transliteration engine, allowing you to easily transliterate text between different Indic languages and scripts.

## Quick Start

### Pull from Docker Hub

```bash
docker pull vm75/indicxlit:latest
```

### Pull from GitHub Container Registry

```bash
docker pull ghcr.io/vm75/indicxlit:latest
```

### Run the Container

```bash
docker run -d -p 4321:4321 vm75/indicxlit:latest
```

The API server will be available at `http://localhost:4321`

## Building from Source

```bash
git clone https://github.com/vm75/indicxlit.git
cd indicxlit
docker build -t indicxlit .
docker run -d -p 4321:4321 indicxlit
```

## API Usage

### Transliterate Text

**Endpoint:** `POST /transliterate`

The API follows the ULCA (Universal Language Contribution API) specification.

**Request Body:**
```json
{
  "input": [
    {"source": "namaste"}
  ],
  "config": {
    "language": {
      "sourceLanguage": "en",
      "targetLanguage": "hi"
    },
    "isSentence": false,
    "numSuggestions": 5
  }
}
```

**Parameters:**
- `input`: Array of objects with `source` field containing text to transliterate
- `config.language.sourceLanguage`: Source language code (e.g., "en", "hi", "ta")
- `config.language.targetLanguage`: Target language code
- `config.isSentence`: Boolean - `true` for sentence transliteration, `false` for word
- `config.numSuggestions`: Number of suggestions to return (default: 5, max: 10)

**Response:**
```json
{
  "output": [
    {
      "source": "namaste",
      "target": ["नमस्ते", "नामस्ते", "नमास्ते", "नमस्थे", "नमस्तें"]
    }
  ]
}
```

### Example with cURL

**Word transliteration (English to Hindi):**
```bash
curl -X POST http://localhost:4321/transliterate \
  -H "Content-Type: application/json" \
  -d '{
    "input": [{"source": "namaste"}],
    "config": {
      "language": {
        "sourceLanguage": "en",
        "targetLanguage": "hi"
      },
      "isSentence": false,
      "numSuggestions": 5
    }
  }'
```

**Sentence transliteration (English to Tamil):**
```bash
curl -X POST http://localhost:4321/transliterate \
  -H "Content-Type: application/json" \
  -d '{
    "input": [{"source": "vanakkam ulagam"}],
    "config": {
      "language": {
        "sourceLanguage": "en",
        "targetLanguage": "ta"
      },
      "isSentence": true,
      "numSuggestions": 1
    }
  }'
```

**Indic to English (romanization):**
```bash
curl -X POST http://localhost:4321/transliterate \
  -H "Content-Type: application/json" \
  -d '{
    "input": [{"source": "नमस्ते"}],
    "config": {
      "language": {
        "sourceLanguage": "hi",
        "targetLanguage": "en"
      },
      "isSentence": false,
      "numSuggestions": 5
    }
  }'
```

### Supported Languages

The API supports transliteration between various Indic languages including:
- Hindi (hi)
- Bengali (bn)
- Gujarati (gu)
- Punjabi (pa)
- Kannada (kn)
- Malayalam (ml)
- Marathi (mr)
- Oriya (or)
- Tamil (ta)
- Telugu (te)
- Urdu (ur)
- English (en)

## Environment Variables

Currently, no environment variables are required. The server runs on port 4321 by default.

## Docker Compose

Create a `docker-compose.yml` file:

```yaml
version: '3.8'
services:
  indicxlit:
    image: vm75/indicxlit:latest
    ports:
      - "4321:4321"
    restart: unless-stopped
```

Run with:
```bash
docker-compose up -d
```

## Credits

This container wraps the excellent work by [AI4Bharat](https://github.com/AI4Bharat) on the [IndicXlit](https://github.com/AI4Bharat/IndicXlit) transliteration engine.

## License

This Docker container is provided as-is. Please refer to the [AI4Bharat/IndicXlit license](https://github.com/AI4Bharat/IndicXlit/blob/main/LICENSE) for the underlying transliteration engine.

## Issues and Contributions

If you encounter any issues or have suggestions, please open an issue on the [GitHub repository](https://github.com/vm75/indicxlit).
