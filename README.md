# BrainCloud Contracts

## Setup

### 1. Setup Foundry

[Installation instructions](https://book.getfoundry.sh/getting-started/installation)

```bash
# Download foundry
$ curl -L https://foundry.paradigm.xyz | bash

# Install foundry
$ foundryup

# (Mac only) Install anvil (prereq: Homebrew)
$ brew install libusb
```

### 2. Install contract dependencies

```bash
# <root>
$ make install
```

### 3. Setup contracts environment variables

See `.env.example` This is set in your root directory.

## Deployment

### 1. Deploy Contracts

```bash
# <root>/contracts
make deploy-token
```

```bash
# <root>/contracts
make deploy-subscription
```

```bash
# <root>/contracts
make deploy-rewards-pool
```
