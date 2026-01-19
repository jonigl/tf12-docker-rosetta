tf12() {
    # 1. Find the root of the git repo dynamically
    local GIT_ROOT
    GIT_ROOT=$(git rev-parse --show-toplevel)

    # 2. Calculate the path from the root to your current folder
    local CURRENT_PATH=$(pwd)
    local RELATIVE_PATH=${CURRENT_PATH#$GIT_ROOT}

    # 3. Initialize Docker Arguments Array
    local DOCKER_ARGS=(
        --rm -it
        --platform linux/amd64
        -v "$GIT_ROOT":/workspace:delegated
        -v "$HOME/.aws:/root/.aws"
        -v "$HOME/.ssh:/root/.ssh:ro"
        -v "$HOME/.kube:/root/.kube:ro"
        -e AWS_PROFILE="${AWS_PROFILE:-default}"
        -e AWS_SDK_LOAD_CONFIG=1
        -e KUBECONFIG="/root/.kube/config"
        -e GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
        --env-file "$HOME/.env.tf12"
        -w "/workspace$RELATIVE_PATH"
    )

    # 4. Safely Append AWS Config Mount (If variable exists)
    if [ -n "${AWS_CONFIG_FILE:-}" ]; then
        if [ -f "$AWS_CONFIG_FILE" ]; then
             DOCKER_ARGS+=(-v "${AWS_CONFIG_FILE}:/root/.aws/config:ro")
        fi
    fi

    # 5. Execution Logic
    if [ $# -eq 0 ]; then
        echo "🔌 Entering Terraform 0.12 Container (Alias 'tf' enabled)..."
        docker run "${DOCKER_ARGS[@]}" \
            --entrypoint /bin/sh \
            tf12-aws \
            -c "echo 'alias tf=terraform' >> ~/.profile && /bin/sh -l"
    else
        docker run "${DOCKER_ARGS[@]}" \
            tf12-aws "$@"
    fi
}
