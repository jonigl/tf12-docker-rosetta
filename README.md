# Terraform 0.12 + AWS on Apple Silicon

Run Terraform 0.12.31 + AWS natively on Apple Silicon using a Dockerized environment with `amd64` emulation via Rosetta.

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
