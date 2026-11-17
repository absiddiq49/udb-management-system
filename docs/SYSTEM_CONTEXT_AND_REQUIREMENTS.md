# CID Bangladesh - Unidentified Dead Body (UDB) Management System
## System Context, Requirements & International Standards Analysis

---

## 1. Executive Summary & Problem Statement
In Bangladesh and worldwide, thousands of deceased individuals are recovered every year whose identities cannot be established at the scene. Under standard police procedures (such as Section 174 of the Code of Criminal Procedure - CrPC and Police Regulations of Bengal - PRB), an inquest (*সুরতহাল*) is conducted and a post-mortem examination (*ময়নাতদন্ত*) is performed. However, due to fragmented communications between district police stations (*Thanas*), lack of a centralized digital repository, and absence of standardized cross-matching with missing persons, many bodies remain unidentified and are buried by charitable organizations (such as Anjuman Mufidul Islam) without their families ever discovering their fate.

The **CID Unidentified Dead Body Management System (UDB-MS)** is an independent, specialized web application developed for the **Criminal Investigation Department (CID), Bangladesh Police**. It provides an end-to-end digital forensic platform following international standards (Interpol DVI and US NamUs) to record, catalogue, search, cross-match, and safely share information regarding unidentified deceased individuals.

---

## 2. International Comparative Analysis: How Other Countries Manage UDBs

### A. United States: NamUs (National Missing and Unidentified Persons System)
* **Agency**: Funded and administered by the National Institute of Justice (NIJ), US Department of Justice.
* **Tiered Access Architecture**:
  * **Public Access**: Any citizen, family member, or NGO can search deceased records using demographic filters (estimated age, biological sex, height, weight, recovery date, state/county, tattoos, clothing). Graphic crime-scene and autopsy photos are strictly withheld or displayed as forensic artist reconstructions.
  * **Professional / Law Enforcement Access**: Sworn law enforcement officers, coroners, medical examiners, and forensic odontologists receive multi-factor verified credentials. They have access to full autopsy findings, toxicology reports, high-resolution dactyloscopic cards (fingerprints linked with FBI NextGen/AFIS), dental charting (Odontology), and DNA profile tracking (linked with CODIS).
  * **Automated Cross-Matching**: Continuously compares missing persons records with unidentified decedent records and notifies investigating agencies when similarity thresholds are triggered.

### B. Interpol: Disaster Victim Identification (DVI) & Black Notices
* **Standard**: Interpol Pink Form (*Post-Mortem / PM*) and Yellow Form (*Ante-Mortem / AM*).
* **Sections**:
  1. Administrative data & Place/Date of recovery.
  2. Physical description (Sex, Age estimate, Stature, Complexion, Hair, Eyes).
  3. Medical & Surgical findings (Fractures, amputations, scars, tattoos, implants).
  4. Dental charting (Odontology with FDI tooth numbering system).
  5. Clothing and personal effects (Labels, sizes, laundry tags, jewelry, pockets).
  6. Biometrics (Fingerprints / Dactyloscopy).
  7. DNA profiling and biological sample custody.
* **Black Notices**: Official international police circulars issued to seek information on unidentified bodies across borders.

### C. United Kingdom: UK Missing Persons and Unidentified Remains Unit (NCA)
* **Agency**: National Crime Agency (NCA).
* **Key Features**:
  * Public portal displays 3D facial reconstructions, sketches, and detailed clothing/possession photographs.
  * Explicit sensitivity warnings and click-to-unblur controls on real photographs.
  * Secure police officer portal for mutual inter-force case transfer and evidentiary review.

### D. India: NCRB (National Crime Records Bureau) & Zipnet / Talash
* **Key Features**:
  * Integrates *Thana* General Diary (GD) and FIR records with post-mortem mortuary intake numbers.
  * Public missing/deceased search module; restricted investigation officer module for inter-state body identification and cremation clearances.

---

## 3. Core Architectural & Policy Decisions for CID Bangladesh

