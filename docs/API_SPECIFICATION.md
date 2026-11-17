# REST API Specification (PostgreSQL Server Backend)
## CID Unidentified Dead Body (UDB) Management System

---

## 1. Authentication & Sessions
* `POST /api/v1/auth/login`: Authenticate CID officer with username/email and password. Returns JWT with role and BP number.
* `POST /api/v1/auth/token-login`: Authenticate external IO using one-time/temporary access pass.
* `POST /api/v1/auth/logout`: Invalidate session and log logout event.
* `GET /api/v1/auth/me`: Retrieve currently authenticated user profile and permissions.

---

## 2. Public Endpoints (No Auth Required)
* `GET /api/v1/public/cases`: Query published unidentified dead body records with filters:
  * Parameters: `keywords`, `gender`, `age_group`, `division`, `district`, `thana`, `date_from`, `date_to`, `page`, `limit`.
  * Returns: Redacted case summaries (autopsy details excluded).
* `GET /api/v1/public/cases/:reference`: Retrieve single public dossier by reference number (e.g. `CIB-UDB-2026-001`).
* `GET /api/v1/public/statistics`: KPI dashboard statistics (Total recovered, recent 90 days, identified, DNA available).
* `POST /api/v1/public/report-body`: Citizen emergency report of an unidentified found body.
* `POST /api/v1/public/submit-tip`: Citizen submission of a potential missing relative match / lead.

---

## 3. Investigation Officer Data Access Requests
* `POST /api/v1/requests/submit`: External officer submits formal data access request with BP number, unit, and GD/case basis.
* `GET /api/v1/requests/status/:requestCode`: Check status of access request.
* `GET /api/v1/admin/requests`: [Admin Only] List pending, approved, and rejected access requests.
* `POST /api/v1/admin/requests/:id/review`: [Admin Only] Approve or reject request with notes and token expiration.

---

## 4. Official & Forensic Case Management (Authorized Officers Only)
* `GET /api/v1/official/cases`: List full forensic cases including unpublished, draft, and confidential records.
* `GET /api/v1/official/cases/:reference`: Retrieve full unredacted forensic dossier with all photos, autopsy documents, and officer notes.
* `POST /api/v1/official/cases`: Create new case following Interpol DVI PM Pink Form standards.
* `PUT /api/v1/official/cases/:reference`: Update case details or update status to `Identified and closed`.
* `POST /api/v1/official/cases/:reference/photos`: Upload multi-resolution categorized forensic photos.
* `POST /api/v1/official/cases/:reference/documents`: Upload inquest, autopsy, or DNA report PDF with SHA-256 validation.
* `GET /api/v1/official/cases/:reference/export-pdf`: Generate and stream official watermarked PDF dossier.

---

## 5. Audit & Compliance
* `GET /api/v1/admin/audit-logs`: [Admin Only] Query immutable audit trail filtered by officer BP number, action, or case reference.

