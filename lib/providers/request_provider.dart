import 'package:flutter/material.dart';
import '../models/official_access_request.dart';
import '../models/citizen_report.dart';
import '../models/citizen_tip.dart';
import '../services/udb_repository.dart';

class RequestProvider extends ChangeNotifier {
  final UdbRepository _repository;

  RequestProvider(this._repository);

  List<OfficialAccessRequest> get requests => _repository.getAllRequests();
  List<CitizenReport> get citizenReports => _repository.getAllCitizenReports();
  List<CitizenTip> get citizenTips => _repository.getAllTips();

  int get pendingRequestsCount =>
      _repository.getAllRequests().where((r) => r.isPending).length;

  int get pendingCitizenReportsCount =>
      _repository.getAllCitizenReports().where((r) => r.status.contains('PENDING')).length;

  void submitIORequest(OfficialAccessRequest req) {
    _repository.submitAccessRequest(req);
    notifyListeners();
  }

  void reviewIORequest({
    required String requestId,
    required bool approve,
    required String reviewerName,
    required String notes,
  }) {
    _repository.reviewAccessRequest(
      requestId: requestId,
      approve: approve,
      reviewerName: reviewerName,
      notes: notes,
    );
    notifyListeners();
  }

  void submitCitizenReport(CitizenReport report) {
    _repository.submitCitizenReport(report);
    notifyListeners();
  }

  void submitCitizenTip(CitizenTip tip) {
    _repository.submitCitizenTip(tip);
    notifyListeners();
  }
}