### Should the System be Restricted or Open?
**The Optimal Solution is a Dual-Tier Hybrid Architecture:**
1. **Public Information Portal (Open & Accessible without Login)**:
   * **Why**: Families of missing persons and the general public need quick, barrier-free access to check if a missing relative matches an unidentified body found anywhere in Bangladesh.
   * **Information Exposed**: Reference Number, recovery date, division/district/thana, general recovery location, biological sex, estimated age bracket, height, weight, body condition, visible scars/tattoos, clothing description, personal effects (watch, ring, sandals), and contact information of the investigating police officer/thana.
   * **Information Redacted/Protected**: Highly graphic scene/autopsy imagery is blurred by default with an explicit opt-in confirmation toggle. Sensitive post-mortem internal organ pathology, confidential officer intelligence notes, raw DNA sequence strings, and confidential informant remarks are **never** exposed to the public.
   * **Public Participation Tools**:
     * **Citizen Emergency Deceased Report**: Form for citizens or first responders to report finding a body with GPS coordinates, photos, and time.
     * **Citizen Lead / Match Claim Submission**: Form for citizens to submit a tip ("I believe this is my missing brother GD #123") with contact info and photo proofs.

2. **Official Forensic & Investigation Portal (Strictly Authenticated)**:
   * **Who**: CID Forensic teams, CID Central Intelligence Bureau (CIB) officers, Thana Investigation Officers (IOs), and verified Medical Examiners.
   * **Authentication**: Multi-tier authentication with official credentials, role-based authorization, and session expiration.
   * **What Can Be Seen**:
     * High-resolution, unblurred forensic photo catalog (Face, Full Body, Marks, Dental, Belongings).
     * Complete scanned official documents: Inquest Report (*সুরতহাল*), Post-Mortem Autopsy Report (*ময়নাতদন্ত*), and Forensic DNA/Toxicology lab analysis.
     * Biometric status: 10-Print AFIS fingerprint status, DNA STR profile reference, dental records.
     * Internal case intelligence notes, suspected foul play observations, and lead tracking.
     * Ability to edit records, verify citizen reports, and mark cases as "Identified" upon formal identification.

---

## 4. How External Investigation Officers (IOs) Request Data
In Bangladesh, over 650 police stations (*Thanas*), River Police, Highway Police, Railway Police, and PBI investigate cases. An officer in a distant Thana (e.g., Teknaf or Panchagarh) might not have permanent CID super-admin credentials.

### The Formal IO Data Access Request Protocol:
1. **Request Submission**:
   * An IO accesses the portal and clicks **"Request Officer Data Access"**.
   * The IO provides:
     * Full Name, Police Rank (e.g., SI, Inspector, ASP).
     * Official Police BP ID Number (unique police badge identifier in Bangladesh).
     * Posting Unit / Thana (e.g., Ramna Model Thana, DMP).
     * Official Contact Number & Government Email.
     * Target Case / Reference (or general district access).
     * Legal Justification / Case Linkage (e.g., "Investigating Missing Person GD No. 442/26, physical description matches UDB-2026-004").
     * Upload of Official Duty Pass / GD Copy.
2. **Review & Approval by CID CIB Desk**:
   * The request enters an administrative **Access Request Queue**.
   * A CID supervisor reviews the request and verifies the BP number.
   * The supervisor approves or rejects with a reason.
   * Upon approval, a **Secure Temporary Access Token / Pass** is generated (valid for e.g., 7 days or 30 days) and dispatched to the officer's verified contact/email.
3. **Audit Logging & Security**:
   * Every view, search, and document download by the officer is logged with timestamp, BP number, and IP address.
   * Downloaded PDF reports are dynamically watermarked: `"OFFICIAL POLICE USE ONLY - ACCESSED BY BP-[NO] ON [TIMESTAMP]"`.

---

## 5. Technology Stack & Database Strategy

* **Frontend & Web Client**: **Flutter Web 3.x**
  * Modern, responsive, single-codebase web application.
  * Custom CID deep-navy and gold visual theme conforming to modern web UI/UX standards.
  * Instant reactivity, client-side caching, fluid animations, and print-ready dossier stylesheets.
  * Future-proof: Can be compiled natively for Android/iOS tablets used by Crime Scene field units without rewriting application logic.
* **Database & Persistence**:
  * **Target Production Database**: **PostgreSQL 15+** with extensions (`uuid-ossp`, `pg_trgm` for fuzzy similarity search, `pgcrypto`).
  * **Architecture Layering**: Clean Repository Pattern (`UdbRepository`). Supports in-memory & persistent local storage pre-loaded with official CID demo data, with clean REST/PostgreSQL API abstraction for seamless server migration.
* **Storage**:
  * Optimized WebP multi-resolution image pipeline (thumbnail, preview, archival) saving 75-85% storage while preserving forensic sharpness.
  * Secure document vault for PDF inquest and autopsy records with SHA-256 integrity verification.

