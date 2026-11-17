import '../models/udb_record.dart';
import '../models/official_access_request.dart';
import '../models/citizen_report.dart';
import '../models/citizen_tip.dart';
import '../core/constants/mock_data.dart';

class UdbFilterParams {
  final String? keywords;
  final String? gender;
  final String? ageGroup;
  final String? division;
  final String? district;
  final String? thana;
  final String? status;
  final bool? hasFingerprint;
  final bool? hasDna;

  const UdbFilterParams({
    this.keywords,
    this.gender,
    this.ageGroup,
    this.division,
    this.district,
    this.thana,
    this.status,
    this.hasFingerprint,
    this.hasDna,
  });

  bool get isEmpty =>
      (keywords == null || keywords!.trim().isEmpty) &&
      (gender == null || gender!.isEmpty) &&
      (ageGroup == null || ageGroup!.isEmpty) &&
      (division == null || division!.isEmpty) &&
      (district == null || district!.isEmpty) &&
      (thana == null || thana!.isEmpty) &&
      (status == null || status!.isEmpty) &&
      hasFingerprint != true &&
      hasDna != true;
}

class UdbRepository {
  final List<UdbRecord> _records = MockData.getInitialRecords();
  final List<OfficialAccessRequest> _requests = MockData.getInitialRequests();
  final List<CitizenReport> _citizenReports = MockData.getInitialCitizenReports();
  final List<CitizenTip> _tips = [];

  List<UdbRecord> getAllRecords() => List.unmodifiable(_records);
  List<OfficialAccessRequest> getAllRequests() => List.unmodifiable(_requests);
  List<CitizenReport> getAllCitizenReports() => List.unmodifiable(_citizenReports);
  List<CitizenTip> getAllTips() => List.unmodifiable(_tips);

  List<UdbRecord> filterRecords(UdbFilterParams filters) {
    return _records.where((record) {
      if (filters.gender != null && filters.gender!.isNotEmpty) {
        if (record.gender.toLowerCase() != filters.gender!.toLowerCase()) {
          return false;
        }
      }

      if (filters.ageGroup != null && filters.ageGroup!.isNotEmpty) {
        if (record.ageGroup != filters.ageGroup) {
          return false;
        }
      }

      if (filters.division != null && filters.division!.isNotEmpty) {
        if (record.division.toLowerCase() != filters.division!.toLowerCase()) {
          return false;
        }
      }

      if (filters.district != null && filters.district!.isNotEmpty) {
        if (record.district.toLowerCase() != filters.district!.toLowerCase()) {
          return false;
        }
      }

      if (filters.thana != null && filters.thana!.isNotEmpty) {
        if (!record.thana.toLowerCase().contains(filters.thana!.toLowerCase())) {
          return false;
        }
      }

      if (filters.status != null && filters.status!.isNotEmpty) {
        if (record.status != filters.status) {
          return false;
        }
      }

      if (filters.hasFingerprint == true && !record.hasFingerprint) {
        return false;
      }

      if (filters.hasDna == true && !record.hasDna) {
        return false;
      }

      if (filters.keywords != null && filters.keywords!.trim().isNotEmpty) {
        final q = filters.keywords!.trim().toLowerCase();
        final haystack = '${record.referenceNo} ${record.gdCaseReference} ${record.placeFound} '
                '${record.locationFound} ${record.identificationMarks} ${record.tattoos} '
                '${record.scars} ${record.clothing} ${record.personalBelongings} ${record.description}'
            .toLowerCase();
        if (!haystack.contains(q)) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  UdbRecord? findByReference(String ref) {
    try {
      return _records.firstWhere((r) => r.referenceNo.toLowerCase() == ref.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  void addRecord(UdbRecord newRecord) {
    _records.insert(0, newRecord);
  }

  void updateRecord(UdbRecord updated) {
    final idx = _records.indexWhere((r) => r.id == updated.id || r.referenceNo == updated.referenceNo);
    if (idx != -1) {
      _records[idx] = updated;
    }
  }

  // IO Access Requests
  void submitAccessRequest(OfficialAccessRequest req) {
    _requests.insert(0, req);
  }

  void reviewAccessRequest({
    required String requestId,
    required bool approve,
    required String reviewerName,
    required String notes,
  }) {
    final idx = _requests.indexWhere((r) => r.id == requestId);
    if (idx != -1) {
      final token = approve ? 'CID-PASS-${(1000 + idx * 77).toString()}-IO' : null;
      _requests[idx] = _requests[idx].copyWith(
        status: approve ? 'approved' : 'rejected',
        reviewedBy: reviewerName,
        reviewNotes: notes,
        accessToken: token,
        tokenExpiresAt: approve ? '14 Days from Approval' : null,
      );
    }
  }

  // Citizen Reports & Tips
  void submitCitizenReport(CitizenReport report) {
    _citizenReports.insert(0, report);
  }

  void submitCitizenTip(CitizenTip tip) {
    _tips.insert(0, tip);
  }
}

