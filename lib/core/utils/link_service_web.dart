import 'dart:html' as html;
import '../../models/udb_record.dart';
import '../../models/user_session.dart';
import '../constants/app_constants.dart';

class LinkService {
  static String _cleanPhone(String phone) {
    return phone.replaceAll(RegExp(r'[^\d+]'), '');
  }

  static Future<bool> launchPhone(String phoneNumber) async {
    final clean = _cleanPhone(phoneNumber);
    if (clean.isEmpty) return false;
    try {
      html.window.open('tel:$clean', '_self');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> launchEmail(String email, {String? subject, String? body}) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty) return false;

    final queryParams = <String>[];
    if (subject != null && subject.isNotEmpty) {
      queryParams.add('subject=${Uri.encodeComponent(subject)}');
    }
    if (body != null && body.isNotEmpty) {
      queryParams.add('body=${Uri.encodeComponent(body)}');
    }

    final query = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
    final mailtoUrl = 'mailto:$cleanEmail$query';

    try {
      html.window.open(mailtoUrl, '_self');
      return true;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> launchWebUrl(String url) async {
    final targetUrl = url.trim();
    if (targetUrl.isEmpty) return false;
    try {
      html.window.open(targetUrl, '_blank');
      return true;
    } catch (_) {
      return false;
    }
  }

  static void printPage() {
    try {
      html.window.print();
    } catch (_) {}
  }

  /// Opens an isolated, full-width, clean A4 printable document window
  /// with print styling, avoiding any canvas clipping or modal backdrop overlays.
  static void printHtmlDocument({required String title, required String htmlContent}) {
    try {
      final fullDoc = '''<!DOCTYPE html>
<html lang="bn">
<head>
  <meta charset="UTF-8">
  <title>$title</title>
  <style>
    @page {
      size: A4 portrait;
      margin: 10mm 12mm;
    }
    *, *::before, *::after {
      box-sizing: border-box;
    }
    body {
      margin: 0;
      padding: 0;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Helvetica Neue", Arial, sans-serif, "SolaimanLipi";
      color: #0f172a;
      background: #ffffff;
      font-size: 10pt;
      line-height: 1.45;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }
    .print-doc {
      width: 100%;
      max-width: 800px;
      margin: 0 auto;
      padding: 8px 12px;
    }
    .header-center {
      text-align: center;
      margin-bottom: 12px;
    }
    .crest-icon {
      width: 60px;
      height: 60px;
      margin: 0 auto 6px auto;
      display: block;
    }
    .gov-heading-1 {
      font-size: 14pt;
      font-weight: 800;
      color: #0f172a;
      margin: 0 0 2px 0;
      letter-spacing: 0.3px;
    }
    .gov-heading-2 {
      font-size: 11pt;
      font-weight: 700;
      color: #1e3a8a;
      margin: 0 0 2px 0;
    }
    .gov-heading-3 {
      font-size: 9.5pt;
      color: #475569;
      margin: 0 0 8px 0;
    }
    .gazette-badge {
      background: #fef3c7;
      border: 1.5px solid #d97706;
      color: #92400e;
      font-weight: 800;
      font-size: 10pt;
      padding: 5px 12px;
      text-align: center;
      margin: 8px 0 12px 0;
      line-height: 1.35;
      border-radius: 4px;
    }
    .meta-box {
      border: 1px solid #cbd5e1;
      background: #f8fafc;
      padding: 8px 12px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 12px;
      border-radius: 4px;
      font-size: 9pt;
    }
    .meta-ref {
      font-weight: 800;
      color: #0f172a;
      font-size: 9.5pt;
    }
    .meta-sub {
      color: #475569;
      margin-top: 2px;
    }
    .badge-pill {
      background: #dcfce7;
      color: #166534;
      border: 1px solid #86efac;
      padding: 3px 8px;
      font-weight: 700;
      font-size: 8.5pt;
      border-radius: 3px;
    }
    .body-intro {
      font-size: 9.5pt;
      line-height: 1.55;
      margin-bottom: 12px;
      color: #1e293b;
      text-align: justify;
    }
    .data-table {
      width: 100%;
      border-collapse: collapse;
      margin: 10px 0 14px 0;
      font-size: 9pt;
    }
    .data-table th, .data-table td {
      border: 1px solid #cbd5e1;
      padding: 5.5px 9px;
      vertical-align: top;
    }
    .data-table td.col-label {
      width: 38%;
      background-color: #f8fafc;
      font-weight: 700;
      color: #334155;
    }
    .data-table td.col-val {
      width: 62%;
      color: #0f172a;
    }
    .appeal-card {
      border: 1.5px solid #ef4444;
      background: #fef2f2;
      padding: 10px 14px;
      border-radius: 6px;
      margin: 14px 0;
    }
    .appeal-title {
      color: #991b1b;
      font-weight: 800;
      font-size: 10pt;
      margin-bottom: 4px;
    }
    .appeal-text {
      color: #991b1b;
      font-size: 9pt;
      line-height: 1.45;
      margin-bottom: 8px;
    }
    .contact-row {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      font-size: 8.5pt;
      font-weight: 700;
    }
    .contact-pill {
      background: #ffffff;
      border: 1px solid #f87171;
      padding: 4px 10px;
      border-radius: 20px;
      color: #b91c1c;
    }
    .sig-section {
      display: flex;
      justify-content: space-between;
      margin-top: 24px;
      page-break-inside: avoid;
    }
    .sig-left {
      font-size: 8.5pt;
      color: #334155;
      line-height: 1.5;
    }
    .sig-right {
      text-align: right;
      font-size: 8.5pt;
      color: #0f172a;
      line-height: 1.45;
    }
    .sig-right .signed {
      font-weight: 800;
      font-size: 9.5pt;
      margin-bottom: 4px;
    }
    .doc-footer {
      border-top: 1px dashed #cbd5e1;
      margin-top: 16px;
      padding-top: 6px;
      font-size: 7.5pt;
      color: #64748b;
      display: flex;
      justify-content: space-between;
    }
    .dossier-sec-header {
      background: #0f172a;
      color: #ffffff;
      padding: 4px 8px;
      font-weight: 700;
      font-size: 8.5pt;
      letter-spacing: 0.5px;
      margin-top: 10px;
    }
    .security-notice {
      background: #fffbeb;
      border: 1px solid #fef3c7;
      padding: 5px 10px;
      font-size: 8pt;
      color: #92400e;
      font-style: italic;
      margin: 8px 0;
    }
    .sig-grid {
      display: flex;
      justify-content: space-between;
      margin-top: 28px;
      page-break-inside: avoid;
    }
    .sig-box-cell {
      width: 30%;
      text-align: center;
      font-size: 8.5pt;
    }
    .sig-box-line {
      border-bottom: 1.2px solid #475569;
      height: 38px;
      margin-bottom: 6px;
    }
    @media print {
      body {
        margin: 0;
      }
      .no-print {
        display: none !important;
      }
    }
  </style>
</head>
<body>
  <div class="print-doc">
    $htmlContent
  </div>
  <script>
    window.onload = function() {
      setTimeout(function() {
        window.print();
      }, 300);
    };
  </script>
</body>
</html>''';

      final blob = html.Blob([fullDoc], 'text/html;charset=utf-8');
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.window.open(url, '_blank');

      Future.delayed(const Duration(minutes: 2), () {
        html.Url.revokeObjectUrl(url);
      });
    } catch (_) {
      html.window.print();
    }
  }

  /// Generates and triggers full A4 page printing for Official Police Gazette Notice
  static void printGazetteNotice(UdbRecord record) {
    final title = 'OFFICIAL POLICE GAZETTE NOTIFICATION - GAZ-${record.referenceNo}';
    final html = '''
    <div class="header-center">
      <div style="font-weight: bold; font-size: 26px; color: #1e3a8a; margin-bottom: 4px;">🛡️ BANGLADESH POLICE CID</div>
      <div class="gov-heading-1">গণপ্রজাতন্ত্রী বাংলাদেশ সরকার</div>
      <div class="gov-heading-2">বাংলাদেশ পুলিশ • ক্রিমিনাল ইনভেস্টিগেশন ডিপার্টমেন্ট (সিআইডি)</div>
      <div class="gov-heading-3">সেন্ট্রাল ইন্টেলিজেন্স ব্যুরো (সিআইবি) • প্রধান কার্যালয়, ঢাকা</div>
      
      <div class="gazette-badge">
        বিশেষ গেজেট বিজ্ঞপ্তি: অজ্ঞাত মৃতদেহ শনাক্তকরণ বিজ্ঞপ্তি<br>
        <span style="font-size: 8.5pt; font-weight: 700;">SPECIAL POLICE GAZETTE: UNIDENTIFIED DEAD BODY IDENTIFICATION NOTICE</span>
      </div>
    </div>

    <div class="meta-box">
      <div>
        <div class="meta-ref">গেজেট রেফারেন্স / Gazette Ref: GAZ-${record.referenceNo}</div>
        <div class="meta-sub">আইনি ভিত্তি: ফৌজদারি কার্যবিধি (CrPC) ধারা ১৭৪ এবং পিআরবি প্রবিধান ২৯৯/৩০০</div>
      </div>
      <div>
        <span class="badge-pill">PUBLIC GAZETTE</span>
      </div>
    </div>

    <div class="body-intro">
      এতদ্বারা সর্বসাধারণের অবগতির জন্য জানানো যাচ্ছে যে, নিম্নবর্ণিত বিবরণ মোতাবেক একটি অজ্ঞাতনামা মৃতদেহ উদ্ধার করা হয়েছে। 
      উক্ত মৃতদেহটির পরিচয় নিশ্চিতকরণের জন্য নিম্নোক্ত শারীরিক ও পোশাকীয় বিবরণ বাংলাদেশ পুলিশ গেজেটে প্রকাশ করা হলো:
    </div>

    <table class="data-table">
      <tbody>
        <tr>
          <td class="col-label">মৃতদেহ প্রাপ্তির তারিখ ও স্থান / Date & Place Found</td>
          <td class="col-val">${record.dateFound} • ${record.placeFound}, ${record.thana}, ${record.district}</td>
        </tr>
        <tr>
          <td class="col-label">নির্দিষ্ট উদ্ধারস্থল / Coordinates & Spot</td>
          <td class="col-val">${record.locationFound}</td>
        </tr>
        <tr>
          <td class="col-label">থানা ও জিডি নং / Police Station & GD Ref</td>
          <td class="col-val">${record.thana} PS • ${record.gdCaseReference}</td>
        </tr>
        <tr>
          <td class="col-label">লিঙ্গ ও আনুমানিক বয়স / Sex & Estimated Age</td>
          <td class="col-val">${record.gender} • আনুমানিক ${record.estimatedAge} বছর (${record.ageGroup})</td>
        </tr>
        <tr>
          <td class="col-label">উচ্চতা ও ওজন / Height & Weight</td>
          <td class="col-val">${record.heightCm} সে.মি. • ${record.weightKg} কেজি</td>
        </tr>
        <tr>
          <td class="col-label">মৃতদেহের অবস্থা / Body Condition</td>
          <td class="col-val">${record.bodyCondition}</td>
        </tr>
        <tr>
          <td class="col-label">গায়ের রঙ ও চুল / Complexion & Hair</td>
          <td class="col-val">${record.complexion} • ${record.hair} • ${record.facialHair}</td>
        </tr>
        <tr>
          <td class="col-label">সনাক্তকরণ বিশেষ চিহ্ন ও ট্যাটু / Marks & Scars</td>
          <td class="col-val">${record.identificationMarks.isNotEmpty ? record.identificationMarks : 'প্রযোজ্য নয়'}</td>
        </tr>
        <tr>
          <td class="col-label">দাঁতের বিবরণ / Dental Characteristics</td>
          <td class="col-val">${record.dentalCharacteristics.isNotEmpty ? record.dentalCharacteristics : 'প্রযোজ্য নয়'}</td>
        </tr>
        <tr>
          <td class="col-label">পরনের পোশাক / Clothing Description</td>
          <td class="col-val">${record.clothing.isNotEmpty ? record.clothing : 'প্রযোজ্য নয়'}</td>
        </tr>
        <tr>
          <td class="col-label">সাথে প্রাপ্ত জিনিসপত্র / Personal Belongings</td>
          <td class="col-val">${record.personalBelongings.isNotEmpty ? record.personalBelongings : 'প্রযোজ্য নয়'}</td>
        </tr>
        <tr>
          <td class="col-label">ময়নাতদন্ত ও ডিএনএ অবস্থা / Forensic Status</td>
          <td class="col-val">ময়নাতদন্ত নং: ${record.postmortemReference} • ডিএনএ প্রোফাইল: ${record.dnaProfileAvailability}</td>
        </tr>
      </tbody>
    </table>

    <div class="appeal-card">
      <div class="appeal-title">📢 জনসাধারণের জন্য জরুরি নোটিশ / Public Appeal</div>
      <div class="appeal-text">
        যদি কোনো নাগরিক বা আত্মীয়-স্বজন উপরোক্ত শারীরিক বিবরণ, চিহ্ন বা পোশাকের ভিত্তিতে মৃত ব্যক্তিকে চিনতে পারেন, 
        তবে অবিলম্বে উদ্ধারকারী কর্মকর্তা অথবা সিআইডি সেন্ট্রাল ইন্টেলিজেন্স ব্যুরো (CIB) হেল্পলাইনে যোগাযোগ করার অনুরোধ করা হচ্ছে।
      </div>
      <div class="contact-row">
        <span class="contact-pill">📞 জাতীয় জরুরি সেবা: 999</span>
        <span class="contact-pill">☎️ সিআইডি সিআইবি হেল্পলাইন: ${AppConstants.cidHelpline}</span>
        <span class="contact-pill">✉️ ইমেইল: ${AppConstants.cidEmail}</span>
      </div>
    </div>

    <div class="sig-section">
      <div class="sig-left">
        <div><strong>গেজেট প্রকাশের তারিখ:</strong> ${record.dateFound}</div>
        <div><strong>উদ্ধারকারী কর্মকর্তা / টিম:</strong> ${record.recoveryOfficerUnit}</div>
        <div><strong>থানা সাধারণ ডায়েরি (GD):</strong> ${record.gdCaseReference}</div>
        <div><strong>ডিভিশন ও জেলা:</strong> ${record.division} • ${record.district}</div>
      </div>
      <div class="sig-right">
        <div class="signed">স্বাক্ষরিত/-</div>
        <div><strong>বিশেষ পুলিশ সুপার (সিআইবি)</strong></div>
        <div>ক্রিমিনাল ইনভেস্টিগেশন ডিপার্টমেন্ট (সিআইডি)</div>
        <div>বাংলাদেশ পুলিশ, প্রধান কার্যালয়, ঢাকা</div>
      </div>
    </div>

    <div class="doc-footer">
      <span>UDBMS BANGLADESH • Unidentified Dead Body Management System</span>
      <span>Official Government Gazette Publication • CrPC Section 174</span>
    </div>
''';

    printHtmlDocument(title: title, htmlContent: html);
  }

  /// Generates and triggers full A4 page printing for Official Police Dossier
  static void printOfficialDossier(UdbRecord record, UserSession session) {
    final title = 'OFFICIAL FORENSIC CASE DOSSIER - ${record.referenceNo}';
    final html = '''
    <div class="header-center">
      <div style="font-weight: bold; font-size: 26px; color: #1e3a8a; margin-bottom: 4px;">🛡️ BANGLADESH POLICE CID</div>
      <div class="gov-heading-1">CRIMINAL INVESTIGATION DEPARTMENT (CID)</div>
      <div class="gov-heading-2">CENTRAL INTELLIGENCE BUREAU (CIB) • BANGLADESH POLICE</div>
      <div class="gov-heading-3">National Forensic Portal for Unidentified Dead Body Identification (Interpol DVI Standards)</div>
    </div>

    <div class="meta-box" style="margin-bottom: 6px;">
      <div>
        <div class="meta-ref">CASE REFERENCE: ${record.referenceNo}</div>
        <div class="meta-sub">GD/FIR No: ${record.gdCaseReference} • Thana: ${record.thana}, ${record.district}</div>
      </div>
      <div>
        <span class="badge-pill" style="background:#e0f2fe; color:#0369a1; border-color:#7dd3fc;">STATUS: ${record.status.toUpperCase()}</span>
      </div>
    </div>

    <div class="security-notice">
      SECURITY NOTICE: Generated for official police use by [${session.rank} ${session.fullName}, BP: ${session.bpNumber}].
      Cryptographic audit fingerprint embedded. Unauthorized dissemination is punishable under Section 29 of the Police Act.
    </div>

    <div class="dossier-sec-header">1. RECOVERY & JURISDICTIONAL PARTICULARS</div>
    <table class="data-table">
      <tbody>
        <tr><td class="col-label">Discovery Date & Time</td><td class="col-val">${record.dateFound} at ${record.timeFound}</td></tr>
        <tr><td class="col-label">Recovery Spot Location</td><td class="col-val">${record.locationFound}</td></tr>
        <tr><td class="col-label">General Area / Landmark</td><td class="col-val">${record.placeFound}</td></tr>
        <tr><td class="col-label">Jurisdictional Thana & District</td><td class="col-val">${record.thana} PS, ${record.district} District (${record.division} Division)</td></tr>
        <tr><td class="col-label">Recovery Officer & Team</td><td class="col-val">${record.recoveryOfficerUnit}</td></tr>
        <tr><td class="col-label">Inquest Legal Basis</td><td class="col-val">CrPC Section 174 & PRB Regulation 299</td></tr>
      </tbody>
    </table>

    <div class="dossier-sec-header">2. ANTHROPOLOGICAL PROFILE (INTERPOL DVI PM-FORM)</div>
    <table class="data-table">
      <tbody>
        <tr><td class="col-label">Biological Sex</td><td class="col-val">${record.gender}</td></tr>
        <tr><td class="col-label">Estimated Age & Bracket</td><td class="col-val">~${record.estimatedAge} Years (${record.ageGroup})</td></tr>
        <tr><td class="col-label">Stature / Height</td><td class="col-val">${record.heightCm} cm</td></tr>
        <tr><td class="col-label">Approximate Weight</td><td class="col-val">${record.weightKg} kg</td></tr>
        <tr><td class="col-label">Body Decomposition State</td><td class="col-val">${record.bodyCondition}</td></tr>
        <tr><td class="col-label">Estimated Time Since Death</td><td class="col-val">${record.estimatedDeathTime}</td></tr>
        <tr><td class="col-label">Complexion & Tone</td><td class="col-val">${record.complexion}</td></tr>
        <tr><td class="col-label">Hair Characteristics</td><td class="col-val">${record.hair}</td></tr>
        <tr><td class="col-label">Facial Hair</td><td class="col-val">${record.facialHair}</td></tr>
      </tbody>
    </table>

    <div class="dossier-sec-header">3. IDENTIFYING MARKS, SCARS, TATTOOS & DENTAL CHARTING</div>
    <table class="data-table">
      <tbody>
        <tr><td class="col-label">Distinctive Identification Marks</td><td class="col-val">${record.identificationMarks}</td></tr>
        <tr><td class="col-label">Surgical Scars & Trauma Scars</td><td class="col-val">${record.scars}</td></tr>
        <tr><td class="col-label">Tattoos & Body Art</td><td class="col-val">${record.tattoos}</td></tr>
        <tr><td class="col-label">Dental Characteristics</td><td class="col-val">${record.dentalCharacteristics}</td></tr>
        <tr><td class="col-label">Birthmarks</td><td class="col-val">${record.birthmarks}</td></tr>
      </tbody>
    </table>

    <div class="dossier-sec-header">4. CLOTHING, FOOTWEAR & PERSONAL EFFECTS</div>
    <table class="data-table">
      <tbody>
        <tr><td class="col-label">Clothing Description</td><td class="col-val">${record.clothing}</td></tr>
        <tr><td class="col-label">Jewellery & Personal Belongings</td><td class="col-val">${record.personalBelongings}</td></tr>
      </tbody>
    </table>

    <div class="dossier-sec-header">5. FORENSIC LAB BIOMETRICS & DOCUMENT REGISTRY</div>
    <table class="data-table">
      <tbody>
        <tr><td class="col-label">AFIS 10-Print Fingerprint Status</td><td class="col-val">${record.fingerprintAvailability}</td></tr>
        <tr><td class="col-label">DNA Profile Lab Availability</td><td class="col-val">${record.dnaProfileAvailability}</td></tr>
        <tr><td class="col-label">Post-Mortem Autopsy Reference</td><td class="col-val">${record.postmortemReference}</td></tr>
        <tr><td class="col-label">Forensic Lab Reference</td><td class="col-val">${record.linkedForensicRecord}</td></tr>
      </tbody>
    </table>

    <div class="dossier-sec-header">6. INVESTIGATIVE CIRCUMSTANCES & RECOVERY SUMMARY</div>
    <div style="border: 1px solid #cbd5e1; padding: 8px 12px; font-size: 8.5pt; color: #1e293b; line-height: 1.5; margin: 6px 0;">
      ${record.description}
    </div>

    <div class="sig-grid">
      <div class="sig-box-cell">
        <div class="sig-box-line"></div>
        <div style="font-weight: bold; color: #0f172a;">Investigation Officer (IO)</div>
        <div style="color: #64748b; font-size: 7.5pt;">Sub-Inspector of Police<br>Jurisdictional Thana</div>
      </div>
      <div class="sig-box-cell">
        <div class="sig-box-line"></div>
        <div style="font-weight: bold; color: #0f172a;">Forensic Medical Examiner</div>
        <div style="color: #64748b; font-size: 7.5pt;">Medical Officer / Mortuary<br>Post-Mortem Examiner</div>
      </div>
      <div class="sig-box-cell">
        <div class="sig-box-line"></div>
        <div style="font-weight: bold; color: #0f172a;">Superintendent of Police</div>
        <div style="color: #64748b; font-size: 7.5pt;">CID Central Intelligence Bureau<br>Dhaka Headquarters</div>
      </div>
    </div>

    <div class="doc-footer">
      <span>Official Forensic Record • Bangladesh Police Criminal Investigation Department</span>
      <span>Confidential Police Dossier • Case ${record.referenceNo}</span>
    </div>
''';

    printHtmlDocument(title: title, htmlContent: html);
  }
}
