# Testing scenarios using AI Studio extension

## Prerequisities
1. Podman installed
2. Machine created with at least 2 cores and 10GB of memory

## Instalation and starting up of AI Studio extension

1. Open Podman Desktop Settings -> Extensions
2. Install a new extension from OCI Image -> `ghcr.io/containers/podman-desktop-extension-ai-lab:latest` (possible to also test `:nightly` for latest builds - every commit from `https://github.com/containers/podman-desktop-extension-ai-lab`)
3. Verify that AI Studio extension is present under Settings -> Extensions
4. Verify that Studio extension is present in the left navbar

## Running an AI Studio demo

1. Click on Studio extension in the left navbar
2. Click on Recipe Catalog
3. Click on ChatBot demo application
4. Click on Start AI App - will download a rather large LLM model from HuggingFace
    * In the future we will have to use a custom, locally downloaded, open-source model (TBD)
5. Verify that containers of the application were successfully deployed and are running
6. Open `pod-chatbot-interface-app` Logs from Pods navbar, look for `Running on local URL:` at the bottom of the logs
7. Open said application URL in your browser (look at the port and navigate to `<protocol>`://localhost:`<port>`)
8. Keep the pod logs open to verify any crashes/errors that might occure
9. Send an example prompt: `Hello. Can you introduce yourself?`
10. You should see a progressive generation of a response from the LLM
