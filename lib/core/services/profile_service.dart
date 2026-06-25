import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum UserType {
  freelancer,
  client,
  both,
}

class UserSkill {
  final String name;
  final String category;
  final int level; // 1-5
  final int endorsements;
  final bool isVerified;

  UserSkill({
    required this.name,
    required this.category,
    required this.level,
    this.endorsements = 0,
    this.isVerified = false,
  });

  UserSkill copyWith({
    String? name,
    String? category,
    int? level,
    int? endorsements,
    bool? isVerified,
  }) {
    return UserSkill(
      name: name ?? this.name,
      category: category ?? this.category,
      level: level ?? this.level,
      endorsements: endorsements ?? this.endorsements,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'level': level,
      'endorsements': endorsements,
      'isVerified': isVerified,
    };
  }

  factory UserSkill.fromJson(Map<String, dynamic> json) {
    return UserSkill(
      name: json['name'],
      category: json['category'],
      level: json['level'],
      endorsements: json['endorsements'] ?? 0,
      isVerified: json['isVerified'] ?? false,
    );
  }
}

class UserPortfolio {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final List<String> tags;
  final String? projectUrl;
  final DateTime createdAt;
  final int views;
  final int likes;

  UserPortfolio({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.tags,
    this.projectUrl,
    required this.createdAt,
    this.views = 0,
    this.likes = 0,
  });

  UserPortfolio copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? images,
    List<String>? tags,
    String? projectUrl,
    DateTime? createdAt,
    int? views,
    int? likes,
  }) {
    return UserPortfolio(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      projectUrl: projectUrl ?? this.projectUrl,
      createdAt: createdAt ?? this.createdAt,
      views: views ?? this.views,
      likes: likes ?? this.likes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'images': images,
      'tags': tags,
      'projectUrl': projectUrl,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
      'likes': likes,
    };
  }

  factory UserPortfolio.fromJson(Map<String, dynamic> json) {
    return UserPortfolio(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      images: List<String>.from(json['images']),
      tags: List<String>.from(json['tags']),
      projectUrl: json['projectUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
    );
  }
}

class UserReview {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String reviewerAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final List<String> pros;
  final List<String> cons;
  final String projectId;
  final String projectName;

  UserReview({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.pros = const [],
    this.cons = const [],
    required this.projectId,
    required this.projectName,
  });

  UserReview copyWith({
    String? id,
    String? reviewerId,
    String? reviewerName,
    String? reviewerAvatar,
    double? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? pros,
    List<String>? cons,
    String? projectId,
    String? projectName,
  }) {
    return UserReview(
      id: id ?? this.id,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerAvatar: reviewerAvatar ?? this.reviewerAvatar,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reviewerId': reviewerId,
      'reviewerName': reviewerName,
      'reviewerAvatar': reviewerAvatar,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
      'pros': pros,
      'cons': cons,
      'projectId': projectId,
      'projectName': projectName,
    };
  }

  factory UserReview.fromJson(Map<String, dynamic> json) {
    return UserReview(
      id: json['id'],
      reviewerId: json['reviewerId'],
      reviewerName: json['reviewerName'],
      reviewerAvatar: json['reviewerAvatar'],
      rating: json['rating'].toDouble(),
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
      pros: List<String>.from(json['pros'] ?? []),
      cons: List<String>.from(json['cons'] ?? []),
      projectId: json['projectId'],
      projectName: json['projectName'],
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String? bio;
  final String? location;
  final String? website;
  final UserType userType;
  final DateTime joinedAt;
  final bool isVerified;
  final bool isOnline;
  final DateTime? lastSeen;
  
  // Stats
  final double rating;
  final int totalReviews;
  final int completedProjects;
  final double totalEarnings;
  final int responseRate;
  final int responseTime; // in hours
  
  // Skills and Portfolio
  final List<UserSkill> skills;
  final List<UserPortfolio> portfolio;
  final List<UserReview> reviews;
  
  // Social links
  final Map<String, String> socialLinks;
  
  // Availability
  final bool isAvailable;
  final String? availabilityStatus;

  UserProfile({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.bio,
    this.location,
    this.website,
    required this.userType,
    required this.joinedAt,
    this.isVerified = false,
    this.isOnline = false,
    this.lastSeen,
    this.rating = 0.0,
    this.totalReviews = 0,
    this.completedProjects = 0,
    this.totalEarnings = 0.0,
    this.responseRate = 0,
    this.responseTime = 0,
    this.skills = const [],
    this.portfolio = const [],
    this.reviews = const [],
    this.socialLinks = const {},
    this.isAvailable = false,
    this.availabilityStatus,
  });

  UserProfile copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatar,
    String? bio,
    String? location,
    String? website,
    UserType? userType,
    DateTime? joinedAt,
    bool? isVerified,
    bool? isOnline,
    DateTime? lastSeen,
    double? rating,
    int? totalReviews,
    int? completedProjects,
    double? totalEarnings,
    int? responseRate,
    int? responseTime,
    List<UserSkill>? skills,
    List<UserPortfolio>? portfolio,
    List<UserReview>? reviews,
    Map<String, String>? socialLinks,
    bool? isAvailable,
    String? availabilityStatus,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      website: website ?? this.website,
      userType: userType ?? this.userType,
      joinedAt: joinedAt ?? this.joinedAt,
      isVerified: isVerified ?? this.isVerified,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      completedProjects: completedProjects ?? this.completedProjects,
      totalEarnings: totalEarnings ?? this.totalEarnings,
      responseRate: responseRate ?? this.responseRate,
      responseTime: responseTime ?? this.responseTime,
      skills: skills ?? this.skills,
      portfolio: portfolio ?? this.portfolio,
      reviews: reviews ?? this.reviews,
      socialLinks: socialLinks ?? this.socialLinks,
      isAvailable: isAvailable ?? this.isAvailable,
      availabilityStatus: availabilityStatus ?? this.availabilityStatus,
    );
  }

