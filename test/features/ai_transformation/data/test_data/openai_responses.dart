// Test data for OpenAI API responses based on official documentation
// https://platform.openai.com/docs/api-reference

class OpenAITestData {
  /// Successful DALL-E 3 image generation response
  static const Map<String, dynamic> successfulImageResponse = {
    "created": 1589478378,
    "data": [
      {
        "url": "https://example.com/generated-image.png",
        "revised_prompt":
            "A futuristic cityscape at sunset, with sleek glass towers reflecting the orange and pink hues of the sky. Flying cars move between the buildings, and holographic advertisements float in the air. The scene captures a sense of advanced technology and urban beauty.",
      },
    ],
  };

  /// Successful DALL-E 3 response with base64 format
  static const Map<String, dynamic> successfulBase64Response = {
    "created": 1589478378,
    "data": [
      {
        "b64_json":
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
        "revised_prompt":
            "A simple white pixel representing minimalism and digital art.",
      },
    ],
  };

  /// Multiple images response (for DALL-E 2)
  static const Map<String, dynamic> multipleImagesResponse = {
    "created": 1589478378,
    "data": [
      {"url": "https://example.com/image1.png"},
      {"url": "https://example.com/image2.png"},
      {"url": "https://example.com/image3.png"},
    ],
  };

  /// Successful models list response
  static const Map<String, dynamic> successfulModelsResponse = {
    "object": "list",
    "data": [
      {
        "id": "dall-e-3",
        "object": "model",
        "created": 1698785189,
        "owned_by": "system",
      },
      {
        "id": "dall-e-2",
        "object": "model",
        "created": 1698785189,
        "owned_by": "system",
      },
      {
        "id": "gpt-4",
        "object": "model",
        "created": 1687882411,
        "owned_by": "openai",
      },
    ],
  };

  /// Error response - Invalid API key (401)
  static const Map<String, dynamic> invalidApiKeyError = {
    "error": {
      "message":
          "Incorrect API key provided: sk-proj-****. You can find your API key at https://platform.openai.com/account/api-keys.",
      "type": "invalid_request_error",
      "param": null,
      "code": "invalid_api_key",
    },
  };

  /// Error response - Rate limit exceeded (429)
  static const Map<String, dynamic> rateLimitError = {
    "error": {
      "message": "Rate limit reached for requests",
      "type": "requests",
      "param": null,
      "code": "rate_limit_exceeded",
    },
  };

  /// Error response - Invalid request (400)
  static const Map<String, dynamic> invalidRequestError = {
    "error": {
      "message":
          "Invalid value for 'size': must be one of ['1024x1024', '1792x1024', '1024x1792']",
      "type": "invalid_request_error",
      "param": "size",
      "code": null,
    },
  };

  /// Error response - Content policy violation (400)
  static const Map<String, dynamic> contentPolicyError = {
    "error": {
      "message":
          "Your request was rejected as a result of our safety system. Your prompt may contain text that is not allowed by our safety system.",
      "type": "invalid_request_error",
      "param": "prompt",
      "code": "content_policy_violation",
    },
  };

  /// Error response - Server error (500)
  static const Map<String, dynamic> serverError = {
    "error": {
      "message":
          "The server had an error while processing your request. Sorry about that!",
      "type": "server_error",
      "param": null,
      "code": null,
    },
  };

  /// Sample image generation requests
  static const Map<String, dynamic> validImageRequest = {
    "prompt": "A futuristic cityscape at sunset with flying cars",
    "model": "dall-e-3",
    "n": 1,
    "quality": "standard",
    "response_format": "url",
    "size": "1024x1024",
    "style": "vivid",
  };

  static const Map<String, dynamic> hdImageRequest = {
    "prompt": "A photorealistic portrait of a golden retriever in a sunny park",
    "model": "dall-e-3",
    "n": 1,
    "quality": "hd",
    "response_format": "url",
    "size": "1024x1024",
    "style": "natural",
  };

  static const Map<String, dynamic> landscapeImageRequest = {
    "prompt":
        "An abstract painting with bold geometric shapes in primary colors",
    "model": "dall-e-3",
    "n": 1,
    "quality": "standard",
    "response_format": "url",
    "size": "1792x1024",
    "style": "vivid",
  };

  static const Map<String, dynamic> base64ImageRequest = {
    "prompt": "A minimalist line drawing of a mountain landscape",
    "model": "dall-e-3",
    "n": 1,
    "quality": "standard",
    "response_format": "b64_json",
    "size": "1024x1024",
    "style": "natural",
  };
}
