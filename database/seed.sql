-- ====================================================================
-- CID BANGLADESH - UNIDENTIFIED DEAD BODY MANAGEMENT SYSTEM (UDBMS)
-- PostgreSQL Initial Mock / Fake Data Seed Script
-- ====================================================================

-- 1. BETTER-AUTH USER ACCOUNTS (Tiered Authentication)
-- Password for all demo accounts: 'police123' (SHA-256 hashed)
INSERT INTO "user" (
    id, name, email, email_verified, tier, role, bp_number, rank, designation, unit_thana, phone_number, is_active, created_at, updated_at
) VALUES 
('user_admin_001', 'SP M. A. Rahman', 'cib.admin@police.gov.bd', true, 5, 'cib_admin', 'BP-759812401', 'Superintendent of Police (SP)', 'Special Superintendent of Police', 'Central Intelligence Bureau (CIB), CID HQ Dhaka', '+8801713374001', true, NOW(), NOW()),
('user_cid_002', 'Inspector Farhana Yasmin', 'farhana.cid@police.gov.bd', true, 3, 'cid_officer', 'BP-821940192', 'Police Inspector (CID)', 'Case Intake & Biometrics Officer', 'CID Forensic Hub Malibagh, Dhaka', '+8801713374052', true, NOW(), NOW()),
('user_forensic_003', 'Dr. Nusrat Jahan', 'nusrat.dna@cid.gov.bd', true, 2, 'forensic_expert', 'BP-901248102', 'Assistant Director (Forensics)', 'Forensic DNA Specialist & Pathologist', 'National Forensic DNA Profiling Laboratory, CID Dhaka', '+8801713374088', true, NOW(), NOW()),
('user_io_004', 'SI Md. Nazrul Islam', 'nazrul.si@dmp.gov.bd', true, 1, 'external_io', 'BP-8812049182', 'Sub-Inspector (SI)', 'Investigating Officer (IO)', 'Paltan Model Thana, DMP Dhaka', '+8801713374211', true, NOW(), NOW()),
('user_citizen_005', 'Rafiqul Hassan (Citizen)', 'citizen.rafiq@gmail.com', true, 0, 'citizen', 'N/A', 'Citizen Portal User', 'Public Member', 'Dhaka Sadar', '+8801819920192', true, NOW(), NOW())
ON CONFLICT (email) DO NOTHING;

-- Account credential credentials
INSERT INTO "account" (
    id, user_id, account_id, provider_id, password, created_at, updated_at
) VALUES
('acc_001', 'user_admin_001', 'cib.admin@police.gov.bd', 'credential', '0b91cb4cf39e4e69b5976b9e84711689255ec379207e3ea8536f73117469a489', NOW(), NOW()),
('acc_002', 'user_cid_002', 'farhana.cid@police.gov.bd', 'credential', '0b91cb4cf39e4e69b5976b9e84711689255ec379207e3ea8536f73117469a489', NOW(), NOW()),
('acc_003', 'user_forensic_003', 'nusrat.dna@cid.gov.bd', 'credential', '0b91cb4cf39e4e69b5976b9e84711689255ec379207e3ea8536f73117469a489', NOW(), NOW()),
('acc_004', 'user_io_004', 'nazrul.si@dmp.gov.bd', 'credential', '0b91cb4cf39e4e69b5976b9e84711689255ec379207e3ea8536f73117469a489', NOW(), NOW())
ON CONFLICT (provider_id, account_id) DO NOTHING;

