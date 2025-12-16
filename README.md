# Terraform 0.12 + AWS on Apple Silicon

Run Terraform 0.12.31 + AWS natively on Apple Silicon using a Dockerized environment with `amd64` emulation via Rosetta.


## Purpose

Terraform 0.12.31 was released before Apple Silicon (M1/M2/M3/M4) and does not natively support the `arm64` architecture. Running the macOS Terraform binary via Rosetta 2 can be slower and can intermittently break provider startup/handshakes, showing errors like:

> Failed to instantiate provider "aws" to obtain schema: Unrecognized remote plugin message:

This Dockerized workflow avoids relying on process-level Rosetta emulation on macOS directly. Instead, it runs Terraform 0.12 inside a `linux/amd64` container, which is typically more stable for legacy provider execution.

> [!TIP]
> Need a different legacy Terraform version?
> Just change the `FROM hashicorp/terraform:0.12.31` line in the `Dockerfile` to your desired version and rebuild the image (`docker build --platform linux/amd64 -t tf12-aws .`).
> As long as the image tag stays `tf12-aws`, the `tf12` wrapper doesn’t need any changes.

## Prerequisites

- **Docker Desktop** installed
- **Enable Rosetta**: Docker Settings → General → Check *"Use Rosetta for x86/amd64 emulation on Apple Silicon"*
- **AWS credentials** configured locally (if using AWS)


## Setup (One-time)

Run these commands from this directory to build the image and configure the shell alias.

### 1. Build the Docker image

```bash
docker build --platform linux/amd64 -t tf12-aws .
```

### 2. Load the alias

**Option A: Temporary (current session only)**
```bash
source ./tf12.zsh
```

**Option B: Permanent (recommended)**
Add this line to your `~/.zshrc`:
```bash
source /path/to/this/directory/tf12.zsh
```

## Usage

> [!WARNING]
> The `tf12` alias must be run from within a git repository. It uses `git rev-parse --show-toplevel` to find the repo root and mount it into the container

### Option A: Interactive Shell (Recommended for multiple commands)

Enter the container to run multiple Terraform commands without startup overhead:

```bash
$ tf12
# Now inside the container
/workspace $ tf init   # 'tf' is aliased to 'terraform'
/workspace $ tf plan
/workspace $ tf apply
/workspace $ exit
```

### Option B: Direct Commands (Quick one-off operations)

```bash
tf12 init
tf12 plan
tf12 apply
```

## Troubleshooting

**AWS authentication error (exit code 255)**
- Ensure you're logged in locally: `aws sso login --profile your-profile`
- Set the profile before running: `export AWS_PROFILE=your-profile`
- Verify credentials: `aws sts get-caller-identity`

**Slow performance**
- Confirm Rosetta is enabled in Docker Desktop settings
- Check Docker resource allocation (Settings → Resources)

**Cannot find git repository**
- The `tf12` alias must be run from within a git repository
- It uses `git rev-parse --show-toplevel` to mount the repo root

**"Cannot connect to Docker daemon"**
- Ensure Docker Desktop is running
- Restart Docker Desktop if needed
