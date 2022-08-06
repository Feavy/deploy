# Build and deploy a Docker image to Kubernetes

Steps:
1. Build the image
2. Push the image to GitHub Container Registry (GHCR)
3. Apply deployment to the Kubernetes cluster

Example:

```yml
# .github/workflows/deploy.yml

name: Build image and deploy to kubernetes

on:
  push:
    branches: [ "main" ]

jobs:
  deploy:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3
        with:
          path: .

      - uses: feavy/deploy@main
        env:
          KUBE_CONFIG: ${{ secrets.KUBE_CONFIG }}
          GITHUB_USERNAME: feavy
          GITHUB_TOKEN: ${{ secrets.PAT }}
          DOCKERFILE_PATH: .
          DOCKER_IMAGE: feavy-nginx:latest
          DEPLOYMENT: deployment.yml

      # Manually restart deployment if needed:
      - name: Restart deployment
        run: kubectl rollout restart deployment feavy-nginx

```

Source: https://github.com/Feavy/nginx-k8s