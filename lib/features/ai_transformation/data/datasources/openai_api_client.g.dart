// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'openai_api_client.dart';

// **************************************************************************
// RetrofitGenerator
// **************************************************************************

// ignore_for_file: unnecessary_brace_in_string_interps,no_leading_underscores_for_local_identifiers

class _OpenAIApiClient implements OpenAIApiClient {
  _OpenAIApiClient(this._dio, {this.baseUrl}) {
    baseUrl ??= 'https://api.openai.com/v1/';
  }

  final Dio _dio;

  String? baseUrl;

  @override
  Future<OpenAIImageResponse> generateImage(OpenAIImageRequest request) async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final _data = <String, dynamic>{};
    _data.addAll(request.toJson());
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<OpenAIImageResponse>(
        Options(method: 'POST', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/images/generations',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = OpenAIImageResponse.fromJson(_result.data!);
    return value;
  }

  @override
  Future<OpenAIModelsResponse> getModels() async {
    const _extra = <String, dynamic>{};
    final queryParameters = <String, dynamic>{};
    final _headers = <String, dynamic>{};
    final Map<String, dynamic>? _data = null;
    final _result = await _dio.fetch<Map<String, dynamic>>(
      _setStreamType<OpenAIModelsResponse>(
        Options(method: 'GET', headers: _headers, extra: _extra)
            .compose(
              _dio.options,
              '/models',
              queryParameters: queryParameters,
              data: _data,
            )
            .copyWith(baseUrl: _combineBaseUrls(_dio.options.baseUrl, baseUrl)),
      ),
    );
    final value = OpenAIModelsResponse.fromJson(_result.data!);
    return value;
  }

  RequestOptions _setStreamType<T>(RequestOptions requestOptions) {
    if (T != dynamic &&
        !(requestOptions.responseType == ResponseType.bytes ||
            requestOptions.responseType == ResponseType.stream)) {
      if (T == String) {
        requestOptions.responseType = ResponseType.plain;
      } else {
        requestOptions.responseType = ResponseType.json;
      }
    }
    return requestOptions;
  }

  String _combineBaseUrls(String dioBaseUrl, String? baseUrl) {
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      return dioBaseUrl;
    }

    final url = Uri.parse(baseUrl);

    if (url.isAbsolute) {
      return url.toString();
    }

    return Uri.parse(dioBaseUrl).resolveUri(url).toString();
  }
}
