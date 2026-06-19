# How to set up a local insecure registry with self-signed TLS and basic auth

A local registry with a self-signed certificate and basic authentication is useful for testing registry workflows in Podman Desktop — adding authenticated registries, pulling/pushing images, and certificate trust scenarios.

## Requirements

- **Podman** — used to run the registry container
- **OpenSSL** — used to generate the self-signed TLS certificate (and htpasswd hash when overriding default credentials)

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

1. Generates a self-signed TLS certificate for `localhost` (with SAN `DNS:localhost,IP:127.0.0.1`, `keyUsage=keyCertSign`, and `extendedKeyUsage=serverAuth` for Electron/BoringSSL compatibility)
2. Creates an htpasswd file (pre-computed bcrypt hash for defaults, `openssl passwd -apr1` for custom credentials)
3. Starts a `docker.io/library/registry:2` container on `localhost:5443` with TLS and basic auth enabled

## Credentials

| Field    | Default              | Override env var                |
|----------|----------------------|---------------------------------|
| Username | `testuser`           | `INSECURE_REGISTRY_USERNAME`    |
| Password | `testpassword123`    | `INSECURE_REGISTRY_PASSWORD`    |

## Configuration

| Setting        | Default              | Override env var                |
|----------------|----------------------|---------------------------------|
| Registry port  | `5443`               | `INSECURE_REGISTRY_PORT`        |
| Container name | `pd-test-registry`   | `INSECURE_REGISTRY_CONTAINER_NAME` |

## Behavior when registry already exists

- **On CI** (`CI=true`, set automatically by GitHub Actions): tears down and recreates without prompting.
- **Locally**: prompts the user to choose between tearing down or restarting the existing container.

## Verifying the registry

```bash
# Should return 401 (no credentials)
curl --cacert /tmp/pd-test-registry/registry.crt https://localhost:5443/v2/

# Should return 200 (valid credentials)
curl --cacert /tmp/pd-test-registry/registry.crt -u testuser:testpassword123 https://localhost:5443/v2/

# Alternative: skip TLS verification entirely with -k
curl -sk -u testuser:testpassword123 https://localhost:5443/v2/

# Verify TLS certificate subject and SANs
echo | openssl s_client -connect localhost:5443 2>/dev/null \
  | openssl x509 -noout -subject -ext subjectAltName
```

## Trusting the certificate on the host

The generated certificate includes `keyUsage=keyCertSign` and `basicConstraints=CA:true`, which makes it compatible with Electron's BoringSSL (see [electron/electron#45674](https://github.com/electron/electron/issues/45674#issuecomment-3474002008) and [electron/electron#38527](https://github.com/electron/electron/issues/38527)). Once imported into the system trust store, Podman Desktop will accept it without `--tls-verify=false`.

### Fedora / RHEL / CentOS

```bash
sudo cp /tmp/pd-test-registry/registry.crt /etc/pki/ca-trust/source/anchors/pd-test-registry.crt
sudo update-ca-trust
```

### Ubuntu / Debian

```bash
sudo cp /tmp/pd-test-registry/registry.crt /usr/local/share/ca-certificates/pd-test-registry.crt
sudo update-ca-certificates
```

### macOS

```bash
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain /tmp/pd-test-registry/registry.crt
```

After importing, restart Podman Desktop so it picks up the updated trust store.

### Known issue: Flatpak install does not read host CA certificates

Podman Desktop's `Certificates` class on Linux reads from `/etc/ssl/certs/ca-bundle.crt`. Inside the Flatpak sandbox, this resolves to the **Flatpak runtime's** certificate bundle, not the host's. Importing a cert via `update-ca-trust` on the host has no effect on the Flatpak install.

This is tracked in [podman-desktop#17971](https://github.com/podman-desktop/podman-desktop/issues/17971).

The following approaches were tested and **do not work** with Flatpak:

| Approach | Why it fails |
|----------|-------------|
| `NODE_OPTIONS=--use-system-ca` | "System" inside Flatpak is the runtime's bundle, not the host's |
| `NODE_EXTRA_CA_CERTS=/path/to/cert` | `got` HTTP library uses explicit `certificateAuthority` option, bypassing Node.js core TLS |
| `SSL_CERT_FILE=/path/to/bundle` | Same reason — `got` does not honor this env var |
| `flatpak override --filesystem=/etc/pki/ca-trust:ro` | Flatpak reserves `/etc` — cannot mount into it |

**Workaround (fragile):** Append the certificate directly to the Flatpak runtime's CA bundle:

```bash
cat /tmp/pd-test-registry/registry.crt >> \
  ~/.local/share/flatpak/runtime/org.freedesktop.Platform/x86_64/*/active/files/etc/pki/ca-trust/extracted/pem/tls-ca-bundle.pem
```

> **Warning:** This is overwritten by Flatpak runtime updates.

**Recommended:** Use the native tarball/AppImage/RPM install instead of Flatpak for self-signed certificate testing. The native install reads `/etc/ssl/certs/ca-bundle.crt` directly from the host and works correctly after `update-ca-trust`.

## Using with Podman Desktop

### Native install (tarball, AppImage, RPM) — recommended for cert testing

1. Run `./setup-insecure-registry.sh`
2. Import the certificate into the system trust store (see above)
3. Restart Podman Desktop
4. Open Settings → Registries
5. Add registry: `localhost:5443` with credentials above
6. Pull/push images to `localhost:5443/<image>:<tag>`

### Flatpak install

1. Run `./setup-insecure-registry.sh`
2. Import the certificate into the system trust store (see above)
3. Append the certificate to the Flatpak runtime's CA bundle (see workaround above)
4. Restart Podman Desktop
5. Open Settings → Registries
6. Add registry: `localhost:5443` with credentials above
7. Pull/push images to `localhost:5443/<image>:<tag>`

> **Note:** On macOS/Windows where Podman runs inside a VM, the certificate must also be synchronized to the VM.
> Use the command palette: **Podman: Synchronize certificates to all VMs**.