  String get fullName => '$firstName $lastName';
  
  String get displayName => firstName.isNotEmpty ? firstName : email.split('@')[0];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'bio': bio,
      'location': location,
      'website': website,
      'userType': userType.name,
      'joinedAt': joinedAt.toIso8601String(),
      'isVerified': isVerified,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'rating': rating,
      'totalReviews': totalReviews,
      'completedProjects': completedProjects,
      'totalEarnings': totalEarnings,
      'responseRate': responseRate,
      'responseTime': responseTime,
      'skills': skills.map((s) => s.toJson()).toList(),
      'portfolio': portfolio.map((p) => p.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
      'socialLinks': socialLinks,
      'isAvailable': isAvailable,
      'availabilityStatus': availabilityStatus,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
      userType: UserType.values.firstWhere((e) => e.name == json['userType']),
      joinedAt: DateTime.parse(json['joinedAt']),
      isVerified: json['isVerified'] ?? false,
      isOnline: json['isOnline'] ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.parse(json['lastSeen']) : null,
      rating: json['rating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      completedProjects: json['completedProjects'] ?? 0,
      totalEarnings: json['totalEarnings']?.toDouble() ?? 0.0,
      responseRate: json['responseRate'] ?? 0,
      responseTime: json['responseTime'] ?? 0,
      skills: (json['skills'] as List?)
          ?.map((s) => UserSkill.fromJson(s))
          .toList() ?? [],
      portfolio: (json['portfolio'] as List?)
          ?.map((p) => UserPortfolio.fromJson(p))
          .toList() ?? [],
      reviews: (json['reviews'] as List?)
          ?.map((r) => UserReview.fromJson(r))
          .toList() ?? [],
      socialLinks: Map<String, String>.from(json['socialLinks'] ?? {}),
      isAvailable: json['isAvailable'] ?? false,
      availabilityStatus: json['availabilityStatus'],
    );
  }
}

class ProfileState {
  final bool isLoading;
  final String? error;
  final UserProfile? currentUser;
  final UserProfile? viewedProfile;
  final List<UserProfile> searchResults;
  final List<UserSkill> allSkills;
  final Map<String, List<UserReview>> reviewsByUser;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.currentUser,
    this.viewedProfile,
    this.searchResults = const [],
    this.allSkills = const [],
    this.reviewsByUser = const {},
  });

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    UserProfile? currentUser,
    UserProfile? viewedProfile,
    List<UserProfile>? searchResults,
    List<UserSkill>? allSkills,
    Map<String, List<UserReview>>? reviewsByUser,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentUser: currentUser ?? this.currentUser,
      viewedProfile: viewedProfile ?? this.viewedProfile,
      searchResults: searchResults ?? this.searchResults,
      allSkills: allSkills ?? this.allSkills,
      reviewsByUser: reviewsByUser ?? this.reviewsByUser,
    );
  }
}

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService();
});

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier(ref.read(profileServiceProvider));
});

