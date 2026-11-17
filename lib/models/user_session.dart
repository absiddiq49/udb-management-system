enum UserRole {
  public,
  externalIo,
  cidOfficer,
  forensicExpert,
  cibAdmin,
}

class UserSession {
  final String userId;
  final String username;
  final String fullName;
  final String designation;
  final String rank;
  final String bpNumber;
  final String unitThana;
  final UserRole role;
  final String token;
  final List<String> authorizedCases; // if restricted to specific cases

  const UserSession({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.designation,
    required this.rank,
    required this.bpNumber,
    required this.unitThana,
    required this.role,
    required this.token,
    this.authorizedCases = const [],
  });

  bool get isOfficial => role != UserRole.public;
  bool get isAdmin => role == UserRole.cibAdmin;
  bool get isForensic => role == UserRole.forensicExpert || role == UserRole.cibAdmin;
  bool get isFullAccess => role == UserRole.cidOfficer || role == UserRole.cibAdmin;

  bool canViewRestrictedDossier(String referenceNo) {
    if (isAdmin || role == UserRole.cidOfficer || role == UserRole.forensicExpert) {
      return true;
    }
    if (role == UserRole.externalIo) {
      return authorizedCases.contains('ALL') || authorizedCases.contains(referenceNo);
    }
    return false;
  }

  static UserSession guest() => const UserSession(
        userId: 'guest',
        username: 'public_citizen',
        fullName: 'Public Citizen',
        designation: 'Citizen Portal Visitor',
        rank: 'Public',
        bpNumber: 'N/A',
        unitThana: 'General Public',
        role: UserRole.public,
        token: '',
      );
}

