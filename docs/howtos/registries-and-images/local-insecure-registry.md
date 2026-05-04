# How to set up a local insecure registry with self-signed TLS and basic auth

A local registry with a self-signed certificate and basic authentication is useful for testing registry workflows in Podman Desktop — adding authenticated registries, pulling/pushing images, and certificate trust scenarios.

## Quick start

The setup script lives in the main repository at [`tests/playwright/scripts/setup-insecure-registry.sh`](https://github.com/podman-desktop/podman-desktop/blob/main/tests/playwright/scripts/setup-insecure-registry.sh).

```bash
# Start the registry
./setup-insecure-registry.sh

# Tear down and remove all artifacts
./setup-insecure-registry.sh cleanup
```

All artifacts (certs, htpasswd) are created under `/tmp/pd-test-registry` — nothing is written outside of `/tmp`.

## What the script does

1. Generates a self-signed TLS certificate for `localhost` (with SAN `DNS:localhost,IP:127.0.0.1`)
2. Creates an htpasswd file with a pre-hashed password (bcrypt)
3. Starts a `docker.io/library/registry:2` container on `localhost:5443` with TLS and basic auth enabled

## Credentials

| Field    | Value                                       |
|----------|---------------------------------------------|
| Username | `podmanqe`                                  |
| Password | Available in GitHub secrets and listed below |

**Password:** `mywordismypassword`

## Configuration

| Setting        | Default | Override          |
|----------------|---------|-------------------|
| Registry port  | `5443`  | `REGISTRY_PORT` env var |
| Container name | `pd-test-registry` | —           |

## Behavior when registry already exists

- **On CI** (`CI=true`, set automatically by GitHub Actions): tears down and recreates without prompting.
- **Locally**: prompts the user to choose between tearing down or restarting the existing container.

## Verifying the registry

```bash
# Should return 401 (no credentials)
curl -sk https://localhost:5443/v2/

# Should return 200 (valid credentials)
curl -sk -u podmanqe:mywordismypassword https://localhost:5443/v2/

# Verify TLS certificate subject and SANs
echo | openssl s_client -connect localhost:5443 2>/dev/null \
  | openssl x509 -noout -subject -ext subjectAltName
```

## Using with Podman Desktop

1. Run `./setup-insecure-registry.sh`
2. Open Podman Desktop → Settings → Registries
3. Add registry: `localhost:5443` with credentials above
4. Pull/push images to `localhost:5443/<image>:<tag>`

> **Note:** Since the certificate is self-signed, Podman will reject TLS verification by default.
> For testing purposes you can use `--tls-verify=false` on the CLI, or test the certificate synchronization feature in Podman Desktop.