class ProfileService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Mock data for demonstration
  static final List<UserSkill> _mockSkills = [
    UserSkill(name: 'Flutter', category: 'Development', level: 5, endorsements: 23, isVerified: true),
    UserSkill(name: 'React', category: 'Development', level: 4, endorsements: 15),
    UserSkill(name: 'UI/UX Design', category: 'Design', level: 3, endorsements: 8),
    UserSkill(name: 'Node.js', category: 'Development', level: 4, endorsements: 12),
    UserSkill(name: 'Python', category: 'Development', level: 3, endorsements: 6),
    UserSkill(name: 'Figma', category: 'Design', level: 4, endorsements: 18, isVerified: true),
    UserSkill(name: 'Digital Marketing', category: 'Marketing', level: 3, endorsements: 9),
    UserSkill(name: 'Content Writing', category: 'Writing', level: 4, endorsements: 14),
  ];

  // Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = await _storage.read(key: 'current_user_id');
      if (userId == null) return null;

      // Mock user profile - in a real app, you'd fetch from API
      return UserProfile(
        id: userId,
        email: 'user@example.com',
        firstName: 'John',
        lastName: 'Doe',
        avatar: 'https://picsum.photos/seed/user_$userId/200/200.jpg',
        bio: 'Experienced Flutter developer with a passion for creating beautiful mobile applications.',
        location: 'San Francisco, CA',
        website: 'https://johndoe.dev',
        userType: UserType.freelancer,
        joinedAt: DateTime.now().subtract(const Duration(days: 365)),
        isVerified: true,
        isOnline: true,
        rating: 4.8,
        totalReviews: 47,
        completedProjects: 23,
        totalEarnings: 15420.50,
        responseRate: 95,
        responseTime: 2,
        skills: _mockSkills.take(4).toList(),
        portfolio: _generateMockPortfolio(userId),
        reviews: _generateMockReviews(userId),
        socialLinks: {
          'github': 'https://github.com/johndoe',
          'linkedin': 'https://linkedin.com/in/johndoe',
          'twitter': 'https://twitter.com/johndoe',
        },
        isAvailable: true,
        availabilityStatus: 'Available for new projects',
      );
    } catch (e) {
      return null;
    }
  }

  // Get user profile by ID
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // Mock implementation - in a real app, you'd fetch from API
      return UserProfile(
        id: userId,
        email: 'user_$userId@example.com',
        firstName: 'User',
        lastName: '$userId',
        avatar: 'https://picsum.photos/seed/user_$userId/200/200.jpg',
        bio: 'This is a sample bio for user $userId',
        location: 'New York, NY',
        website: null,
        userType: UserType.freelancer,
        joinedAt: DateTime.now().subtract(Duration(days: int.parse(userId) * 10)),
        isVerified: int.parse(userId) % 3 == 0,
        isOnline: int.parse(userId) % 2 == 0,
        rating: 3.5 + (int.parse(userId) % 5) * 0.3,
        totalReviews: int.parse(userId) * 5,
        completedProjects: int.parse(userId) * 2,
        totalEarnings: int.parse(userId) * 500.0,
        responseRate: 80 + (int.parse(userId) % 20),
        responseTime: 1 + (int.parse(userId) % 4),
        skills: _mockSkills.take(3 + (int.parse(userId) % 3)).toList(),
        portfolio: _generateMockPortfolio(userId),
        reviews: _generateMockReviews(userId),
        socialLinks: {},
        isAvailable: int.parse(userId) % 3 != 0,
        availabilityStatus: int.parse(userId) % 3 != 0 ? 'Available' : 'Busy',
      );
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      // Mock implementation - in a real app, you'd update via API
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Search users
  Future<List<UserProfile>> searchUsers({
    String query = '',
    UserType? userType,
    List<String>? skills,
    double? minRating,
    String? location,
    bool? isAvailable,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // Mock implementation - in a real app, you'd search via API
      await Future.delayed(const Duration(milliseconds: 800));
      
      final results = <UserProfile>[];
      for (int i = 1; i <= 50; i++) {
        final profile = await getUserProfile(i.toString());
        if (profile != null) {
          // Apply filters
          if (query.isNotEmpty && 
              !profile.fullName.toLowerCase().contains(query.toLowerCase()) &&
              !profile.bio!.toLowerCase().contains(query.toLowerCase())) {
            continue;
          }
          
          if (userType != null && profile.userType != userType) continue;
          
          if (minRating != null && profile.rating < minRating) continue;
          
          if (location != null && 
              !profile.location!.toLowerCase().contains(location.toLowerCase())) {
            continue;
          }
          
          if (isAvailable != null && profile.isAvailable != isAvailable) continue;
          
          results.add(profile);
        }
      }
      
      return results.skip(offset).take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Add review
  Future<bool> addReview({
    required String userId,
    required String reviewerId,
    required double rating,
    required String comment,
    List<String>? pros,
    List<String>? cons,
    required String projectId,
    required String projectName,
  }) async {
    try {
      // Mock implementation - in a real app, you'd add via API
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add skill
  Future<bool> addSkill({
    required String userId,
    required String skillName,
    required String category,
    required int level,
  }) async {
    try {
      // Mock implementation - in a real app, you'd add via API
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Endorse skill
  Future<bool> endorseSkill({
    required String userId,
    required String skillName,
    required String endorserId,
  }) async {
    try {
      // Mock implementation - in a real app, you'd endorse via API
      await Future.delayed(const Duration(milliseconds: 300));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Add portfolio item
  Future<bool> addPortfolioItem({
    required String userId,
    required String title,
    required String description,
    required List<String> images,
    required List<String> tags,
    String? projectUrl,
  }) async {
    try {
      // Mock implementation - in a real app, you'd add via API
      await Future.delayed(const Duration(milliseconds: 500));
      return true;
    } catch (e) {
      return false;
    }
  }

  // Get all available skills
  Future<List<UserSkill>> getAllSkills() async {
    try {
      await Future.delayed(const Duration(milliseconds: 200));
      return _mockSkills;
    } catch (e) {
      return [];
    }
  }

  // Get user reviews
  Future<List<UserReview>> getUserReviews(String userId) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      return _generateMockReviews(userId);
    } catch (e) {
      return [];
    }
  }

  // Get user portfolio
  Future<List<UserPortfolio>> getUserPortfolio(String userId) async {
    try {
      // Mock implementation
      await Future.delayed(const Duration(milliseconds: 300));
      return _generateMockPortfolio(userId);
    } catch (e) {
      return [];
    }
  }

  // Generate mock portfolio
  List<UserPortfolio> _generateMockPortfolio(String userId) {
    return [
      UserPortfolio(
        id: 'portfolio_${userId}_1',
        title: 'E-commerce Mobile App',
        description: 'A fully functional e-commerce app with payment integration and real-time inventory management.',
        images: [
          'https://picsum.photos/seed/portfolio_${userId}_1_1/400/300.jpg',
          'https://picsum.photos/seed/portfolio_${userId}_1_2/400/300.jpg',
          'https://picsum.photos/seed/portfolio_${userId}_1_3/400/300.jpg',
        ],
        tags: ['Flutter', 'Firebase', 'E-commerce'],
        projectUrl: 'https://github.com/user/project1',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        views: 150 + int.parse(userId) * 10,
        likes: 25 + int.parse(userId) * 2,
      ),
      UserPortfolio(
        id: 'portfolio_${userId}_2',
        title: 'Social Media Dashboard',
        description: 'Analytics dashboard for social media management with real-time data visualization.',
        images: [
          'https://picsum.photos/seed/portfolio_${userId}_2_1/400/300.jpg',
          'https://picsum.photos/seed/portfolio_${userId}_2_2/400/300.jpg',
        ],
        tags: ['React', 'Charts.js', 'Analytics'],
        projectUrl: 'https://github.com/user/project2',
        createdAt: DateTime.now().subtract(const Duration(days: 60)),
        views: 200 + int.parse(userId) * 15,
        likes: 40 + int.parse(userId) * 3,
      ),
    ];
  }

  // Generate mock reviews
  List<UserReview> _generateMockReviews(String userId) {
    return [
      UserReview(
        id: 'review_${userId}_1',
        reviewerId: 'reviewer_1',
        reviewerName: 'Alice Johnson',
        reviewerAvatar: 'https://picsum.photos/seed/reviewer_1/100/100.jpg',
        rating: 5.0,
        comment: 'Excellent work! Delivered on time and exceeded expectations. Highly recommended!',
        pros: ['Professional', 'Good communication', 'High quality'],
        cons: [],
        projectId: 'proj_123',
        projectName: 'Mobile App Development',
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
      ),
      UserReview(
        id: 'review_${userId}_2',
        reviewerId: 'reviewer_2',
        reviewerName: 'Bob Smith',
        reviewerAvatar: 'https://picsum.photos/seed/reviewer_2/100/100.jpg',
        rating: 4.5,
        comment: 'Great developer with strong technical skills. Would work with again.',
        pros: ['Technical expertise', 'Problem solving'],
        cons: ['Slight delay in delivery'],
        projectId: 'proj_456',
        projectName: 'Web Development',
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
      UserReview(
        id: 'review_${userId}_3',
        reviewerId: 'reviewer_3',
        reviewerName: 'Carol White',
        reviewerAvatar: 'https://picsum.photos/seed/reviewer_3/100/100.jpg',
        rating: 4.0,
        comment: 'Good work overall. Communication could be improved but the final product was solid.',
        pros: ['Quality work', 'Reasonable pricing'],
        cons: ['Communication could be better'],
        projectId: 'proj_789',
        projectName: 'UI/UX Design',
        createdAt: DateTime.now().subtract(const Duration(days: 45)),
      ),
    ];
  }

  // Get profile statistics
  Future<Map<String, dynamic>> getProfileStats(String userId) async {
    // Mock statistics
    return {
      'profileViews': 1234,
      'projectViews': 5678,
      'portfolioViews': 2345,
      'searchAppearances': 890,
      'contactRequests': 45,
      'hireRate': 0.75,
      'repeatClients': 12,
      'averageProjectValue': 650.0,
      'monthlyEarnings': [3200, 2800, 3500, 4100, 3800, 4200],
      'skillsEndorsements': {
        'Flutter': 23,
        'React': 15,
        'UI/UX Design': 8,
      },
      'ratingDistribution': {
        '5': 35,
        '4': 8,
        '3': 3,
        '2': 1,
        '1': 0,
      },
    };
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileService _service;

  ProfileNotifier(this._service) : super(const ProfileState()) {
    _loadCurrentUser();
    _loadAllSkills();
  }

  Future<void> _loadCurrentUser() async {
    try {
      state = state.copyWith(isLoading: true);
      final profile = await _service.getCurrentUserUserProfile();
      state = state.copyWith(
        isLoading: false,
        currentUser: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      );
    }
  }

  Future<void> _loadAllSkills() async {
    try {
      final skills = await _service.getAllSkills();
      state = state.copyWith(allSkills: skills);
    } catch (e) {
      // Handle error
    }
  }

  Future<void> loadUserProfile(String userId) async {
    try {
      state = state.copyWith(isLoading: true);
      final profile = await _service.getUserProfile(userId);
      state = state.copyWith(
        isLoading: false,
        viewedProfile: profile,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load user profile: $e',
      );
    }
  }

  Future<void> updateProfile(UserProfile profile) async {
    try {
      state = state.copyWith(isLoading: true);
      final success = await _service.updateUserProfile(profile);
      if (success) {
        state = state.copyWith(
          isLoading: false,
          currentUser: profile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to update profile',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: $e',
      );
    }
  }

  Future<void> searchUsers({
    String query = '',
    UserType? userType,
    List<String>? skills,
    double? minRating,
    String? location,
    bool? isAvailable,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final results = await _service.searchUsers(
        query: query,
        userType: userType,
        skills: skills,
        minRating: minRating,
        location: location,
        isAvailable: isAvailable,
      );
      state = state.copyWith(
        isLoading: false,
        searchResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Search failed: $e',
      );
    }
  }

  Future<void> addReview({
    required String userId,
    required double rating,
    required String comment,
    List<String>? pros,
    List<String>? cons,
    required String projectId,
    required String projectName,
  }) async {
    try {
      final currentUserId = state.currentUser?.id;
      if (currentUserId == null) return;

      final success = await _service.addReview(
        userId: userId,
        reviewerId: currentUserId,
        rating: rating,
        comment: comment,
        pros: pros,
        cons: cons,
        projectId: projectId,
        projectName: projectName,
      );

      if (success) {
        // Refresh the viewed profile
        if (state.viewedProfile?.id == userId) {
          await loadUserProfile(userId);
        }
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to add review: $e');
    }
  }

  Future<void> addSkill({
    required String skillName,
    required String category,
    required int level,
  }) async {
    try {
      final currentUserId = state.currentUser?.id;
      if (currentUserId == null) return;

      final success = await _service.addSkill(
        userId: currentUserId,
        skillName: skillName,
        category: category,
        level: level,
      );

      if (success) {
        await _loadCurrentUser();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to add skill: $e');
    }
  }

  Future<void> addPortfolioItem({
    required String title,
    required String description,
    required List<String> images,
    required List<String> tags,
    String? projectUrl,
  }) async {
    try {
      final currentUserId = state.currentUser?.id;
      if (currentUserId == null) return;

      final success = await _service.addPortfolioItem(
        userId: currentUserId,
        title: title,
        description: description,
        images: images,
        tags: tags,
        projectUrl: projectUrl,
      );

      if (success) {
        await _loadCurrentUser();
      }
    } catch (e) {
      state = state.copyWith(error: 'Failed to add portfolio item: $e');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await _loadCurrentUser();
  }
}
