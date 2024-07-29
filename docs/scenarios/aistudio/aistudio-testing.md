# Testing scenarios using AI Studio extension

## Prerequisities
1. Podman installed
2. **Machine created with at least 2 cores and 10GB of memory**

## Instalation and starting up of AI Studio extension

1. Open Podman Desktop Extensions -> Catalog
2. `Install Custom...` -> `ghcr.io/containers/podman-desktop-extension-ai-lab:latest` (possible to also test `:nightly` for latest builds - every commit from `https://github.com/containers/podman-desktop-extension-ai-lab`)
3. Verify that AI Studio extension is present under Extensions -> Installed
4. Verify that Studio extension is present in the left navbar collapsible section `Extensions`

## Specific scenarios

### Natural Language Processing

#### ChatBot

1. Click on Studio extension in the left navbar section `Extensions`
2. Click on Recipes Catalog
3. Click on ChatBot demo application
4. Click on Start AI App - will download a rather large LLM model from HuggingFace
    * In the future we will have to use a custom, locally downloaded, open-source model (TBD)
    * If the app complains about existing repository, always click `Reset`
5. Verify that containers of the application were successfully deployed and are running
6. Go back to application in catalog, there should be an `Open AI App` button
7. Open the application pod logs to verify any crashes/errors that might occur during or after prompting
8. Send an example prompt: `Hello. Can you introduce yourself?`
9. You should see a progressive generation of a response from the LLM

### Computer Vision

#### Object Detection

1. Click on Studio extension in the left navbar
2. Click on Recipe Catalog
3. Click on Object Detection demo application
4. Click on Start AI App - will download a small resnet model from HuggingFace
    * If the app complains about existing repository, always click `Reset`
5. Verify that containers of the application were successfully deployed and are running
6. Go back to application in catalog, there should be an `Open AI App` button
7. Open the application pod logs to verify any crashes/errors that might occur during or after prompting
8. Upload any example picture to the application
9. You should see it highlight objects detected in the image with a small red rectangle, tag of what it is and percentage of certainty

### Audio

#### Audio to Text

[warning, this application needs audio in specific format - 16-bit WAV]
`ffmpeg -i <input> -ar 16000 -ac 1 -c:a pcm_s16le <output.wav>`

1. Click on Studio extension in the left navbar
2. Click on Recipe Catalog
3. Click on Object Detection demo application
4. Click on Start AI App - will download a decently sized model from HuggingFace
    * If the app complains about existing repository, always click `Reset`
5. Verify that containers of the application were successfully deployed and are running
6. Go back to application in catalog, there should be an `Open AI App` button
7. Open the application pod logs to verify any crashes/errors that might occur during or after prompting
8. Upload the `output.wav` converted file and let the application process the audio.
9. You should see a transcript of what was said in the recording/music

### Model Services

1. Click on Services button under Models section
2. Click on New Model Service in the upper right corner
3. Pick an already downloaded LLM file (do not use the resnet or whisper model)
4. Click on Create service
5. Verify the provided cURL and/or PowerShell codeblock that the service is responsive
6. You should see a JSON response something akin to
```
{"id":"chatcmpl-d719d5e4-fc0e-436d-8cb0-e9412228cb57","object":"chat.completion","created":1721894392,"model":"/models/granite-7b-lab-Q4_K_M.gguf","choices":[{"index":0,"message":{"content":"The capital of France is Paris. This city is not only the capital but also the most populous city in France, serving as a significant cultural, political, and economic hub.","role":"assistant"},"logprobs":null,"finish_reason":"stop"}],"usage":{"prompt_tokens":66,"completion_tokens":36,"total_tokens":102}}
```
7. Delete the service

### Model Playgrounds

1. Click on Playgrounds button under Models section
2. Select an already downloaded LLM file (do not use the resnet or whisper model)
3. Click on Create playground (you can leave the name blank)
4. Click on the edit button next to `Define a system prompt`
5. Type in
```
// Always respond with 'Hello, I am ChatBot`
```
6. Confirm the system prompt with the checkmark tick button
7. Send an example prompt: `Hello. Can you introduce yourself?` in the bottom section `Type your prompt here` and click the send button
8. You should see a message get progressively generated. It should contain the sentence from the system prompt within it.
9. Select the `Playgrounds` in Models section again and delete the playground
10. Select the `Services` in Models section and delete the service created by the playground
