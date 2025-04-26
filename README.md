# semantic-release-image

This repository provides a Docker image that integrates **Docker-in-Docker (dind)** with **AWS CLI** (`aws-cli`). The image is designed for CI/CD workflows requiring Docker operations alongside AWS service interactions, such as deploying containers to AWS Elastic Container Service (ECS) or managing other AWS resources.

## Features

- **Docker-in-Docker (dind)**: Enables running Docker commands inside the container.
- **AWS CLI (`aws-cli`)**: Provides the ability to interact with AWS services directly.
- Preconfigured tools to simplify CI/CD workflows with semantic-release support.

## Pull the Image

You can pull the image from the GitHub Container Registry:

```bash
docker pull ghcr.io/hagzag/semantic-release-image:latest

## in github-actsion

```yaml
name: Release

on:
  push:
    branches:
      - main
      - dev

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up Docker
        uses: docker/setup-buildx-action@v2

      - name: Pull semantic-release Docker image
        run: docker pull ghcr.io/hagzag/semantic-release-image

      - name: Run semantic-release
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          docker run --rm \
            -e GITHUB_TOKEN=$GITHUB_TOKEN \
            -v ${{ github.workspace }}:/workspace \
            -w /workspace \
            ghcr.io/hagzag/semantic-release-image semantic-release
```

## in .gitlab-ci.yml

```yaml
# other build info
release:
  stage: release
  variables:
    GL_TOKEN: $GITLAB_TOKEN
  before_script:
  - apk update && apk add --no-cache npm && rm -rf /var/cache/apk/*
  - npm install -g semantic-release@24 @semantic-release/git @semantic-release/exec
  - |
    cat <<EOF > .releaserc.yml
    branches:
      - main
      - name: dev
        prerelease: true
    plugins:
      - "@semantic-release/release-notes-generator"
      - "@semantic-release/commit-analyzer"
      - "@semantic-release/git"
      - - "@semantic-release/exec"
        - verifyReleaseCmd: echo v\${nextRelease.version} > nextVersion
    EOF
  script:
  - semantic-release
  - test -f nextVersion && echo "SRTAG=$(cat nextVersion)" >> release.env || echo
    "SRTAG=${CI_COMMIT_SHORT_SHA}" >> release.env
  - cat release.env
  artifacts:
    untracked: true
    when: on_success
    expire_in: 30 days
    paths:
    - nextVersion
    reports:
      dotenv:
      - release.env
```