-- 2. UNIDENTIFIED DECEASED RECORDS (All 8 Divisions of Bangladesh)
INSERT INTO unidentified_dead_bodies (
    case_reference_no, source_portal, input_team, recovery_date, recovery_time,
    recovery_location, police_jurisdiction_thana, district, division,
    crpc_inquest_no, thana_gd_no, estimated_age_min, estimated_age_max, age_group,
    gender, height_cm, complexion, body_condition, status, clothing_worn,
    physical_marks, tattoos, dental_features, belongings_found, autopsy_summary,
    dna_profile_ref, afis_fingerprint_status, burial_reference,
    recovery_officer_name, recovery_officer_rank, recovery_officer_bp,
    recovery_officer_unit, recovery_officer_phone, assigned_forensic_expert,
    gis_latitude, gis_longitude, created_at, updated_at
) VALUES
(
    'UDB-2026-DHK-0012', 'CID-UDBMS-HQ', 'CID Homicide & Forensics Squad', '2026-10-14', '06:45:00',
    'Under Sadarghat Lalkuthi Pontoon, Buriganga River Shore', 'Kotwali Thana', 'Dhaka', 'Dhaka',
    'CrPC-174/Kotwali-2026/89', 'GD No. 1142 dated 14-Oct-2026', 30, 35, '30-40',
    'Male', 168.0, 'Wheatish / Brown', 'Recoverable visual features', 'Unidentified - active matching',
    'Black full-sleeve polyester jacket over navy blue t-shirt, beige denim jeans with brown synthetic belt',
    'Deep crescent scar on right forehead (approx 3.5cm); circular black mole behind left earlobe',
    'Faint anchor symbol inked in blue pigment on upper right forearm',
    'Missing lower right second premolar; distinct gold crown on upper left canine',
    'Stainless steel digital wristwatch (water-damaged), metal safety pin, folded laminated medical receipt from Sir Salimullah Medical College',
    'Asphyxia resulting from drowning in polluted river waters. No ante-mortem defensive fractures. Blunt contusion over right occipital scalp.',
    'CID-DNA-2026-DHK-0412', 'Fingerprints rolled via live-scan; NID database cross-search pending secondary clearance',
    'Anjuman Mufidul Islam Register Vol-14, Razarbagh Morgue serial 312; Rayerbazar Graveyard Plot #B-412',
    'SI Kamal Uddin', 'Sub-Inspector', 'BP-8492018491', 'DMP Kotwali Model Thana', '+8801713374501', 'Dr. Nusrat Jahan (CID DNA Lab)',
    23.7042, 90.4124, NOW(), NOW()
),
(
    'UDB-2026-CTG-0045', 'RAILWAY-GRP-CTG', 'Railway Police (GRP) Inquest Unit', '2026-10-21', '11:15:00',
    'Km 34.2 Rail Track embankment, near Sitakunda Station Outer Signal', 'Sitakunda GRP Thana', 'Chattogram', 'Chattogram',
    'CrPC-174/Sitakunda-GRP/2026/34', 'GD No. 450 dated 21-Oct-2026', 40, 48, '40-50',
    'Male', 172.5, 'Dark Brown', 'Recoverable visual features', 'Unidentified - DNA profile stored',
    'Light blue striped cotton shirt, grey gabardine formal trousers, Bata brown leather sandals size 8',
    'Surgical keloid scar across right lower abdomen (consistent with appendectomy); pigmented birthmark on left shoulder blade',
    'None detected',
    'Severe tobacco staining across lower incisors; natural attrition on molars',
    'Broken spectacles with silver wire frame, set of 3 brass keys with rubber keychain, leather wallet containing 420 BDT without ID',
    'Multiple severe blunt-force crush injuries consistent with high-speed railway strike. Traumatic transection of left lower extremity.',
    'CID-DNA-2026-CTG-0089', 'Ten-print card recorded; partial AFIS match probability 64% against Chittagong voter roll',
    'Burial facilitated by Anjuman Mufidul Islam Chattogram branch, Firingi Bazar Graveyard Block 4-Row 12',
    'Inspector M. A. Bashar', 'Officer-in-Charge (GRP)', 'BP-7910284910', 'Railway Police Bangladesh', '+8801713374820', 'Dr. S. K. Barua (CMCH)',
    22.6167, 91.6606, NOW(), NOW()
),
(
    'UDB-2026-SYL-0019', 'PBI-SYL-SPECIAL', 'Police Bureau of Investigation (PBI) Sylhet', '2026-09-28', '14:20:00',
    'Shallow gravel bed near Zero Point, Piyain River, Jaflong', 'Gowainghat Thana', 'Sylhet', 'Sylhet',
    'CrPC-174/Gowainghat-2026/112', 'GD No. 892 dated 28-Sep-2026', 22, 27, '20-30',
    'Female', 153.0, 'Fair / Light Wheatish', 'Recoverable visual features', 'Unidentified - active matching',
    'Maroon georgette three-piece kameez with gold embroidery along neckline, matching salwar and orna',
    'Pierced nose (left nostril) with miniature silver flower stud; linear scar 2cm on inner left wrist',
    'Small stylized butterfly tattoo on right dorsal ankle',
    'Intact dentition; slight diastema (space) between upper central incisors',
    'Imitation pearl earrings, red braided hairband, metallic hair clip',
    'Asphyxia due to freshwater drowning. Examination revealed no ligature strangulation or lethal skeletal fractures.',
    'CID-DNA-2026-SYL-0145', 'Water-wrinkled epidermal peel re-hydrated; AFIS biometric profile uploaded to national index',
    'Preserved at Sylhet MAG Osmani Medical College Morgue cold storage; later buried at Manik Pir Graveyard Sylhet',
    'SI Rehana Akter', 'Sub-Inspector', 'BP-8610294819', 'PBI Sylhet District', '+8801713374933', 'Dr. Anupom Das (SOMC)',
    25.1633, 92.0167, NOW(), NOW()
),
(
    'UDB-2026-RAJ-0033', 'CID-RAJ-REGIONAL', 'CID Rajshahi Forensic Unit', '2026-10-05', '08:30:00',
    'Char Matikata, Padma River sandbank, 3km downstream from Godagari Ghat', 'Godagari Thana', 'Rajshahi', 'Rajshahi',
    'CrPC-174/Godagari-2026/67', 'GD No. 204 dated 05-Oct-2026', 50, 60, '50-60',
    'Male', 165.0, 'Dark', 'Decomposed', 'Pending forensic confirmation',
    'Check cotton lungi (green and navy), white sleeveless vest (torn), red holy thread on right wrist',
    'Amputation scar of left index finger distal phalanx; large dark mole on right cheek',
    'None',
    'Edentulous posterior upper jaw; worn central incisors',
    'Plastic wrapped pouch with tobacco, small brass ring on left pinky finger',
    'Moderate decomposition with skin slippage. No evidence of cranial fracture or firearm trauma. Cause of death consistent with drowning.',
    'CID-DNA-2026-RAJ-0072', 'Fingerprint friction ridge details partially degraded; chemical reconstruction underway',
    'Rajshahi City Corporation Graveyard, Hetem Khan Section; Anjuman Token #RAJ-441',
    'SI Tariqul Islam', 'Sub-Inspector', 'BP-8320491823', 'Rajshahi District Police', '+8801713374712', 'Dr. M. A. Hannan (RMC)',
    24.4667, 88.3333, NOW(), NOW()
),
(
    'UDB-2026-KHU-0027', 'RAB-6-KHU', 'RAB-6 Special Task Force & Riverine Patrol', '2026-10-18', '17:10:00',
    'Near Rupsha Rail Bridge pillar #4, Rupsha River shoreline', 'Rupsha Thana', 'Khulna', 'Khulna',
    'CrPC-174/Rupsha-2026/91', 'GD No. 719 dated 18-Oct-2026', 25, 32, '20-30',
    'Male', 170.0, 'Wheatish', 'Floater / Water immersed', 'Unidentified - active matching',
    'Navy blue sports track pants with white double stripes, grey moisture-wicking workout t-shirt',
    'Linear burn scar (scald) on left forearm (approx 5cm); surgical scar on right knee',
    'Tribal band tattooed around left bicep',
    'Orthodontic retainer wire present on lingual surface of mandibular anterior teeth',
    'Water-resistant fitness tracker band, black silicone ring',
    'Death due to cerebral hemorrhage secondary to heavy blunt impact to frontal bone before submersion. Homicide investigation initiated under CrPC §174/PBI.',
    'CID-DNA-2026-KHU-0103', 'Complete 10-finger AFIS capture completed at Khulna Medical College Morgue',
    'Khulna Municipal Graveyard, Rupsha Ghat Anjuman Mufidul Islam serial 189',
    'ASP Tanvir Ahmed', 'Assistant Superintendent of Police', 'BP-8120491823', 'RAB-6 Khulna', '+8801713374665', 'Dr. Shahabuddin (KMCH)',
    22.8098, 89.5828, NOW(), NOW()
),
(
    'UDB-2026-BAR-0014', 'CID-BAR-REGIONAL', 'CID Barishal Regional Unit', '2026-09-15', '07:50:00',
    'Kirtankhola Riverbank near Launch Steamer Ghat, Char Kawa', 'Kotwali Model Thana', 'Barishal', 'Barishal',
    'CrPC-174/Kotwali-Barishal/2026/51', 'GD No. 581 dated 15-Sep-2026', 35, 42, '30-40',
    'Female', 156.0, 'Medium Brown', 'Recoverable visual features', 'Unidentified - active matching',
    'Dark purple floral cotton saree with green border, cream colored blouse',
    'Prominent black mole on right upper lip; silver nose-ring in right nostril',
    'None',
    'Intact natural teeth; slight crowding in lower incisors',
    'Pair of brass bangles, pair of silver anklets (payel), small cloth key pouch',
    'Asphyxia consistent with ante-mortem drowning. No evidence of blunt or sharp force trauma.',
    'CID-DNA-2026-BAR-0056', 'Clear fingerprints captured; cross-referenced with Barishal NID sub-station',
    'Muslim Graveyard Amanatganj, Barishal; Anjuman Registry #BAR-218',
    'SI Harun-or-Rashid', 'Sub-Inspector', 'BP-8520491823', 'Barishal Metropolitan Police', '+8801713374332', 'Dr. K. M. Jahangir (SBMC)',
    22.7010, 90.3535, NOW(), NOW()
)
ON CONFLICT (case_reference_no) DO NOTHING;

