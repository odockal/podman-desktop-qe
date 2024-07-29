# Testing scenarios using AI Studio extension

## Prerequisities
1. Podman installed
2. Machine created with at least 2 cores and 10GB of memory

## Instalation and starting up of AI Studio extension

1. Open Podman Desktop Extensions -> Catalog
2. `Install Custom...` -> `ghcr.io/containers/podman-desktop-extension-ai-lab:latest` (possible to also test `:nightly` for latest builds - every commit from `https://github.com/containers/podman-desktop-extension-ai-lab`)
3. Verify that AI Studio extension is present under Extensions -> Installed
4. Verify that Studio extension is present in the left navbar collapsible section `Extensions`

## Running an AI Studio demo

1. Click on Studio extension in the left navbar section `Extensions`
2. Click on Recipes Catalog
3. Click on ChatBot demo application
4. Click on Start AI App - will download a rather large LLM model from HuggingFace
    * In the future we will have to use a custom, locally downloaded, open-source model (TBD)
5. Verify that containers of the application were successfully deployed and are running
6. Inside the AI Lab tab, navigate to Running, look for PORT XXXXX under the model name in MODEL column
7. Open chatbot application URL in your browser (look at the port and navigate to `<protocol>`://localhost:`<port>`)
8. Keep the pod logs open to verify any crashes/errors that might occur
9. Send an example prompt: `Hello. Can you introduce yourself?`
10. You should see a progressive generation of a response from the LLM
