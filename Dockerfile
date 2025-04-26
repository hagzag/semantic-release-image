FROM docker.io/alpine:3.21.3

RUN apk update \
    && apk add --no-cache curl jq yq bash git nodejs npm openssh glab github-cli jsonnet \
    && rm -rf /var/cache/apk/*

RUN npm install -g semantic-release \
                    @semantic-release/git \
                    @semantic-release/gitlab \
                    @semantic-release/github \
                    semantic-release-docker \
                    semantic-release-helm \
                    semantic-release-helm3 \
                    @semantic-release/release-notes-generator \
                    @semantic-release/commit-analyzer \
                    @semantic-release/changelog \
                    @semantic-release/exec

ENV HELM_EXPERIMENTAL_OCI=1

ENTRYPOINT ["/bin/bash", "-l", "-c"]
