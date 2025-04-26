# dind-aws-cli

This repository contains a Dockerfile for building a Docker image that integrates AWS CLI (`aws-cli`) with Docker-in-Docker (`dind`). This setup is ideal for workflows requiring Docker operations alongside AWS service interactions, such as deploying containers to AWS Elastic Container Service (ECS) or other AWS-related tasks.

## Features

- **AWS CLI**: Provides access to AWS services.
- **Docker-in-Docker (dind)**: Enables running Docker commands inside containers.

## Local Usage

   Pull the image from the Docker registry (you need to login first):
   ```bash
   docker pull ghcr.io/hagzag/semantic-release-image:latest
   ```

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