-- 3. INITIAL APPROVED IO REQUEST
INSERT INTO official_access_requests (
    id, target_case_reference, officer_name, officer_rank, bp_number,
    posting_unit, official_email, phone_number, purpose_of_access,
    gd_fir_reference, request_status, access_token, token_expires_at,
    reviewed_by, created_at, updated_at
) VALUES (
    'req-paltan-001', 'UDB-2026-DHK-0012', 'SI Md. Nazrul Islam', 'Sub-Inspector (SI)',
    'BP-8812049182', 'Paltan Model Thana, DMP', 'nazrul.si@dmp.gov.bd', '+8801713374211',
    'Cross-verifying Paltan Thana Missing GD #412 with recovered Buriganga floater victim',
    'Paltan Thana GD #412/2026', 'approved', 'IO-AUTH-2026-DHK-4128',
    NOW() + INTERVAL '72 hours', 'SP M. A. Rahman (CIB)', NOW() - INTERVAL '4 hours', NOW()
)
ON CONFLICT (id) DO NOTHING;

-- 4. CITIZEN EMERGENCY REPORT
INSERT INTO citizen_reports (
    id, tracking_number, reporter_name, reporter_phone, reporter_email,
    recovery_location_description, district, thana, gender_observed,
    approx_age_description, clothing_description, condition_observed,
    additional_information, status, created_at, updated_at
) VALUES (
    'cit-rep-001', 'CR-2026-98124', 'Anwar Hossain', '+8801912481920', 'anwar.h@gmail.com',
    'Found floating near Sadarghat launch pontoon #4 early morning', 'Dhaka', 'Kotwali Thana',
    'Male', 'Approx 30-35 years old', 'Navy blue t-shirt and jeans', 'Fresh body, water immersed',
    'Informed Sadarghat river police outpost immediately.', 'verified', NOW() - INTERVAL '2 days', NOW()
)
ON CONFLICT (id) DO NOTHING;
