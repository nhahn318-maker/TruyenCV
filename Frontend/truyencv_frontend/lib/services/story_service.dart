import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/story.dart';
import '../models/api_response.dart';
import 'http_client_helper.dart';

class StoryService {
  final http.Client _client = HttpClientHelper.createHttpClient();
  // Lấy tất cả truyện (có thể filter theo authorId, primaryGenreId, q)
  Future<ApiResponse<List<StoryListItem>>> getAllStories({
    int? authorId,
    int? primaryGenreId,
    String? q,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.storiesEndpoint}/all').replace(
        queryParameters: {
          if (authorId != null) 'authorId': authorId.toString(),
          if (primaryGenreId != null)
            'primaryGenreId': primaryGenreId.toString(),
          if (q != null && q.isNotEmpty) 'q': q,
        },
      );

      final response = await _client
          .get(
            uri,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception(
                'Kết nối timeout. Vui lòng kiểm tra backend có đang chạy không.',
              );
            },
          );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        final apiResponse = ApiResponse.fromJson(jsonData, (data) {
          if (data is List) {
            return data.map((item) {
              return StoryListItem.fromJson(
                item as Map<String, dynamic>,
              );
            }).toList();
          }
          return <StoryListItem>[];
        });

        return apiResponse;
      } else {
        return ApiResponse(
          status: false,
          message:
              'Lỗi từ server: ${response.statusCode} - ${response.reasonPhrase}',
          data: null,
        );
      }
    } catch (e) {
      String errorMessage = 'Lỗi kết nối: ${e.toString()}';

      if (e.toString().contains('Failed to fetch') ||
          e.toString().contains('NetworkError')) {
        errorMessage =
            'Không thể kết nối đến backend. Vui lòng kiểm tra:\n'
            '1. Backend có đang chạy trên http://localhost:5057 không?\n'
            '2. CORS đã được cấu hình đúng chưa?\n'
            '3. Thử mở http://localhost:5057/api/stories/all trong trình duyệt';
      }

      return ApiResponse(status: false, message: errorMessage, data: null);
    }
  }

  // Lấy truyện theo ID
  Future<ApiResponse<Story?>> getStoryById(int id) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.storiesEndpoint}/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null) {
          return Story.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Tạo truyện mới
  Future<ApiResponse<Story?>> createStory(StoryCreateDTO dto) async {
    try {
      // Tạo form data body
      final Map<String, String> formData = {
        'title': dto.title,
        'authorId': dto.authorId.toString(),
        'status': dto.status,
      };
      
      if (dto.description != null && dto.description!.isNotEmpty) {
        formData['description'] = dto.description!;
      }
      if (dto.coverImage != null && dto.coverImage!.isNotEmpty) {
        formData['coverImage'] = dto.coverImage!;
      }
      if (dto.primaryGenreId != null) {
        formData['primaryGenreId'] = dto.primaryGenreId.toString();
      }

      // Encode form data với UTF-8
      final encodedBody = formData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _client.post(
        Uri.parse('${ApiConfig.storiesEndpoint}/create'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          'Accept': 'application/json',
        },
        body: encodedBody,
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null) {
          return Story.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Cập nhật truyện
  Future<ApiResponse<Story?>> updateStory(int id, StoryUpdateDTO dto) async {
    try {
      // Tạo form data body
      final Map<String, String> formData = {
        'title': dto.title,
        'authorId': dto.authorId.toString(),
        'status': dto.status,
      };
      
      if (dto.description != null && dto.description!.isNotEmpty) {
        formData['description'] = dto.description!;
      }
      if (dto.coverImage != null && dto.coverImage!.isNotEmpty) {
        formData['coverImage'] = dto.coverImage!;
      }
      if (dto.primaryGenreId != null) {
        formData['primaryGenreId'] = dto.primaryGenreId.toString();
      }

      // Encode form data với UTF-8
      final encodedBody = formData.entries
          .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
          .join('&');

      final response = await _client.put(
        Uri.parse('${ApiConfig.storiesEndpoint}/update-$id'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=utf-8',
          'Accept': 'application/json',
        },
        body: encodedBody,
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null) {
          return Story.fromJson(data as Map<String, dynamic>);
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Xóa truyện
  Future<ApiResponse<bool>> deleteStory(int id) async {
    try {
      final response = await _client.delete(
        Uri.parse('${ApiConfig.storiesEndpoint}/delete-$id'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) => true);

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: false,
      );
    }
  }

  // Lấy truyện mới nhất
  Future<ApiResponse<Map<String, dynamic>?>> getLatestStories({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.storiesEndpoint}/latest').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy truyện đã hoàn thành
  Future<ApiResponse<Map<String, dynamic>?>> getCompletedStories({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.storiesEndpoint}/completed').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy truyện đang tiến hành
  Future<ApiResponse<Map<String, dynamic>?>> getOngoingStories({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.storiesEndpoint}/ongoing').replace(
        queryParameters: {
          'page': page.toString(),
          'pageSize': pageSize.toString(),
        },
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data != null && data is Map) {
          return data as Map<String, dynamic>;
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy truyện theo tác giả
  Future<ApiResponse<List<StoryListItem>?>> getStoriesByAuthor(
    int authorId,
  ) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.storiesEndpoint}/by-author/$authorId'),
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data is List) {
          return data
              .map(
                (item) => StoryListItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }

  // Lấy truyện theo thể loại
  Future<ApiResponse<List<StoryListItem>?>> getStoriesByGenre(
    int genreId, {
    List<int>? genreIds,
  }) async {
    try {
      final uri = Uri.parse(
        '${ApiConfig.storiesEndpoint}/by-genre/$genreId',
      ).replace(
        queryParameters:
            genreIds != null && genreIds.isNotEmpty
                ? {'genreIds': genreIds.map((id) => id.toString()).toList()}
                : null,
      );

      final response = await _client.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final apiResponse = ApiResponse.fromJson(jsonData, (data) {
        if (data is List) {
          return data
              .map(
                (item) => StoryListItem.fromJson(item as Map<String, dynamic>),
              )
              .toList();
        }
        return null;
      });

      return apiResponse;
    } catch (e) {
      return ApiResponse(
        status: false,
        message: 'Lỗi kết nối: ${e.toString()}',
        data: null,
      );
    }
  }
}
