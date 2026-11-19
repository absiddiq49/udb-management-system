import 'package:flutter_test/flutter_test.dart';
import 'package:unidentified_dead_body/services/udb_repository.dart';

void main() {
  group('UDBMS Agency Filter & PostgreSQL Model Tests', () {
    late UdbRepository repository;

    setUp(() {
      repository = UdbRepository();
    });

    test('Initial records loaded across multiple divisions', () {
      final all = repository.getAllRecords();
      expect(all.isNotEmpty, isTrue);
      expect(all.length >= 8, isTrue);
    });

    test('Filter by CID Forensics returns CID cases', () {
      final results = repository.filterRecords(const UdbFilterParams(agency: 'CID'));
      expect(results.isNotEmpty, isTrue);
      for (final r in results) {
        final matches = r.inputTeam.toLowerCase().contains('cid') ||
            r.recoveryOfficerUnit.toLowerCase().contains('cid');
        expect(matches, isTrue);
      }
    });

    test('Filter by DMP returns DMP cases', () {
      final results = repository.filterRecords(const UdbFilterParams(agency: 'DMP'));
      expect(results.isNotEmpty, isTrue);
      for (final r in results) {
        final matches = r.inputTeam.toLowerCase().contains('dmp') ||
            r.recoveryOfficerUnit.toLowerCase().contains('dmp');
        expect(matches, isTrue);
      }
    });

    test('Filter by PBI returns PBI cases', () {
      final results = repository.filterRecords(const UdbFilterParams(agency: 'PBI'));
      expect(results.isNotEmpty, isTrue);
      for (final r in results) {
        final matches = r.inputTeam.toLowerCase().contains('pbi') ||
            r.recoveryOfficerUnit.toLowerCase().contains('pbi');
        expect(matches, isTrue);
      }
    });

    test('Filter by RAB returns RAB cases', () {
      final results = repository.filterRecords(const UdbFilterParams(agency: 'RAB'));
      expect(results.isNotEmpty, isTrue);
      for (final r in results) {
        final matches = r.inputTeam.toLowerCase().contains('rab') ||
            r.recoveryOfficerUnit.toLowerCase().contains('rab');
        expect(matches, isTrue);
      }
    });

    test('Filter by Railway Police returns Railway cases', () {
      final results = repository.filterRecords(const UdbFilterParams(agency: 'Railway'));
      expect(results.isNotEmpty, isTrue);
      for (final r in results) {
        final matches = r.inputTeam.toLowerCase().contains('railway') ||
            r.recoveryOfficerUnit.toLowerCase().contains('railway');
        expect(matches, isTrue);
      }
    });

    test('Filter by Highway Police returns Highway cases', () {
      final results = repository.filterRecords(const UdbFilterParams(agency: 'Highway'));
      expect(results.isNotEmpty, isTrue);
      for (final r in results) {
        final matches = r.inputTeam.toLowerCase().contains('highway') ||
            r.recoveryOfficerUnit.toLowerCase().contains('highway');
        expect(matches, isTrue);
      }
    });
  });
}
