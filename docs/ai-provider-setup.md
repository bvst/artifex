# AI Provider Setup Guide

This guide explains how to configure AI providers for photo transformation in Artifex.

## Quick Start

1. **Copy the environment template**
   ```bash
   cp .env.example .env
   ```

2. **Get your OpenAI API key**
   - Go to [OpenAI Platform](https://platform.openai.com/api-keys)
   - Create an account or sign in
   - Generate a new API key
   - Copy the key (it starts with `sk-`)

3. **Configure your .env file**
   ```env
   OPENAI_API_KEY=sk-your-actual-api-key-here
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Configuration Options

### Required Settings

- `OPENAI_API_KEY`: Your OpenAI API key for DALL-E 3 access

### Optional Settings

- `DEFAULT_AI_PROVIDER`: Which AI provider to use by default (currently only `openai` is supported)
- `ENABLE_COST_ESTIMATION`: Show cost estimates to users (`true`/`false`)
- `API_TIMEOUT_SECONDS`: Timeout for API requests (default: 30)
- `API_RETRY_ATTEMPTS`: Number of retry attempts for failed requests (default: 3)

### Future Provider Support

The architecture supports multiple AI providers. When available, you can configure:
- `GEMINI_API_KEY`: For Google Gemini
- `CLAUDE_API_KEY`: For Anthropic Claude
- `STABILITY_API_KEY`: For Stability AI

## Security Best Practices

1. **Never commit your .env file**
   - The `.env` file is already in `.gitignore`
   - Always use `.env.example` as a template

2. **Keep your API keys secret**
   - Don't share your API keys
   - Rotate keys regularly
   - Use different keys for development and production

3. **Monitor usage**
   - Check your OpenAI dashboard for usage
   - Set up billing alerts
   - DALL-E 3 costs: $0.04 per standard image, $0.08 per HD image

## Troubleshooting

### "AI configuration not found" warning
- Make sure you've created a `.env` file
- Check that your API key is correctly formatted
- Restart the app after changing configuration

### API errors
- Verify your API key is valid
- Check your OpenAI account has credits
- Ensure you have access to DALL-E 3

### Network errors
- Check your internet connection
- Verify firewall/proxy settings
- Try increasing `API_TIMEOUT_SECONDS`

## Using the AI Transformation

Once configured, the app will:
1. Load your API configuration on startup
2. Initialize the DALL-E 3 provider
3. Allow users to transform photos with the "Make kids drawings real" filter

The transformation process:
1. User selects a photo
2. Chooses the transformation filter
3. App sends request to DALL-E 3
4. Transformed image is returned and displayed

## Cost Information

DALL-E 3 pricing (as of 2024):
- Standard quality (1024x1024): $0.04 per image
- HD quality (1024x1024): $0.08 per image

The app shows cost estimates before transformation if `ENABLE_COST_ESTIMATION=true`.

## Architecture

The AI provider system uses a flexible architecture:

```
AIConfiguration
    ↓
AIProviderFactory → AIProvider (DALL-E, Gemini, etc.)
    ↓
TransformPhotoUseCase
    ↓
UI Components
```

This allows easy switching between providers without changing the UI code.