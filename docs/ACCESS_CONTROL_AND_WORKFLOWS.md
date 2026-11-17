# Access Control, Workflows & Security Specification
## CID Unidentified Dead Body (UDB) Management System

---

## 1. Role-Based Access Control (RBAC) Matrix

| User Role | Description | Public Search | View Sensitive Photos | View Autopsy/Inquest Docs | Submit Tip/Lead | Report Found Body | Edit/Register Case | Manage IO Requests | Audit Logs |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Public / Citizen** | General public, relatives, NGOs | ✅ (Redacted) | ⚠️ (Opt-in Blurred) | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ |
| **External IO (Requested)** | Thana Police Officer with approved temporary token | ✅ | ✅ (Unmasked) | ✅ (Watermarked) | ✅ | ✅ | ❌ (View only) | ❌ | ❌ |
| **CID Field Officer / IO** | Assigned Crime Scene or CIB Detective | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (Assigned cases) | ❌ | 👁️ View own |
| **Forensic Medical Specialist** | Forensic Pathologist / DNA Analyst | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (Forensic fields) | ❌ | 👁️ View own |
| **CID CIB Super Admin** | Central Intelligence Bureau Supervisor | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ (All cases) | ✅ (Approve/Reject) | ✅ Full Audit |

---

## 2. Investigation Officer (IO) Access Request Lifecycle

```
[ External IO (Thana / PBI / Highway) ]
                   │
                   ▼
  Fills Formal Access Request Form
  - Name, Rank, BP Number, Unit / Thana
  - Contact Mobile & Official Email
  - Target Case Reference (or Regional)
  - Legal Basis / GD / FIR Reference
  - Upload ID Badge / GD Scan
                   │
                   ▼
  [ Database: `official_access_requests` ] (Status: PENDING)
                   │
                   ▼
  CID CIB Admin Dashboard Notification
                   │
         ┌─────────┴─────────┐
         ▼                   ▼
    [ APPROVED ]        [ REJECTED ]
         │                   │
  Token Generated     Rejection reason
  (Valid 7-30 Days)   sent via SMS/Email
  Dispatched to IO           │
         │                [ END ]
         ▼
  IO logs in via Token / Official Pass
  - Gains immediate access to targeted dossier
  - Downloads watermarked autopsy/inquest docs
  - All actions logged in `audit_logs`
```

---

## 3. Citizen Reporting & Lead Workflow

### A. Reporting an Unidentified Found Body
* **Who Can Report**: Any citizen, local village council member (*Union Parishad*), first responder, or local volunteer.
* **Fields Captured**:
  * Date and Time of discovery.
  * Location (Division, District, Thana, specific spot, landmark, optional GPS coordinates).
  * Apparent physical traits (Sex, estimated age bracket, clothing, visible marks).
  * Photos (Scene/Body photos uploaded from phone camera/gallery).
  * Informant Details (Name, Phone Number, National ID/NID optional, relationship to discovery).
* **System Action**:
  * Record created in `citizen_reports` with status `NEW_REPORT`.
  * Emergency alert notification pushed to CID CIB Intake desk and designated Thana liaison.
  * CID officer verifies the report. Upon verification, the officer can convert the citizen report directly into an official active case (`unidentified_dead_bodies`).

### B. Submitting a Match Tip (Lead for Missing Relative)
* **Who Can Submit**: A family member or friend searching for a missing loved one.
* **Fields Captured**:
  * Target Unidentified Body Reference (e.g., `CIB-UDB-2026-001`).
  * Missing Person Name & General Diary (GD) / FIR Number.
  * Police Station where GD was filed.
  * Distinctive matching features identified by the claimant (e.g., "The scar on the right eyebrow matches my missing brother").
  * Claimant contact information, relation, and photo of the missing person.
* **System Action**:
  * Record logged in `citizen_tips_matches` linked to the case.
  * Case status updated to `Unidentified - under verification` or flagged with `Active Citizen Lead`.
  * CID Investigation Officer reviews the lead and can schedule a formal biometric/DNA comparison with the family member.

---

## 4. Respectful Sensitive Media Guard Policy

Forensic imagery of deceased individuals can be traumatic for the general public and disrespectful to the deceased if handled carelessly.
* **Default State**: In public view, all photographic evidence is masked with a frosted glass blur (`backdrop-filter: blur(16px)` / `ImageFilter.blur`).
* **Warning Card**: The image displays a clear amber/neutral warning badge:
  > **Sensitive Content Warning**
  > *This image contains forensic photographic documentation for identification purposes only. Click to reveal.*
* **Unmasking Mechanism**: The viewer must explicitly click "Reveal Image" or toggle "Show Sensitive Content".
* **Watermarking**: High-resolution downloads in official portal embed cryptographic watermarks including viewing officer's credentials, preventing unauthorized leakage to social media or press.

