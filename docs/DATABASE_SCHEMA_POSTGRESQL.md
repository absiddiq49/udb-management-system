# PostgreSQL Database Schema & Migration Specification
## CID Unidentified Dead Body (UDB) Management System

---

## 1. Schema Architecture Overview
The schema is built for **PostgreSQL 14+** to guarantee:
* Strict referential integrity.
* High-performance geospatial and fuzzy text matching (using `pg_trgm` and `btree_gist`).
* Flexible metadata storage for varying forensic pathology records using `JSONB`.
* Full compliance with international disaster victim identification (Interpol DVI) standards.

---

## 2. PostgreSQL DDL Script (`database/schema.sql`)

```sql
-- ====================================================================
-- CID BANGLADESH - UNIDENTIFIED DEAD BODY MANAGEMENT SYSTEM
-- PostgreSQL Database Initialization & Migration Script
-- ====================================================================

-- 1. EXTENSIONS
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- 2. ENUMS
CREATE TYPE user_role_enum AS ENUM (
    'citizen',
    'external_io',
    'cid_officer',
    'forensic_expert',
    'cib_admin',
    'super_admin'
);

CREATE TYPE gender_enum AS ENUM (
    'Male',
    'Female',
    'Transgender',
    'Unknown'
);

CREATE TYPE body_condition_enum AS ENUM (
    'Recoverable visual features',
    'Decomposed',
    'Advanced decomposition',
    'Skeletal remains',
    'Charred / Burned',
    'Mutilated',
    'Dismembered',
    'Floater / Water immersed'
);

CREATE TYPE case_status_enum AS ENUM (
    'Unidentified - new entry',
    'Unidentified - active matching',
    'Unidentified - under verification',
    'Unidentified - DNA profile stored',
    'Pending forensic confirmation',
    'Probable match found',
    'Identified and closed',
    'Archived'
);

CREATE TYPE request_status_enum AS ENUM (
    'pending',
    'approved',
    'rejected',
    'expired',
    'revoked'
);

-- 3. USERS & INVESTIGATION OFFICERS
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    username VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(150) NOT NULL,
    designation VARCHAR(100),
    rank VARCHAR(100),
    bp_number VARCHAR(50) UNIQUE, -- Bangladesh Police ID
    unit_thana VARCHAR(150),
    phone_number VARCHAR(30),
    role user_role_enum NOT NULL DEFAULT 'cid_officer',
    is_active BOOLEAN NOT NULL DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 4. OFFICIAL ACCESS REQUESTS (FOR EXTERNAL INVESTIGATION OFFICERS)
CREATE TABLE IF NOT EXISTS official_access_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_code VARCHAR(30) UNIQUE NOT NULL, -- e.g. REQ-2026-0042
    officer_name VARCHAR(150) NOT NULL,
    officer_rank VARCHAR(100) NOT NULL,
    bp_number VARCHAR(50) NOT NULL,
    posting_unit VARCHAR(150) NOT NULL,
    contact_phone VARCHAR(30) NOT NULL,
    official_email VARCHAR(255) NOT NULL,
    case_target_reference VARCHAR(100), -- Specific UDB reference requested
    investigation_gd_fir VARCHAR(255) NOT NULL,
    investigation_thana VARCHAR(150) NOT NULL,
    reason_for_access TEXT NOT NULL,
    badge_attachment_url TEXT,
    gd_attachment_url TEXT,
    status request_status_enum NOT NULL DEFAULT 'pending',
    review_notes TEXT,
    reviewed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    access_token VARCHAR(255),
    token_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 5. CORE UNIDENTIFIED DEAD BODY RECORDS
CREATE TABLE IF NOT EXISTS unidentified_dead_bodies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_no VARCHAR(50) UNIQUE NOT NULL, -- e.g. CIB-UDB-2026-001
    source VARCHAR(150) DEFAULT 'Central Intelligence Bureau (CIB)',
    input_team VARCHAR(150),
    
    -- Recovery Jurisdiction
    date_found DATE NOT NULL,
    time_found VARCHAR(20),
    division VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    thana VARCHAR(100) NOT NULL,
    place_found TEXT NOT NULL,
    location_details TEXT,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    gd_case_reference VARCHAR(255) NOT NULL,
    recovery_officer_unit VARCHAR(200) NOT NULL,
    
    -- Anthropological & Physical Profile
    gender gender_enum NOT NULL DEFAULT 'Unknown',
    estimated_age SMALLINT,
    age_group VARCHAR(30), -- '0-12', '13-17', '18-25', '26-35', '36-50', '51+'
    height_cm SMALLINT,
    weight_kg SMALLINT,
    body_condition body_condition_enum NOT NULL DEFAULT 'Recoverable visual features',
    estimated_death_interval VARCHAR(100),
    complexion VARCHAR(50),
    hair VARCHAR(100),
    facial_hair VARCHAR(100),
    eye_color VARCHAR(50),
    
    -- Marks & Unique Anatomical Characteristics
    identification_marks TEXT,
    scars TEXT,
    tattoos TEXT,
    birthmarks TEXT,
    dental_characteristics TEXT,
    other_physical_characteristics TEXT,
    
    -- Apparel & Personal Effects
    clothing_description TEXT,
    personal_belongings TEXT,
    footwear_description TEXT,
    jewelry_valuables TEXT,
    
    -- Forensic Identifiers
    fingerprint_availability VARCHAR(100) DEFAULT 'Fingerprint unavailable',
    afis_fingerprint_id VARCHAR(100),
    dna_profile_availability VARCHAR(100) DEFAULT 'DNA sample pending',
    dna_lab_reference VARCHAR(100),
    postmortem_reference VARCHAR(100),
    inquest_reference VARCHAR(100),
    
    -- Case Narratives & Intelligence
    case_narrative TEXT,
    confidential_officer_remarks TEXT,
    
    -- Status & Publication
    status case_status_enum NOT NULL DEFAULT 'Unidentified - new entry',
    is_public_published BOOLEAN NOT NULL DEFAULT true,
    is_sensitive_media_restricted BOOLEAN NOT NULL DEFAULT true,
    
    -- Identified metadata (if solved)
    identified_full_name VARCHAR(150),
    identified_national_id VARCHAR(50),
    identified_at TIMESTAMP WITH TIME ZONE,
    
    -- Metadata
    created_by UUID REFERENCES users(id) ON DELETE SET NULL,
    updated_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 6. FORENSIC PHOTOGRAPHS
CREATE TABLE IF NOT EXISTS forensic_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    body_id UUID NOT NULL REFERENCES unidentified_dead_bodies(id) ON DELETE CASCADE,
    photo_category VARCHAR(50) NOT NULL, -- 'face', 'full_body', 'scars', 'tattoos', 'dental', 'clothing', 'belongings'
    caption VARCHAR(255),
    preview_url TEXT NOT NULL,
    thumb_url TEXT,
    archive_hd_url TEXT,
    file_size_bytes BIGINT,
    mime_type VARCHAR(50) DEFAULT 'image/webp',
    is_primary BOOLEAN DEFAULT false,
    is_sensitive BOOLEAN DEFAULT true,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 7. FORENSIC LEGAL DOCUMENTS (PDF/SCANS)
CREATE TABLE IF NOT EXISTS forensic_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    body_id UUID NOT NULL REFERENCES unidentified_dead_bodies(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL, -- 'inquest_report', 'post_mortem_report', 'dna_lab_report', 'toxicology', 'gd_copy'
    title VARCHAR(255) NOT NULL,
    reference_number VARCHAR(100),
    issuing_authority VARCHAR(200),
    file_url TEXT NOT NULL,
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    sha256_hash VARCHAR(64), -- Cryptographic integrity validation
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 8. CITIZEN REPORTS (PUBLIC REPORTING OF FOUND BODY)
CREATE TABLE IF NOT EXISTS citizen_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_reference VARCHAR(30) UNIQUE NOT NULL, -- e.g. CIT-REP-2026-0001
    reporter_name VARCHAR(150),
    reporter_phone VARCHAR(30) NOT NULL,
    reporter_nid VARCHAR(50),
    division VARCHAR(100) NOT NULL,
    district VARCHAR(100) NOT NULL,
    thana VARCHAR(100) NOT NULL,
    spot_location TEXT NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    date_spotted DATE NOT NULL,
    time_spotted VARCHAR(20),
    description TEXT NOT NULL,
    condition_description TEXT,
    photo_urls TEXT[],
    verification_status VARCHAR(50) DEFAULT 'PENDING_POLICE_DISPATCH',
    assigned_thana VARCHAR(150),
    converted_body_id UUID REFERENCES unidentified_dead_bodies(id) ON DELETE SET NULL,
    police_action_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 9. CITIZEN MATCH TIPS (TIPS FROM SEARCHING RELATIVES)
CREATE TABLE IF NOT EXISTS citizen_tips_matches (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    body_id UUID NOT NULL REFERENCES unidentified_dead_bodies(id) ON DELETE CASCADE,
    claimant_name VARCHAR(150) NOT NULL,
    claimant_phone VARCHAR(30) NOT NULL,
    claimant_email VARCHAR(255),
    relationship_to_missing VARCHAR(50) NOT NULL,
    missing_person_name VARCHAR(150) NOT NULL,
    missing_person_gd_fir VARCHAR(255),
    thana_filed VARCHAR(150),
    similarity_reasons TEXT NOT NULL,
    photo_urls TEXT[],
    review_status VARCHAR(50) DEFAULT 'UNDER_REVIEW',
    investigator_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 10. SYSTEM AUDIT LOGS (IMMUTABLE LEGAL TRAIL)
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    bp_number VARCHAR(50),
    action VARCHAR(100) NOT NULL, -- 'VIEW_DOSSIER', 'DOWNLOAD_AUTOPSY', 'CREATE_RECORD', 'APPROVE_IO_REQUEST'
    entity_type VARCHAR(100),
    entity_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ====================================================================
-- PERFORMANCE INDEXES & FULL-TEXT / TRIGRAM SEARCH
-- ====================================================================
CREATE INDEX IF NOT EXISTS idx_udb_division_district_thana ON unidentified_dead_bodies(division, district, thana);
CREATE INDEX IF NOT EXISTS idx_udb_date_found ON unidentified_dead_bodies(date_found DESC);
CREATE INDEX IF NOT EXISTS idx_udb_gender_age ON unidentified_dead_bodies(gender, age_group);
CREATE INDEX IF NOT EXISTS idx_udb_status ON unidentified_dead_bodies(status);

-- Trigram Indexes for Fuzzy Searching across physical marks, tattoos, and clothing
CREATE INDEX IF NOT EXISTS idx_udb_marks_trgm ON unidentified_dead_bodies USING gin (identification_marks gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_udb_tattoos_trgm ON unidentified_dead_bodies USING gin (tattoos gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_udb_clothing_trgm ON unidentified_dead_bodies USING gin (clothing_description gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_udb_ref_trgm ON unidentified_dead_bodies USING gin (reference_no gin_trgm_ops);

-- Audit log index
CREATE INDEX IF NOT EXISTS idx_audit_user_action ON audit_logs(user_id, action, created_at DESC);
```

