# Artifex Development Checklist

Here is a comprehensive checklist to guide the development of the Artifex app. This document supplements the main Brand Guide by providing specific user stories, technical requirements, and asset needs.

## 1. User Stories & Features

This breaks down the app's functionality into specific tasks from the user's perspective.

### Onboarding:

- [ ] **First Launch**: What does the user see the very first time they open the app? Is there a brief tutorial (e.g., a 3-step swipe-through) explaining the "Upload > Choose Filter > Create" process?

### Image Input:

- [ ] As a user, I want to see two clear, primary buttons on the home screen: "Take a Photo" and "Upload Image".
- [ ] When I tap "Take a Photo", the native device camera interface should open.
- [ ] When I tap "Upload Image", my phone's photo gallery should open for me to select an image.

### Filter Selection:

- [ ] As a user, I want to see a list or scrollable grid of available filters.
- [ ] Each filter in the list should have a descriptive name (e.g., "Make Kids Drawing Real!", "Send it to Mars").
- [ ] **Key Decision**: Does the user select the filter before or after providing an image? (The recommended flow is Image First -> Then Filter).

### Processing:

- [ ] After I've provided an image and selected a filter, I want to see a loading/processing screen so I know the app is working.
- [ ] This screen must display an animated indicator and a message from our brand voice (e.g., "Dreaming up a new reality...", "Painting with pixels...", "Consulting the digital muse...").

### Results & Output:

- [ ] As a user, I want to see the final, generated image displayed clearly on a results screen.
- [ ] **Feature Decision**: Should the results screen include a "Before & After" slider to compare the original and new images?
- [ ] I want to see three clear action buttons on the results screen:
  - **"Save to Gallery"**: Saves the image to the device's main photo album.
  - **"Share"**: Opens the native OS sharing options.
  - **"Start Over"**: Takes the user back to the home screen.

## 2. Screen Wireframes (Low-Fidelity Layouts)

Simple sketches or digital diagrams showing the layout of each screen are needed.

- [ ] **Home Screen**:
  - Position of the Logo/Wordmark.
  - Layout of the "Take a Photo" and "Upload Image" buttons.
  - Layout of the filter selection list/grid.

- [ ] **Processing Screen**:
  - Placement of the loading animation and the brand voice text.

- [ ] **Results Screen**:
  - How the final image is displayed (full screen, card, etc.).
  - Position of the "Before & After" slider control (if included).
  - Placement of the "Save," "Share," and "Start Over" buttons.

## 3. Technical Specifications

- [ ] **AI Model**: The image generation will be powered by the OpenAI DALL-E 3 API.
- [ ] **Prompt Logic**: A clear formula must be defined for how the user's image and our stored text prompt are combined.
  - **Example for "Send to Mars" filter**: The instruction sent to the DALL-E API could be: "Redraw the subject from the user-provided image in a photorealistic style as if they are standing on the rocky, red surface of Mars. The background should show a thin, dusty atmosphere and a distant, small sun."
- [ ] **Initial Prompt List**: Provide the exact, final text for the first 3-5 filters to be implemented.

## 4. Required Assets

- [ ] **Logo Files**: Provide the primary logo, wordmark, and app icon as SVG or high-resolution PNG files.
- [ ] **Copywriting**: Create a document with the final text for all buttons, labels, headlines, and onboarding messages, written according to the brand voice.