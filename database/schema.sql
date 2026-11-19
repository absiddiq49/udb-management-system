-- ====================================================================
-- CID BANGLADESH - UNIDENTIFIED DEAD BODY MANAGEMENT SYSTEM (UDBMS)
-- PostgreSQL Database DDL Initialization Script with BetterAuth
-- ====================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";
CREATE EXTENSION IF NOT EXISTS "pg_trgm";

-- --------------------------------------------------------------------
-- 1. ENUMS FOR POLICE PROCEDURES & FORENSIC STATUS
-- --------------------------------------------------------------------
DO $$ BEGIN
    CREATE TYPE user_role_enum AS ENUM (
        'citizen', 'external_io', 'forensic_expert', 'cid_officer', 'cib_admin', 'super_admin'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE gender_enum AS ENUM ('Male', 'Female', 'Transgender', 'Unknown');
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE body_condition_enum AS ENUM (
        'Recoverable visual features', 'Decomposed', 'Advanced decomposition',
        'Skeletal remains', 'Charred / Burned', 'Mutilated', 'Dismembered', 'Floater / Water immersed'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE case_status_enum AS ENUM (
        'Unidentified - new entry', 'Unidentified - active matching',
        'Unidentified - under verification', 'Unidentified - DNA profile stored',
        'Pending forensic confirmation', 'Probable match found', 'Identified and closed', 'Archived'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE request_status_enum AS ENUM (
        'pending', 'approved', 'rejected', 'expired', 'revoked'
    );
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- --------------------------------------------------------------------
-- 2. BETTER-AUTH INTEGRATION TABLES (Tiered Clearance)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS "user" (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    image TEXT,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    role VARCHAR(50) DEFAULT 'citizen',
    tier INTEGER NOT NULL DEFAULT 0,
    "bpNumber" VARCHAR(50),
    rank VARCHAR(100),
    designation VARCHAR(150),
    "unitThana" VARCHAR(150),
    "phoneNumber" VARCHAR(50),
    "isActive" BOOLEAN NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS "session" (
    id TEXT PRIMARY KEY,
    "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
    token TEXT NOT NULL UNIQUE,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "userId" TEXT NOT NULL REFERENCES "user"(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS "account" (
    id TEXT PRIMARY KEY,
    "accountId" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "userId" TEXT NOT NULL REFERENCES "user"(id) ON DELETE CASCADE,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "idToken" TEXT,
    "accessTokenExpiresAt" TIMESTAMP WITH TIME ZONE,
    "refreshTokenExpiresAt" TIMESTAMP WITH TIME ZONE,
    scope TEXT,
    password TEXT,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS "verification" (
    id TEXT PRIMARY KEY,
    identifier TEXT NOT NULL,
    value TEXT NOT NULL,
    "expiresAt" TIMESTAMP WITH TIME ZONE NOT NULL,
    "createdAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Legacy compatibility table view
CREATE OR REPLACE VIEW users AS
    SELECT id, email as username, email, "name" as full_name, designation, rank, "bpNumber" as bp_number,
           "unitThana" as unit_thana, "phoneNumber" as phone_number, role, tier, "isActive" as is_active,
           "createdAt" as created_at, "updatedAt" as updated_at
    FROM "user";

-- --------------------------------------------------------------------
-- 3. OFFICIAL ACCESS REQUESTS (External IO Inquest Access)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS official_access_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    request_code VARCHAR(30) UNIQUE NOT NULL,
    officer_name VARCHAR(150) NOT NULL,
    officer_rank VARCHAR(100) NOT NULL,
    bp_number VARCHAR(50) NOT NULL,
    posting_unit VARCHAR(150) NOT NULL,
    contact_phone VARCHAR(30) NOT NULL,
    official_email VARCHAR(255) NOT NULL,
    case_target_reference VARCHAR(100),
    investigation_gd_fir VARCHAR(255) NOT NULL,
    investigation_thana VARCHAR(150) NOT NULL,
    reason_for_access TEXT NOT NULL,
    badge_attachment_url TEXT,
    gd_attachment_url TEXT,
    status request_status_enum NOT NULL DEFAULT 'pending',
    review_notes TEXT,
    reviewed_by TEXT REFERENCES "user"(id) ON DELETE SET NULL,
    reviewed_at TIMESTAMP WITH TIME ZONE,
    access_token VARCHAR(255),
    token_expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------------------
-- 4. UNIDENTIFIED DEAD BODIES (Central Inquest & Physical Registry)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS unidentified_dead_bodies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reference_no VARCHAR(50) UNIQUE NOT NULL,
    source VARCHAR(150) DEFAULT 'Central Intelligence Bureau (CIB)',
    input_team VARCHAR(150) DEFAULT 'CID Forensics',
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
    gender gender_enum NOT NULL DEFAULT 'Unknown',
    estimated_age SMALLINT,
    age_group VARCHAR(30),
    height_cm SMALLINT,
    weight_kg SMALLINT,
    body_condition body_condition_enum NOT NULL DEFAULT 'Recoverable visual features',
    estimated_death_interval VARCHAR(100),
    complexion VARCHAR(50),
    hair VARCHAR(100),
    facial_hair VARCHAR(100),
    eye_color VARCHAR(50),
    identification_marks TEXT,
    scars TEXT,
    tattoos TEXT,
    birthmarks TEXT,
    dental_characteristics TEXT,
    other_physical_characteristics TEXT,
    clothing_description TEXT,
    personal_belongings TEXT,
    footwear_description TEXT,
    jewelry_valuables TEXT,
    fingerprint_availability VARCHAR(100) DEFAULT 'Fingerprint unavailable',
    afis_fingerprint_id VARCHAR(100),
    dna_profile_availability VARCHAR(100) DEFAULT 'DNA sample pending',
    dna_lab_reference VARCHAR(100),
    postmortem_reference VARCHAR(100),
    inquest_reference VARCHAR(100),
    anjuman_burial_ref VARCHAR(100),
    case_narrative TEXT,
    confidential_officer_remarks TEXT,
    status case_status_enum NOT NULL DEFAULT 'Unidentified - new entry',
    is_public_published BOOLEAN NOT NULL DEFAULT true,
    is_sensitive_media_restricted BOOLEAN NOT NULL DEFAULT true,
    identified_full_name VARCHAR(150),
    identified_national_id VARCHAR(50),
    identified_at TIMESTAMP WITH TIME ZONE,
    created_by TEXT REFERENCES "user"(id) ON DELETE SET NULL,
    updated_by TEXT REFERENCES "user"(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------------------
-- 5. FORENSIC PHOTOS
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS forensic_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    body_id UUID NOT NULL REFERENCES unidentified_dead_bodies(id) ON DELETE CASCADE,
    photo_category VARCHAR(50) NOT NULL,
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

-- --------------------------------------------------------------------
-- 6. FORENSIC DOCUMENTS (Autopsy, Viscera & Inquest PDFs)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS forensic_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    body_id UUID NOT NULL REFERENCES unidentified_dead_bodies(id) ON DELETE CASCADE,
    document_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    reference_number VARCHAR(100),
    issuing_authority VARCHAR(200),
    file_url TEXT NOT NULL,
    file_name VARCHAR(255),
    file_size_bytes BIGINT,
    sha256_hash VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------------------
-- 7. CITIZEN SIGHTING & EMERGENCY INTAKE REPORTS
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS citizen_reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    report_reference VARCHAR(30) UNIQUE NOT NULL,
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

-- --------------------------------------------------------------------
-- 8. CITIZEN TIPS & RELATIVE MATCH CLAIMS
-- --------------------------------------------------------------------
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

-- --------------------------------------------------------------------
-- 9. CRYPTOGRAPHIC AUDIT LOGS (Tier 5 Compliance)
-- --------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT REFERENCES "user"(id) ON DELETE SET NULL,
    bp_number VARCHAR(50),
    action VARCHAR(100) NOT NULL,
    entity_type VARCHAR(100),
    entity_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- --------------------------------------------------------------------
-- 10. OPTIMIZED SEARCH & GIN TRIGRAM INDEXES
-- --------------------------------------------------------------------
CREATE INDEX IF NOT EXISTS idx_udb_division_district_thana ON unidentified_dead_bodies(division, district, thana);
CREATE INDEX IF NOT EXISTS idx_udb_date_found ON unidentified_dead_bodies(date_found DESC);
CREATE INDEX IF NOT EXISTS idx_udb_gender_age ON unidentified_dead_bodies(gender, age_group);
CREATE INDEX IF NOT EXISTS idx_udb_status ON unidentified_dead_bodies(status);
CREATE INDEX IF NOT EXISTS idx_udb_input_team ON unidentified_dead_bodies(input_team);
CREATE INDEX IF NOT EXISTS idx_udb_marks_trgm ON unidentified_dead_bodies USING gin (identification_marks gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_udb_tattoos_trgm ON unidentified_dead_bodies USING gin (tattoos gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_udb_clothing_trgm ON unidentified_dead_bodies USING gin (clothing_description gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_udb_ref_trgm ON unidentified_dead_bodies USING gin (reference_no gin_trgm_ops);
CREATE INDEX IF NOT EXISTS idx_audit_user_action ON audit_logs(user_id, action, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_session_token ON "session"(token);
CREATE INDEX IF NOT EXISTS idx_account_user ON "account"("userId");
