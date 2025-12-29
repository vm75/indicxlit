# IndicXlit Docker Container Setup

## Setup Instructions

### 1. GitHub Secrets Configuration

To enable automatic publishing to Docker Hub and GitHub Container Registry, you need to configure the following secrets in your GitHub repository:

#### Docker Hub Secrets

1. Go to your GitHub repository settings
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following secrets:
   - `DOCKER_HUB_USERNAME`: Your Docker Hub username
   - `DOCKER_HUB_TOKEN`: Your Docker Hub access token (create one at https://hub.docker.com/settings/security)

#### GitHub Container Registry

GHCR uses the built-in `GITHUB_TOKEN` automatically - no additional configuration needed.

### 2. Workflow Triggers

The workflow will automatically run when:
- Code is pushed to `main` or `master` branch
- A tag starting with `v` is pushed (e.g., `v1.0.0`)
- A pull request is created (builds only, doesn't publish)
- Manually triggered via GitHub Actions UI

### 3. Docker Tags

The workflow creates the following tags:
- `latest` - for commits to the default branch
- `main` / `master` - for commits to respective branches
- `v1.2.3`, `v1.2`, `v1` - for semantic version tags
- `pr-123` - for pull requests

### 4. Publishing Your First Release

```bash
# Tag your release
git tag v1.0.0
git push origin v1.0.0

# Or push to main branch
git push origin main
```

### 5. Multi-platform Support

The workflow builds images for both:
- `linux/amd64` (Intel/AMD)
- `linux/arm64` (ARM, Apple Silicon)

## Manual Testing

Test the workflow locally before pushing:

```bash
# Build the image
docker build -t indicxlit:test .

# Run it
docker run -d -p 4321:4321 indicxlit:test

# Test the API
curl -X POST http://localhost:4321/transliterate \
  -H "Content-Type: application/json" \
  -d '{"input": "namaste", "source": "en", "target": "hi"}'
```
