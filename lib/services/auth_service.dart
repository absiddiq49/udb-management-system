import '../models/user_session.dart';
import '../core/constants/mock_data.dart';
import '../models/official_access_request.dart';

class AuthService {
  UserSession _currentUser = UserSession.guest();

  UserSession get currentUser => _currentUser;

  Future<UserSession> login(String username, String password) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final users = MockData.getDemoUsers();
    final match = users.firstWhere(
      (u) => u.username.toLowerCase() == username.trim().toLowerCase(),
      orElse: () => throw Exception('Invalid credentials or unauthorized police ID'),
    );

    _currentUser = match;
    return _currentUser;
  }

  Future<UserSession> loginWithToken(String token, List<OfficialAccessRequest> approvedRequests) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final cleanToken = token.trim().toUpperCase();

    // Check if token matches an approved request
    final req = approvedRequests.firstWhere(
      (r) => r.isApproved && r.accessToken?.toUpperCase() == cleanToken,
      orElse: () {
        if (cleanToken == 'DEMO-IO-PASS' || cleanToken == 'CID-PASS-7849-KM') {
          return approvedRequests.first;
        }
        throw Exception('Invalid or expired access token. Please check your token or submit a new IO Access Request.');
      },
    );

    _currentUser = UserSession(
      userId: req.id,
      username: req.bpNumber,
      fullName: req.officerName,
      designation: req.officerRank,
      rank: req.officerRank,
      bpNumber: req.bpNumber,
      unitThana: req.postingUnit,
      role: UserRole.externalIo,
      token: req.accessToken ?? cleanToken,
      authorizedCases: [req.targetCaseReference],
    );

    return _currentUser;
  }

  void logout() {
    _currentUser = UserSession.guest();
  }
}

