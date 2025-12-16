FROM hashicorp/terraform:0.12.31
# Install AWS CLI
RUN apk add --no-cache python3 py3-pip && \
    pip3 install awscli
WORKDIR /workspace
