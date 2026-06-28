import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator
// const String baseUrl = 'http://localhost:8000/api/v1'; // Web and iOS simulator
// const String baseUrl = 'http://192.168.1.100:8000/api/v1'; // Physical device

// Enable test mode when server is not available
const bool testMode = true;

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized in main.dart');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiService(prefs);
});

class ApiService {
  late final Dio _dio;
  final SharedPreferences _prefs;

  // Placeholder constructor for loading states
  factory ApiService.placeholder() {
    throw UnimplementedError('Use ApiService(SharedPreferences) instead');
  }

  ApiService(this._prefs) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _prefs.getString('token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          _prefs.remove('token');
        }
        return handler.next(error);
      },
    ));
  }

  String? get token => _prefs.getString('token');

  Future<void> saveToken(String token) async {
    print('💾 Saving token: $token');
    await _prefs.setString('token', token);
    final savedToken = _prefs.getString('token');
    print('✅ Token saved successfully: ${savedToken != null ? "YES" : "NO"}');
  }

  Future<void> clearToken() async {
    await _prefs.remove('token');
  }

  // Auth
  Future<Response> login(String email, String password) async {
    if (testMode) {
      // Mock successful login for testing
      if (email == 'test@example.com' && password == 'password123') {
        return Response(
          data: {
            'access_token': 'mock_token_12345',
            'token_type': 'bearer',
          },
          statusCode: 200,
          requestOptions: RequestOptions(path: '/auth/login'),
        );
      } else {
        throw DioException(
          requestOptions: RequestOptions(path: '/auth/login'),
          response: Response(
            data: {'detail': 'Invalid credentials'},
            statusCode: 401,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
          type: DioExceptionType.badResponse,
        );
      }
    }
    
    return _dio.post('/auth/login', data: {
      'username': email,
      'password': password,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return _dio.post('/auth/register', data: data);
  }

  Future<Response> getMe() async {
    if (testMode) {
      return Response(
        data: {
          'id': 1,
          'email': 'test@example.com',
          'name': 'Test User',
          'is_admin': false,
        },
        statusCode: 200,
        requestOptions: RequestOptions(path: '/auth/me'),
      );
    }
    return _dio.get('/auth/me');
  }

  // Listings
  Future<Response> getListings({
    String? search,
    double? minPrice,
    double? maxPrice,
    String? techStack,
    double? minRating,
    String? sortBy,
    int page = 1,
    int limit = 20,
  }) async {
    if (testMode) {
      // Mock listings data
      return Response(
        data: [
          {
            'id': 1,
            'title': 'E-commerce Mobile App',
            'description': 'Complete Flutter e-commerce app with payment integration',
            'price': 299.99,
            'tech_stack': ['Flutter', 'Firebase', 'Stripe'],
            'rating': 4.5,
            'reviews_count': 12,
            'seller': {'name': 'John Doe', 'id': 1},
            'created_at': '2024-01-15T10:30:00Z',
          },
          {
            'id': 2,
            'title': 'Task Management System',
            'description': 'React-based task management tool with real-time collaboration',
            'price': 199.99,
            'tech_stack': ['React', 'Node.js', 'MongoDB'],
            'rating': 4.8,
            'reviews_count': 8,
            'seller': {'name': 'Jane Smith', 'id': 2},
            'created_at': '2024-01-10T14:20:00Z',
          },
          {
            'id': 3,
            'title': 'AI Chatbot Integration',
            'description': 'Python-based chatbot with NLP capabilities',
            'price': 149.99,
            'tech_stack': ['Python', 'TensorFlow', 'FastAPI'],
            'rating': 4.2,
            'reviews_count': 6,
            'seller': {'name': 'Mike Johnson', 'id': 3},
            'created_at': '2024-01-05T09:15:00Z',
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/listings/'),
      );
    }
    
    return _dio.get('/listings/', queryParameters: {
      if (search != null) 'search': search,
      if (minPrice != null) 'min_price': minPrice,
      if (maxPrice != null) 'max_price': maxPrice,
      if (techStack != null) 'tech_stack': techStack,
      if (minRating != null) 'min_rating': minRating,
      if (sortBy != null) 'sort_by': sortBy,
      'skip': (page - 1) * limit,
      'limit': limit,
    });
  }

  Future<Response> getListing(int id) async {
    return _dio.get('/listings/$id');
  }

  Future<Response> createListing(Map<String, dynamic> data) async {
    return _dio.post('/listings/', data: data);
  }

  // Ideas
  Future<Response> getIdeas({int page = 1, int limit = 20}) async {
    return _dio.get('/ideas/', queryParameters: {
      'skip': (page - 1) * limit,
      'limit': limit,
    });
  }

  Future<Response> getIdea(int id) async {
    return _dio.get('/ideas/$id');
  }

  Future<Response> createIdea(Map<String, dynamic> data) async {
    return _dio.post('/ideas/', data: data);
  }

  Future<Response> submitProposal(int ideaId, Map<String, dynamic> data) async {
    return _dio.post('/ideas/$ideaId/proposals', data: data);
  }

  // Reviews
  Future<Response> getReviews({int? listingId, int? userId}) async {
    return _dio.get('/reviews/', queryParameters: {
      if (listingId != null) 'listing_id': listingId,
      if (userId != null) 'user_id': userId,
    });
  }

  Future<Response> createReview(Map<String, dynamic> data) async {
    return _dio.post('/reviews/', data: data);
  }

  // Messages
  Future<Response> getConversations() async {
    if (testMode) {
      return Response(
        data: [
          {
            'user_id': 2,
            'name': 'John Doe',
            'last_message': 'Hey, how is the project going?',
            'timestamp': '2024-01-15T10:30:00Z',
          },
          {
            'user_id': 3,
            'name': 'Jane Smith',
            'last_message': 'Can you send me the files?',
            'timestamp': '2024-01-14T15:20:00Z',
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/messages/conversations'),
      );
    }
    return _dio.get('/messages/conversations');
  }

  Future<Response> getMessages(int recipientId) async {
    if (testMode) {
      return Response(
        data: [
          {
            'id': 1,
            'sender_id': 1,
            'recipient_id': recipientId,
            'content': 'Hello! How are you?',
            'created_at': '2024-01-15T10:30:00Z',
          },
          {
            'id': 2,
            'sender_id': recipientId,
            'recipient_id': 1,
            'content': 'I\'m good, thanks! How about you?',
            'created_at': '2024-01-15T10:31:00Z',
          },
        ],
        statusCode: 200,
        requestOptions: RequestOptions(path: '/messages/$recipientId'),
      );
    }
    return _dio.get('/messages/$recipientId');
  }

  Future<Response> sendMessage(Map<String, dynamic> data) async {
    if (testMode) {
      return Response(
        data: {
          'id': 999,
          'sender_id': 1,
          'recipient_id': data['recipient_id'],
          'content': data['content'],
          'created_at': DateTime.now().toIso8601String(),
        },
        statusCode: 201,
        requestOptions: RequestOptions(path: '/messages/'),
      );
    }
    return _dio.post('/messages/', data: data);
  }

  // Escrow
  Future<Response> getEscrow() async {
    return _dio.get('/escrow/');
  }

  // Disputes
  Future<Response> getDisputes() async {
    return _dio.get('/disputes/');
  }

  Future<Response> createDispute(Map<String, dynamic> data) async {
    return _dio.post('/disputes/', data: data);
  }

  // Admin
  Future<Response> getAdminStats() async {
    return _dio.get('/admin/stats');
  }

  Future<Response> getAdminUsers() async {
    return _dio.get('/admin/users');
  }

  Future<Response> banUser(int userId) async {
    return _dio.patch('/admin/users/$userId/ban');
  }

  Future<Response> unbanUser(int userId) async {
    return _dio.patch('/admin/users/$userId/unban');
  }

  Future<Response> getKycPending() async {
    return _dio.get('/admin/kyc/pending');
  }

  Future<Response> approveKyc(int userId) async {
    return _dio.post('/admin/kyc/$userId/approve');
  }

  Future<Response> rejectKyc(int userId) async {
    return _dio.post('/admin/kyc/$userId/reject');
  }

  // Upload
  Future<Response> uploadFile(String filePath, String fieldName) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
    });
    return _dio.post('/uploads/', data: formData);
  }
}
