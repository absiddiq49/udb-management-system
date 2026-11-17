# CID Bangladesh - Unidentified Dead Body (UDB) Management System
### Interpol DVI & NamUs Compliant Forensic Portal for Deceased Identification & Cross-Matching

[![Flutter Web](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter)](https://flutter.dev)
[![PostgreSQL Ready](https://img.shields.io/badge/PostgreSQL-14%2B-336791?logo=postgresql)](https://www.postgresql.org)
[![Compliance](https://img.shields.io/badge/Standard-Interpol%20DVI%20%7C%20NamUs-D4AF37)](#)

---

## 1. System Overview
The **CID Unidentified Dead Body Management System (UDB-MS)** is a dedicated, production-ready web application designed for the **Criminal Investigation Department (CID), Bangladesh Police**. It replaces legacy fragmented records with a modern, responsive, and secure digital platform modeled after international gold standards:
* **Interpol Disaster Victim Identification (DVI)**: Post-Mortem (Pink Form) and Ante-Mortem (Yellow Form) protocols.
* **United States NamUs (National Missing and Unidentified Persons System)**: Tiered public vs law enforcement access and automated similarity cross-matching.
* **Bangladesh Legal Compliance**: Code of Criminal Procedure (CrPC) Section 174 on Police Inquests and Police Regulations of Bengal (PRB).

---

## 2. Core Functional Modules

### A. Public Citizen & Relative Portal (Open & Barrier-Free)
* **Deceased Search & Advanced Filters**: Search over 24+ pre-loaded Bangladesh CID deceased cases using division, district, thana, gender, estimated age bracket, height, weight, status, and keywords (marks, scars, tattoos, clothing).
* **Respectful Sensitive Media Guard**:
  * Graphic forensic crime scene and autopsy photos are blurred by default (`ImageFilter.blur`).
  * Explicit amber warning card requires user opt-in before viewing for identification purposes.
  * One-click global "Blur: ON / OFF" toggle on the top navigation bar.
* **Citizen Emergency Found-Body Reporting**:
  * Instant intake form for citizens, first responders, and local councils (*Union Parishad*) to report human remains.
  * Dispatches alert directly to CID Central Intelligence Bureau (CIB) and the local Police Station (*Thana*).
  * Generates an emergency tracking code (`CIT-REP-2026-XXXX`).
* **Family / Informant Match Claim (Tip Submission)**:
  * Relatives searching for missing loved ones can submit identification leads directly on any deceased dossier.
  * Links missing person General Diary (GD) or FIR number and contact details for official follow-up.

### B. Investigation Officer (IO) Access Request System
* Designed for external police officers (Thana Sub-Inspectors, Officers-in-Charge, PBI, Highway, Railway, and River Police) who need restricted forensic data without having permanent CID super-admin credentials.
* **Submission**: Officer submits Name, Rank, BP Number (Bangladesh Police ID), Posting Unit/Thana, Official Email/Phone, Target Case Reference, Active Investigation GD/FIR reference, and Legal Justification.
* **Review Queue**: CID CIB administrators approve or reject requests from the Official Dashboard.
* **Token Dispatch**: Upon approval, a secure temporary access pass (e.g. `CID-PASS-7849-KM`) is generated, granting temporary clearance.
* **Watermarked Integrity**: High-resolution downloads in official portal embed cryptographic watermarks including viewing officer's credentials, preventing unauthorized leakage to social media or press.

### C. Official Forensic Dossier & Management Console
* **7-Section Interpol DVI Structure**:
  1. Administrative & Recovery Particulars (Jurisdiction, Recovery Officer, Spot coordinates).
  2. Anthropological Profile (Biological sex, Estimated age bracket, Height, Weight, PMI).
  3. Identifying Marks, Scars, Tattoos & Dental Charting.
  4. Clothing, Apparel & Personal Effects.
  5. Biometric AFIS (10-Print Fingerprint) & DNA Laboratory Profiling Status.
  6. Detailed Investigative Circumstances & Cause of Death Narrative.
  7. Confidential Officer Remarks & Suspect Lead Tracking.
* **Document Vault with SHA-256 Hashes**:
  * Inquest Report (*সুরতহাল প্রতিবেদন*)
  * Post-Mortem Autopsy Report (*ময়নাতদন্ত প্রতিবেদন*)
  * CID Forensic DNA & Toxicology Lab Report

### D. Automated Ante-Mortem vs Post-Mortem Cross-Matching Engine
* Implements a 5-vector similarity algorithm:
  * **Biological Sex**: 30 points
  * **Age Proximity**: Up to 25 points
  * **Height / Stature**: Up to 20 points
  * **Jurisdiction / District**: Up to 10 points
  * **Marks & Clothing Keywords**: Up to 15 points
* Ranks matching candidates with transparent alignment reasons (e.g., "95% Match: Biological sex aligns, Age within ±0 yrs, Height within ±0 cm, Recovered in Dhaka, 2 distinctive keywords matched").

---

## 3. Technology Stack & Database Strategy

| Layer | Technology | Details |
| :--- | :--- | :--- |
| **Frontend Framework** | **Flutter Web 3.x** | Single-codebase, Material 3, Responsive (Desktop/Tablet/Mobile) |
| **Theme & UI** | Custom CID Police Dark Navy | Navy `#0A192F`, Gold `#D4AF37`, Emerald `#10B981`, Red `#EF4444` |
| **State Management** | `Provider` (ChangeNotifier) | Reactive filtering, auth sessions, and request queues |
| **Production Database** | **PostgreSQL 14+** | DDL script in `database/schema.sql` with `uuid-ossp`, `pg_trgm`, `btree_gist` |
| **API Contract** | REST API Specification | Documented in `docs/API_SPECIFICATION.md` |

---

## 4. Documentation Index

1. [`docs/SYSTEM_CONTEXT_AND_REQUIREMENTS.md`](file:///Users/POLIIN/StudioProjects/Unidentyfied%20Dead%20Body%20/docs/SYSTEM_CONTEXT_AND_REQUIREMENTS.md): Background, PRB/CrPC legal mandate, international comparisons (NamUs, Interpol DVI, NCRB Talash), and system objectives.
2. [`docs/ACCESS_CONTROL_AND_WORKFLOWS.md`](file:///Users/POLIIN/StudioProjects/Unidentyfied%20Dead%20Body%20/docs/ACCESS_CONTROL_AND_WORKFLOWS.md): Role-Based Access Control matrix (Tiers 0–5), IO Data Access Request lifecycle, Citizen reporting flow, and sensitive media guard policy.
3. [`docs/DATABASE_SCHEMA_POSTGRESQL.md`](file:///Users/POLIIN/StudioProjects/Unidentyfied%20Dead%20Body%20/docs/DATABASE_SCHEMA_POSTGRESQL.md) & [`database/schema.sql`](file:///Users/POLIIN/StudioProjects/Unidentyfied%20Dead%20Body%20/database/schema.sql): Production PostgreSQL DDL schema with tables, enums, triggers, and trigram indices.
4. [`docs/API_SPECIFICATION.md`](file:///Users/POLIIN/StudioProjects/Unidentyfied%20Dead%20Body%20/docs/API_SPECIFICATION.md): Complete REST API endpoints for server deployment.

---

## 5. Quick Testing & Reviewer Credentials

The application includes pre-configured credentials for quick evaluation:

| User Type | Username / Token | Password | Access Scope |
| :--- | :--- | :--- | :--- |
| **CIB Super Admin** | `cib_supervisor` | `police123` | Full access to all dossiers, IO request approvals, and audit |
| **Forensic DNA Expert** | `forensic_expert` | `police123` | Forensic case records, lab notes, DNA & autopsy uploads |
| **Thana Assigned IO** | `officer_paltan` | `police123` | Assigned district cases and investigative entries |
| **External IO (Token Pass)** | `CID-PASS-7849-KM` | *(Token Login)* | Temporary clearance granted to SI Kamal Hossain (Ramna PS) |

---

## 6. How to Run Locally

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit tests
flutter test

# 3. Run development web server
flutter run -d chrome

# 4. Or build production web bundle
flutter build web --release
```
