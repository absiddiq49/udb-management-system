import 'package:flutter/material.dart';
import '../models/udb_record.dart';
import '../services/udb_repository.dart';

class UdbProvider extends ChangeNotifier {
  final UdbRepository _repository = UdbRepository();
  UdbFilterParams _filters = const UdbFilterParams();
  bool _blurSensitive = true;
  String? _selectedCaseReference;

  UdbFilterParams get filters => _filters;
  bool get blurSensitive => _blurSensitive;
  String? get selectedCaseReference => _selectedCaseReference;
  UdbRepository get repository => _repository;

  List<UdbRecord> get allRecords => _repository.getAllRecords();

  List<UdbRecord> get filteredRecords => _repository.filterRecords(_filters);

  UdbRecord? get selectedRecord => _selectedCaseReference != null
      ? _repository.findByReference(_selectedCaseReference!)
      : null;

  // KPI Calculations
  int get totalRecords => _repository.getAllRecords().length;

  int get recentRecoveriesCount {
    return _repository.getAllRecords().length; // active recoveries
  }

  int get afisAvailableCount =>
      _repository.getAllRecords().where((r) => r.hasFingerprint).length;

  int get dnaAvailableCount =>
      _repository.getAllRecords().where((r) => r.hasDna).length;

  int get activeMatchingCount => _repository
      .getAllRecords()
      .where((r) => r.status.toLowerCase().contains('active') || r.status.toLowerCase().contains('verification'))
      .length;

  void toggleBlur() {
    _blurSensitive = !_blurSensitive;
    notifyListeners();
  }

  void setFilters(UdbFilterParams newFilters) {
    _filters = newFilters;
    notifyListeners();
  }

  void updateKeywords(String keywords) {
    _filters = UdbFilterParams(
      keywords: keywords,
      gender: _filters.gender,
      ageGroup: _filters.ageGroup,
      division: _filters.division,
      district: _filters.district,
      thana: _filters.thana,
      status: _filters.status,
      hasFingerprint: _filters.hasFingerprint,
      hasDna: _filters.hasDna,
      quickPreset: _filters.quickPreset,
      sortOption: _filters.sortOption,
    );
    notifyListeners();
  }

  void updateSort(UdbSortOption sort) {
    _filters = UdbFilterParams(
      keywords: _filters.keywords,
      gender: _filters.gender,
      ageGroup: _filters.ageGroup,
      division: _filters.division,
      district: _filters.district,
      thana: _filters.thana,
      status: _filters.status,
      hasFingerprint: _filters.hasFingerprint,
      hasDna: _filters.hasDna,
      quickPreset: _filters.quickPreset,
      sortOption: sort,
    );
    notifyListeners();
  }

  void updateQuickPreset(String? preset) {
    _filters = UdbFilterParams(
      keywords: _filters.keywords,
      gender: _filters.gender,
      ageGroup: _filters.ageGroup,
      division: _filters.division,
      district: _filters.district,
      thana: _filters.thana,
      status: _filters.status,
      hasFingerprint: _filters.hasFingerprint,
      hasDna: _filters.hasDna,
      quickPreset: preset,
      sortOption: _filters.sortOption,
    );
    notifyListeners();
  }

  void resetFilters() {
    _filters = const UdbFilterParams();
    notifyListeners();
  }

  void selectCase(String? ref) {
    _selectedCaseReference = ref;
    notifyListeners();
  }

  void addRecord(UdbRecord record) {
    _repository.addRecord(record);
    notifyListeners();
  }

  void updateRecord(UdbRecord record) {
    _repository.updateRecord(record);
    notifyListeners();
  }

  void addCaseNote(String referenceNo, CaseNoteEntry note) {
    _repository.addCaseNote(referenceNo, note);
    notifyListeners();
  }

  UdbRecord? findRecord(String referenceNo) {
    return _repository.findByReference(referenceNo);
  }
}

