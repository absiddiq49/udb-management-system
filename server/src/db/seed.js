/**
 * ====================================================================
 * CID BANGLADESH - UNIDENTIFIED DEAD BODY MANAGEMENT SYSTEM (UDBMS)
 * PostgreSQL Database Seeder Script (Supports both direct SQL & Pg Pool)
 * ====================================================================
 * Populates PostgreSQL database with:
 * - 4 Tiered Police Accounts (Tier 0 Citizen, Tier 1 IO, Tier 2 Forensic, Tier 3 CID, Tier 5 CIB Admin)
 * - 26 Comprehensive Bangladesh Deceased Records across all 8 Divisions
 * - Forensic Photographic Evidence & Autopsy Attachments
 * - Official IO Access Requests & Citizen Reports
 */

const { pool } = require('./db');
const crypto = require('crypto');

// Password hash for 'police123' (SHA256 for demo compatibility with BetterAuth / password helper)
function hashPassword(password) {
  return crypto.createHash('sha256').update(password).digest('hex');
}

const DEMO_USERS = [
  {
    id: 'user_admin_001',
    name: 'SP M. A. Rahman',
    email: 'cib.admin@police.gov.bd',
    tier: 5,
    role: 'cib_admin',
    bp_number: 'BP-759812401',
    rank: 'Superintendent of Police (SP)',
    designation: 'Special Superintendent of Police',
    unit_thana: 'Central Intelligence Bureau (CIB), CID HQ Dhaka',
    phone_number: '+8801713374001',
  },
  {
    id: 'user_cid_002',
    name: 'Inspector Farhana Yasmin',
    email: 'farhana.cid@police.gov.bd',
    tier: 3,
    role: 'cid_officer',
    bp_number: 'BP-821940192',
    rank: 'Police Inspector (CID)',
    designation: 'Case Intake & Biometrics Officer',
    unit_thana: 'CID Forensic Hub Malibagh, Dhaka',
    phone_number: '+8801713374052',
  },
  {
    id: 'user_forensic_003',
    name: 'Dr. Nusrat Jahan',
    email: 'nusrat.dna@cid.gov.bd',
    tier: 2,
    role: 'forensic_expert',
    bp_number: 'BP-901248102',
    rank: 'Assistant Director (Forensics)',
    designation: 'Forensic DNA Specialist & Pathologist',
    unit_thana: 'National Forensic DNA Profiling Laboratory, CID Dhaka',
    phone_number: '+8801713374088',
  },
  {
    id: 'user_io_004',
    name: 'SI Md. Nazrul Islam',
    email: 'nazrul.si@dmp.gov.bd',
    tier: 1,
    role: 'external_io',
    bp_number: 'BP-8812049182',
    rank: 'Sub-Inspector (SI)',
    designation: 'Investigating Officer (IO)',
    unit_thana: 'Paltan Model Thana, DMP Dhaka',
    phone_number: '+8801713374211',
  },
  {
    id: 'user_citizen_005',
    name: 'Rafiqul Hassan (Citizen)',
    email: 'citizen.rafiq@gmail.com',
    tier: 0,
    role: 'citizen',
    bp_number: 'N/A',
    rank: 'Citizen Portal User',
    designation: 'Public Member',
    unit_thana: 'Dhaka Sadar',
    phone_number: '+8801819920192',
  },
];

const SEED_RECORDS = [
  {
    case_reference_no: 'UDB-2026-DHK-0012',
    source_portal: 'CID-UDBMS-HQ',
    input_team: 'CID Homicide & Forensics Squad',
    recovery_date: '2026-10-14',
    recovery_time: '06:45:00',
    recovery_location: 'Under Sadarghat Lalkuthi Pontoon, Buriganga River Shore',
    police_jurisdiction_thana: 'Kotwali Thana',
    district: 'Dhaka',
    division: 'Dhaka',
    crpc_inquest_no: 'CrPC-174/Kotwali-2026/89',
    thana_gd_no: 'GD No. 1142 dated 14-Oct-2026',
    estimated_age_min: 30,
    estimated_age_max: 35,
    age_group: '30-40',
    gender: 'Male',
    height_cm: 168.0,
    complexion: 'Wheatish / Brown',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - active matching',
    clothing_worn: 'Black full-sleeve polyester jacket over navy blue t-shirt, beige denim jeans with brown synthetic belt',
    physical_marks: 'Deep crescent scar on right forehead (approx 3.5cm); circular black mole behind left earlobe',
    tattoos: 'Faint anchor symbol inked in blue pigment on upper right forearm',
    dental_features: 'Missing lower right second premolar; distinct gold crown on upper left canine',
    belongings_found: 'Stainless steel digital wristwatch (water-damaged), metal safety pin, folded laminated medical receipt from Sir Salimullah Medical College',
    autopsy_summary: 'Asphyxia resulting from drowning in polluted river waters. No ante-mortem defensive fractures. Blunt contusion over right occipital scalp.',
    dna_profile_ref: 'CID-DNA-2026-DHK-0412',
    afis_fingerprint_status: 'Fingerprints rolled via live-scan; NID database cross-search pending secondary clearance',
    burial_reference: 'Anjuman Mufidul Islam Register Vol-14, Razarbagh Morgue serial 312; Rayerbazar Graveyard Plot #B-412',
    recovery_officer_name: 'SI Kamal Uddin',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8492018491',
    recovery_officer_unit: 'DMP Kotwali Model Thana',
    recovery_officer_phone: '+8801713374501',
    assigned_forensic_expert: 'Dr. Nusrat Jahan (CID DNA Lab)',
    gis_latitude: 23.7042,
    gis_longitude: 90.4124,
  },
  {
    case_reference_no: 'UDB-2026-CTG-0045',
    source_portal: 'RAILWAY-GRP-CTG',
    input_team: 'Railway Police (GRP) Inquest Unit',
    recovery_date: '2026-10-21',
    recovery_time: '11:15:00',
    recovery_location: 'Km 34.2 Rail Track embankment, near Sitakunda Station Outer Signal',
    police_jurisdiction_thana: 'Sitakunda GRP Thana',
    district: 'Chattogram',
    division: 'Chattogram',
    crpc_inquest_no: 'CrPC-174/Sitakunda-GRP/2026/34',
    thana_gd_no: 'GD No. 450 dated 21-Oct-2026',
    estimated_age_min: 40,
    estimated_age_max: 48,
    age_group: '40-50',
    gender: 'Male',
    height_cm: 172.5,
    complexion: 'Dark Brown',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - DNA profile stored',
    clothing_worn: 'Light blue striped cotton shirt, grey gabardine formal trousers, Bata brown leather sandals size 8',
    physical_marks: 'Surgical keloid scar across right lower abdomen (consistent with appendectomy); pigmented birthmark on left shoulder blade',
    tattoos: 'None detected',
    dental_features: 'Severe tobacco staining across lower incisors; natural attrition on molars',
    belongings_found: 'Broken spectacles with silver wire frame, set of 3 brass keys with rubber keychain, leather wallet containing 420 BDT without ID',
    autopsy_summary: 'Multiple severe blunt-force crush injuries consistent with high-speed railway strike. Traumatic transection of left lower extremity.',
    dna_profile_ref: 'CID-DNA-2026-CTG-0089',
    afis_fingerprint_status: 'Ten-print card recorded; partial AFIS match probability 64% against Chittagong voter roll',
    burial_reference: 'Burial facilitated by Anjuman Mufidul Islam Chattogram branch, Firingi Bazar Graveyard Block 4-Row 12',
    recovery_officer_name: 'Inspector M. A. Bashar',
    recovery_officer_rank: 'Officer-in-Charge (GRP)',
    recovery_officer_bp: 'BP-7910284910',
    recovery_officer_unit: 'Railway Police Bangladesh',
    recovery_officer_phone: '+8801713374820',
    assigned_forensic_expert: 'Dr. S. K. Barua (Chittagong Medical College Hospital Morgue)',
    gis_latitude: 22.6167,
    gis_longitude: 91.6606,
  },
  {
    case_reference_no: 'UDB-2026-SYL-0019',
    source_portal: 'PBI-SYL-SPECIAL',
    input_team: 'Police Bureau of Investigation (PBI) Sylhet',
    recovery_date: '2026-09-28',
    recovery_time: '14:20:00',
    recovery_location: 'Shallow gravel bed near Zero Point, Piyain River, Jaflong',
    police_jurisdiction_thana: 'Gowainghat Thana',
    district: 'Sylhet',
    division: 'Sylhet',
    crpc_inquest_no: 'CrPC-174/Gowainghat-2026/112',
    thana_gd_no: 'GD No. 892 dated 28-Sep-2026',
    estimated_age_min: 22,
    estimated_age_max: 27,
    age_group: '20-30',
    gender: 'Female',
    height_cm: 153.0,
    complexion: 'Fair / Light Wheatish',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - active matching',
    clothing_worn: 'Maroon georgette three-piece kameez with gold embroidery along neckline, matching salwar and orna',
    physical_marks: 'Pierced nose (left nostril) with miniature silver flower stud; linear scar 2cm on inner left wrist',
    tattoos: 'Small stylized butterfly tattoo on right dorsal ankle',
    dental_features: 'Intact dentition; slight diastema (space) between upper central incisors',
    belongings_found: 'Imitation pearl earrings, red braided hairband, metallic hair clip',
    autopsy_summary: 'Asphyxia due to freshwater drowning. Examination revealed no ligature strangulation or lethal skeletal fractures.',
    dna_profile_ref: 'CID-DNA-2026-SYL-0145',
    afis_fingerprint_status: 'Water-wrinkled epidermal peel re-hydrated; AFIS biometric profile uploaded to national index',
    burial_reference: 'Preserved at Sylhet MAG Osmani Medical College Morgue cold storage; later buried at Manik Pir Graveyard Sylhet',
    recovery_officer_name: 'SI Rehana Akter',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8610294819',
    recovery_officer_unit: 'PBI Sylhet District',
    recovery_officer_phone: '+8801713374933',
    assigned_forensic_expert: 'Dr. Anupom Das (Dept. of Forensic Medicine, SOMC)',
    gis_latitude: 25.1633,
    gis_longitude: 92.0167,
  },
  {
    case_reference_no: 'UDB-2026-RAJ-0033',
    source_portal: 'CID-RAJ-REGIONAL',
    input_team: 'CID Rajshahi Forensic Unit',
    recovery_date: '2026-10-05',
    recovery_time: '08:30:00',
    recovery_location: 'Char Matikata, Padma River sandbank, 3km downstream from Godagari Ghat',
    police_jurisdiction_thana: 'Godagari Thana',
    district: 'Rajshahi',
    division: 'Rajshahi',
    crpc_inquest_no: 'CrPC-174/Godagari-2026/67',
    thana_gd_no: 'GD No. 204 dated 05-Oct-2026',
    estimated_age_min: 50,
    estimated_age_max: 60,
    age_group: '50-60',
    gender: 'Male',
    height_cm: 165.0,
    complexion: 'Dark',
    body_condition: 'Decomposed',
    status: 'Pending forensic confirmation',
    clothing_worn: 'Check cotton lungi (green and navy), white sleeveless vest (torn), red holy thread on right wrist',
    physical_marks: 'Amputation scar of left index finger distal phalanx; large dark mole on right cheek',
    tattoos: 'None',
    dental_features: 'Edentulous posterior upper jaw; worn central incisors',
    belongings_found: 'Plastic wrapped pouch with tobacco, small brass ring on left pinky finger',
    autopsy_summary: 'Moderate decomposition with skin slippage. No evidence of cranial fracture or firearm trauma. Cause of death consistent with drowning.',
    dna_profile_ref: 'CID-DNA-2026-RAJ-0072',
    afis_fingerprint_status: 'Fingerprint friction ridge details partially degraded; chemical reconstruction underway',
    burial_reference: 'Rajshahi City Corporation Graveyard, Hetem Khan Section; Anjuman Token #RAJ-441',
    recovery_officer_name: 'SI Tariqul Islam',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8320491823',
    recovery_officer_unit: 'Rajshahi District Police',
    recovery_officer_phone: '+8801713374712',
    assigned_forensic_expert: 'Dr. M. A. Hannan (Rajshahi Medical College)',
    gis_latitude: 24.4667,
    gis_longitude: 88.3333,
  },
  {
    case_reference_no: 'UDB-2026-KHU-0027',
    source_portal: 'RAB-6-KHU',
    input_team: 'RAB-6 Special Task Force & Riverine Patrol',
    recovery_date: '2026-10-18',
    recovery_time: '17:10:00',
    recovery_location: 'Near Rupsha Rail Bridge pillar #4, Rupsha River shoreline',
    police_jurisdiction_thana: 'Rupsha Thana',
    district: 'Khulna',
    division: 'Khulna',
    crpc_inquest_no: 'CrPC-174/Rupsha-2026/91',
    thana_gd_no: 'GD No. 719 dated 18-Oct-2026',
    estimated_age_min: 25,
    estimated_age_max: 32,
    age_group: '20-30',
    gender: 'Male',
    height_cm: 170.0,
    complexion: 'Wheatish',
    body_condition: 'Floater / Water immersed',
    status: 'Unidentified - active matching',
    clothing_worn: 'Navy blue sports track pants with white double stripes, grey moisture-wicking workout t-shirt',
    physical_marks: 'Linear burn scar (scald) on left forearm (approx 5cm); surgical scar on right knee',
    tattoos: 'Tribal band tattooed around left bicep',
    dental_features: 'Orthodontic retainer wire present on lingual surface of mandibular anterior teeth',
    belongings_found: 'Water-resistant fitness tracker band (Casio/Xiaomi type), black silicone ring',
    autopsy_summary: 'Death due to cerebral hemorrhage secondary to heavy blunt impact to frontal bone before submersion. Homicide investigation initiated under CrPC §174/PBI.',
    dna_profile_ref: 'CID-DNA-2026-KHU-0103',
    afis_fingerprint_status: 'Complete 10-finger AFIS capture completed at Khulna Medical College Morgue',
    burial_reference: 'Khulna Municipal Graveyard, Rupsha Ghat Anjuman Mufidul Islam serial 189',
    recovery_officer_name: 'ASP Tanvir Ahmed',
    recovery_officer_rank: 'Assistant Superintendent of Police',
    recovery_officer_bp: 'BP-8120491823',
    recovery_officer_unit: 'RAB-6 Khulna',
    recovery_officer_phone: '+8801713374665',
    assigned_forensic_expert: 'Dr. Shahabuddin (KMCH Forensic Medicine Dept.)',
    gis_latitude: 22.8098,
    gis_longitude: 89.5828,
  },
  {
    case_reference_no: 'UDB-2026-BAR-0014',
    source_portal: 'CID-BAR-REGIONAL',
    input_team: 'CID Barishal Regional Unit',
    recovery_date: '2026-09-15',
    recovery_time: '07:50:00',
    recovery_location: 'Kirtankhola Riverbank near Launch Steamer Ghat, Char Kawa',
    police_jurisdiction_thana: 'Kotwali Model Thana',
    district: 'Barishal',
    division: 'Barishal',
    crpc_inquest_no: 'CrPC-174/Kotwali-Barishal/2026/51',
    thana_gd_no: 'GD No. 581 dated 15-Sep-2026',
    estimated_age_min: 35,
    estimated_age_max: 42,
    age_group: '30-40',
    gender: 'Female',
    height_cm: 156.0,
    complexion: 'Medium Brown',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - active matching',
    clothing_worn: 'Dark purple floral cotton saree with green border, cream colored blouse',
    physical_marks: 'Prominent black mole on right upper lip; silver nose-ring in right nostril',
    tattoos: 'None',
    dental_features: 'Intact natural teeth; slight crowding in lower incisors',
    belongings_found: 'Pair of brass bangles, pair of silver anklets (payel), small cloth key pouch',
    autopsy_summary: 'Asphyxia consistent with ante-mortem drowning. No evidence of blunt or sharp force trauma.',
    dna_profile_ref: 'CID-DNA-2026-BAR-0056',
    afis_fingerprint_status: 'Clear fingerprints captured; cross-referenced with Barishal NID sub-station',
    burial_reference: 'Muslim Graveyard Amanatganj, Barishal; Anjuman Registry #BAR-218',
    recovery_officer_name: 'SI Harun-or-Rashid',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8520491823',
    recovery_officer_unit: 'Barishal Metropolitan Police',
    recovery_officer_phone: '+8801713374332',
    assigned_forensic_expert: 'Dr. K. M. Jahangir (Sher-e-Bangla Medical College Hospital)',
    gis_latitude: 22.7010,
    gis_longitude: 90.3535,
  },
  {
    case_reference_no: 'UDB-2026-RNG-0021',
    source_portal: 'CID-RNG-REGIONAL',
    input_team: 'CID Rangpur Crime Scene Unit',
    recovery_date: '2026-10-10',
    recovery_time: '10:00:00',
    recovery_location: 'Teesta River canal embankment, near Teesta Barrage, Dimla',
    police_jurisdiction_thana: 'Dimla Thana',
    district: 'Nilphamari',
    division: 'Rangpur',
    crpc_inquest_no: 'CrPC-174/Dimla-2026/42',
    thana_gd_no: 'GD No. 344 dated 10-Oct-2026',
    estimated_age_min: 28,
    estimated_age_max: 35,
    age_group: '30-40',
    gender: 'Male',
    height_cm: 166.0,
    complexion: 'Wheatish',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - DNA profile stored',
    clothing_worn: 'Dark blue denim jeans, maroon round-neck pullover, black leather belt with silver rectangular buckle',
    physical_marks: 'Scar on chin (approx 2cm vertical); burn scar on right shoulder',
    tattoos: 'Om symbol tattooed on inner left wrist',
    dental_features: 'Missing lower central incisor (old injury); silver filling in upper right molar',
    belongings_found: 'Fastrack analog watch with black leather strap, copper ring on right middle finger',
    autopsy_summary: 'Blunt force trauma to temporal bone causing subdural hemorrhage. Body dumped in canal post-mortem.',
    dna_profile_ref: 'CID-DNA-2026-RNG-0034',
    afis_fingerprint_status: 'AFIS digital scans archived; no immediate national hit',
    burial_reference: 'Rangpur Medical College Morgue reference 194; Dimla Upazila Public Cemetery Plot #12',
    recovery_officer_name: 'Inspector M. Anisur Rahman',
    recovery_officer_rank: 'Inspector of Police',
    recovery_officer_bp: 'BP-8012491823',
    recovery_officer_unit: 'Nilphamari District Police',
    recovery_officer_phone: '+8801713374441',
    assigned_forensic_expert: 'Dr. Asaduzzaman (Rangpur Medical College)',
    gis_latitude: 26.1283,
    gis_longitude: 89.0683,
  },
  {
    case_reference_no: 'UDB-2026-MYM-0018',
    source_portal: 'CID-MYM-REGIONAL',
    input_team: 'CID Mymensingh Forensic Team',
    recovery_date: '2026-10-12',
    recovery_time: '15:45:00',
    recovery_location: 'Old Brahmaputra River Char, near Shombhuganj Bridge, Kotwali Thana',
    police_jurisdiction_thana: 'Kotwali Thana',
    district: 'Mymensingh',
    division: 'Mymensingh',
    crpc_inquest_no: 'CrPC-174/Kotwali-Mym-2026/88',
    thana_gd_no: 'GD No. 912 dated 12-Oct-2026',
    estimated_age_min: 45,
    estimated_age_max: 55,
    age_group: '40-50',
    gender: 'Male',
    height_cm: 162.0,
    complexion: 'Dark Brown',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - active matching',
    clothing_worn: 'Grey checked cotton shirt, black cotton trousers, black rubber slippers',
    physical_marks: 'Prominent wart on left eyebrow; healed fracture deformities on left collarbone',
    tattoos: 'None',
    dental_features: 'Severe dental attrition, missing upper right premolars',
    belongings_found: 'Folded paper talisman (tabiz) in black thread around neck, pocket comb',
    autopsy_summary: 'Death due to acute myocardial infarction followed by sudden collapse. No signs of foul play.',
    dna_profile_ref: 'CID-DNA-2026-MYM-0081',
    afis_fingerprint_status: 'Full set of 10 rolled prints captured on standard CID Form 14',
    burial_reference: 'Mymensingh Municipal Graveyard, Maskanda; Anjuman Serial #MYM-167',
    recovery_officer_name: 'SI Abdul Kader',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8712491823',
    recovery_officer_unit: 'Mymensingh Kotwali Thana',
    recovery_officer_phone: '+8801713374558',
    assigned_forensic_expert: 'Dr. Shah Alam (Mymensingh Medical College Hospital)',
    gis_latitude: 24.7471,
    gis_longitude: 90.4203,
  },
  {
    case_reference_no: 'UDB-2026-DHK-0089',
    source_portal: 'HIGHWAY-POLICE-HQ',
    input_team: 'Highway Police Gazipur Region',
    recovery_date: '2026-10-25',
    recovery_time: '04:15:00',
    recovery_location: 'Dhaka-Mymensingh Highway median culvert, near Tongi College Gate',
    police_jurisdiction_thana: 'Tongi Paschim Thana',
    district: 'Gazipur',
    division: 'Dhaka',
    crpc_inquest_no: 'CrPC-174/Tongi-2026/134',
    thana_gd_no: 'GD No. 1420 dated 25-Oct-2026',
    estimated_age_min: 24,
    estimated_age_max: 30,
    age_group: '20-30',
    gender: 'Male',
    height_cm: 171.0,
    complexion: 'Medium Wheatish',
    body_condition: 'Recoverable visual features',
    status: 'Unidentified - active matching',
    clothing_worn: 'Black hoodie with zip front, dark grey cargo pants with multiple pockets, white Apex running shoes size 41',
    physical_marks: 'Scar 4cm along right jawline; mole on back of neck',
    tattoos: 'Dragon motif tattooed on right shoulder blade',
    dental_features: 'All natural teeth present, very clean dental hygiene',
    belongings_found: 'Cracked smartphone (Samsung Galaxy A-series) without SIM card, metal carabiner keychain',
    autopsy_summary: 'Severe polytrauma consistent with high-speed vehicular hit-and-run impact. Bilateral femur fractures.',
    dna_profile_ref: 'CID-DNA-2026-GZP-0199',
    afis_fingerprint_status: 'Fingerprints processed and submitted to DMP Control Room AFIS hub',
    burial_reference: 'Gazipur City Corporation Morgue; Shaheed Tajuddin Ahmad Medical College reference 89',
    recovery_officer_name: 'SI Jahangir Hossain',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8912491823',
    recovery_officer_unit: 'Highway Police Gazipur',
    recovery_officer_phone: '+8801713374112',
    assigned_forensic_expert: 'Dr. Monjurul Islam (STA Medical College Gazipur)',
    gis_latitude: 23.9880,
    gis_longitude: 90.3800,
  },
  {
    case_reference_no: 'UDB-2026-CTG-0092',
    source_portal: 'CID-COX-REGIONAL',
    input_team: 'CID Cox\'s Bazar Tourist & Coastal Unit',
    recovery_date: '2026-10-19',
    recovery_time: '09:00:00',
    recovery_location: 'Inani Coral Beach shoreline, near Marine Drive culvert #14',
    police_jurisdiction_thana: 'Ukhiya Thana',
    district: 'Cox\'s Bazar',
    division: 'Chattogram',
    crpc_inquest_no: 'CrPC-174/Ukhiya-2026/78',
    thana_gd_no: 'GD No. 811 dated 19-Oct-2026',
    estimated_age_min: 32,
    estimated_age_max: 38,
    age_group: '30-40',
    gender: 'Male',
    height_cm: 167.0,
    complexion: 'Tan / Dark',
    body_condition: 'Floater / Water immersed',
    status: 'Unidentified - active matching',
    clothing_worn: 'Red and black nylon swimming shorts, black waterproof sports t-shirt',
    physical_marks: 'Circular scar on left deltoid (vaccination); small scar across bridge of nose',
    tattoos: 'Compass and ocean wave emblem on left chest',
    dental_features: 'Porcelain crown on left upper premolar',
    belongings_found: 'Waterproof silicone wristband with engraved letter "R"',
    autopsy_summary: 'Saltwater drowning with high salinity pulmonary edema. No defensive injuries.',
    dna_profile_ref: 'CID-DNA-2026-COX-0077',
    afis_fingerprint_status: 'Friction ridge detail recovered via forensic glycerin soaking; AFIS queued',
    burial_reference: 'Cox\'s Bazar Sadar Hospital Morgue; Anjuman Mufidul Islam Cox\'s Bazar Branch',
    recovery_officer_name: 'SI Faruk Ahmed',
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: 'BP-8412491823',
    recovery_officer_unit: 'Tourist Police Cox\'s Bazar',
    recovery_officer_phone: '+8801713374221',
    assigned_forensic_expert: 'Dr. Chandan Kumar (Cox\'s Bazar District Hospital)',
    gis_latitude: 21.3167,
    gis_longitude: 92.0500,
  },
];

// Generate additional 16 realistic cases to total 26 cases across Bangladesh
const DISTRICTS_DIVISIONS = [
  { division: 'Dhaka', district: 'Narayanganj', thana: 'Bandar Thana', loc: 'Shitalakshya Riverbank near Kadamrasul Ghat', gender: 'Male', ageMin: 35, ageMax: 42, condition: 'Recoverable visual features', unit: 'CID Narayanganj' },
  { division: 'Rajshahi', district: 'Bogura', thana: 'Sherpur Thana', loc: 'Dhaka-Bogura Highway culvert roadside ditch', gender: 'Female', ageMin: 26, ageMax: 32, condition: 'Recoverable visual features', unit: 'Highway Police Bogura' },
  { division: 'Khulna', district: 'Jashore', thana: 'Benapole Port Thana', loc: 'Border railway corridor near checkpost rail track', gender: 'Male', ageMin: 45, ageMax: 52, condition: 'Recoverable visual features', unit: 'Railway Police GRP' },
  { division: 'Sylhet', district: 'Moulvibazar', thana: 'Sreemangal Thana', loc: 'Finlay Tea Estate drainage ditch near Section 12', gender: 'Female', ageMin: 20, ageMax: 25, condition: 'Recoverable visual features', unit: 'PBI Moulvibazar' },
  { division: 'Barishal', district: 'Patuakhali', thana: 'Kalapara Thana', loc: 'Kuakata Sea Beach eastern mangrove fringe', gender: 'Male', ageMin: 30, ageMax: 38, condition: 'Floater / Water immersed', unit: 'RAB-8 Patuakhali' },
  { division: 'Dhaka', district: 'Munshiganj', thana: 'Gazaria Thana', loc: 'Meghna River sandy char near Meghna Bridge span 3', gender: 'Male', ageMin: 38, ageMax: 45, condition: 'Recoverable visual features', unit: 'CID Munshiganj' },
  { division: 'Rangpur', district: 'Dinajpur', thana: 'Hakimpur Thana', loc: 'Hili border railway track Km 18 culvert', gender: 'Male', ageMin: 28, ageMax: 35, condition: 'Recoverable visual features', unit: 'Railway Police Dinajpur' },
  { division: 'Mymensingh', district: 'Netrokona', thana: 'Durgapur Thana', loc: 'Someswari riverbed gravel area near Bijoypur', gender: 'Female', ageMin: 22, ageMax: 28, condition: 'Recoverable visual features', unit: 'PBI Netrokona' },
  { division: 'Chattogram', district: 'Cumilla', thana: 'Chauddagram Thana', loc: 'Dhaka-Chattogram Highway median green belt', gender: 'Male', ageMin: 48, ageMax: 58, condition: 'Recoverable visual features', unit: 'Highway Police Cumilla' },
  { division: 'Dhaka', district: 'Tangail', thana: 'Bhuapur Thana', loc: 'Jamuna River eastern embankment near guide dam', gender: 'Male', ageMin: 34, ageMax: 40, condition: 'Floater / Water immersed', unit: 'CID Tangail' },
  { division: 'Rajshahi', district: 'Pabna', thana: 'Ishwardi Thana', loc: 'Paksey Hardinge Bridge railway pier area', gender: 'Male', ageMin: 42, ageMax: 50, condition: 'Recoverable visual features', unit: 'Railway Police Ishwardi' },
  { division: 'Khulna', district: 'Kushtia', thana: 'Kumarkhali Thana', loc: 'Gorai River sandy shoal near railway bridge', gender: 'Female', ageMin: 30, ageMax: 36, condition: 'Recoverable visual features', unit: 'CID Kushtia' },
  { division: 'Sylhet', district: 'Habiganj', thana: 'Shaistaganj Thana', loc: 'Shaistaganj Railway Junction outer signal bush', gender: 'Male', ageMin: 52, ageMax: 62, condition: 'Decomposed', unit: 'Railway Police GRP' },
  { division: 'Barishal', district: 'Bhola', thana: 'Bhola Sadar Thana', loc: 'Ilisha Launch Ghat riverbank mudflat', gender: 'Male', ageMin: 26, ageMax: 33, condition: 'Floater / Water immersed', unit: 'CID Bhola' },
  { division: 'Dhaka', district: 'Faridpur', thana: 'Goalanda Thana', loc: 'Padma riverside rail terminal spur track', gender: 'Male', ageMin: 40, ageMax: 48, condition: 'Recoverable visual features', unit: 'Railway Police Goalanda' },
  { division: 'Chattogram', district: 'Brahmanbaria', thana: 'Akhaura Thana', loc: 'Titas River tributary near Gangasagar Railway Bridge', gender: 'Female', ageMin: 35, ageMax: 42, condition: 'Recoverable visual features', unit: 'PBI Brahmanbaria' },
];

for (let i = 0; i < DISTRICTS_DIVISIONS.length; i++) {
  const d = DISTRICTS_DIVISIONS[i];
  const refNum = (100 + i + 1).toString().padStart(4, '0');
  const divCode = d.division.substring(0, 3).toUpperCase();
  const caseRef = `UDB-2026-${divCode}-${refNum}`;

  SEED_RECORDS.push({
    case_reference_no: caseRef,
    source_portal: `${d.unit.replace(/\s+/g, '-').toUpperCase()}-HUB`,
    input_team: d.unit,
    recovery_date: `2026-10-${(10 + (i % 18)).toString().padStart(2, '0')}`,
    recovery_time: `${(6 + (i % 12)).toString().padStart(2, '0')}:${(15 * (i % 4)).toString().padStart(2, '0')}:00`,
    recovery_location: d.loc,
    police_jurisdiction_thana: d.thana,
    district: d.district,
    division: d.division,
    crpc_inquest_no: `CrPC-174/${d.thana.split(' ')[0]}-2026/${50 + i}`,
    thana_gd_no: `GD No. ${400 + (i * 37)} dated 2026-10-15`,
    estimated_age_min: d.ageMin,
    estimated_age_max: d.ageMax,
    age_group: `${d.ageMin}-${d.ageMax}`,
    gender: d.gender,
    height_cm: d.gender === 'Male' ? 165.0 + (i % 10) : 152.0 + (i % 8),
    complexion: i % 2 === 0 ? 'Wheatish' : 'Medium Brown',
    body_condition: d.condition,
    status: i % 3 === 0 ? 'Unidentified - DNA profile stored' : 'Unidentified - active matching',
    clothing_worn: d.gender === 'Male' ? 'Lungi with striped cotton shirt' : 'Cotton print saree with matching blouse',
    physical_marks: `Distinctive birthmark/scar noted on ${i % 2 === 0 ? 'right wrist' : 'left shoulder'} during Section 174 CrPC post-mortem inspection`,
    tattoos: i % 4 === 0 ? 'Religious inscription inked on inner forearm' : 'None detected',
    dental_features: 'Autopsy forensic odontogram completed and on file',
    belongings_found: 'Folded coins, plastic key ring, safety pin',
    autopsy_summary: 'Autopsy conducted per Section 174 CrPC. Forensic samples harvested for DNA and toxicology analysis.',
    dna_profile_ref: `CID-DNA-2026-${divCode}-${(100 + i).toString().padStart(4, '0')}`,
    afis_fingerprint_status: 'Fingerprint friction ridge scan completed and logged into national biometric queue',
    burial_reference: `Anjuman Mufidul Islam burial registry serial #AMI-${d.division.toUpperCase()}-${500 + i}`,
    recovery_officer_name: `SI Officer ${i + 1}`,
    recovery_officer_rank: 'Sub-Inspector',
    recovery_officer_bp: `BP-88${(10000 + i).toString()}`,
    recovery_officer_unit: d.unit,
    recovery_officer_phone: `+8801713374${(700 + i).toString().padStart(3, '0')}`,
    assigned_forensic_expert: 'Forensic Medical Officer on duty',
    gis_latitude: 23.5 + (i * 0.1),
    gis_longitude: 90.0 + (i * 0.1),
  });
}

async function seedDatabase() {
  console.log('[UDBMS Database Seeder] Starting database population...');
  console.log(`[UDBMS Database Seeder] Target Database: ${process.env.DB_NAME || 'cid_udb_db'}`);

  let client;
  try {
    client = await pool.connect();
    console.log('[PostgreSQL] Connected to database pool.');

    await client.query('BEGIN');

    // 1. Seed BetterAuth Users
    console.log(`[Seeder] Seeding ${DEMO_USERS.length} tiered police & citizen accounts...`);
    for (const u of DEMO_USERS) {
      // Upsert into "user"
      await client.query(
        `INSERT INTO "user" (
          id, name, email, email_verified, image, created_at, updated_at,
          tier, role, bp_number, rank, designation, unit_thana, phone_number, is_active
        ) VALUES ($1, $2, $3, true, null, NOW(), NOW(), $4, $5, $6, $7, $8, $9, $10, true)
        ON CONFLICT (email) DO UPDATE SET
          name = EXCLUDED.name,
          tier = EXCLUDED.tier,
          role = EXCLUDED.role,
          bp_number = EXCLUDED.bp_number,
          rank = EXCLUDED.rank,
          designation = EXCLUDED.designation,
          unit_thana = EXCLUDED.unit_thana,
          phone_number = EXCLUDED.phone_number,
          updated_at = NOW()`,
        [u.id, u.name, u.email, u.tier, u.role, u.bp_number, u.rank, u.designation, u.unit_thana, u.phone_number]
      );

      // Upsert into "account" for credential login (password: police123)
      await client.query(
        `INSERT INTO "account" (
          id, user_id, account_id, provider_id, password, created_at, updated_at
        ) VALUES ($1, $2, $3, 'credential', $4, NOW(), NOW())
        ON CONFLICT (provider_id, account_id) DO UPDATE SET
          password = EXCLUDED.password,
          updated_at = NOW()`,
        [`acc_${u.id}`, u.id, u.email, hashPassword('police123')]
      );
    }

    // 2. Seed Deceased Records
    console.log(`[Seeder] Seeding ${SEED_RECORDS.length} comprehensive unidentified deceased records across all 8 divisions...`);
    for (const r of SEED_RECORDS) {
      await client.query(
        `INSERT INTO unidentified_dead_bodies (
          case_reference_no, source_portal, input_team, recovery_date, recovery_time,
          recovery_location, police_jurisdiction_thana, district, division,
          crpc_inquest_no, thana_gd_no, estimated_age_min, estimated_age_max, age_group,
          gender, height_cm, complexion, body_condition, status, clothing_worn,
          physical_marks, tattoos, dental_features, belongings_found, autopsy_summary,
          dna_profile_ref, afis_fingerprint_status, burial_reference,
          recovery_officer_name, recovery_officer_rank, recovery_officer_bp,
          recovery_officer_unit, recovery_officer_phone, assigned_forensic_expert,
          gis_latitude, gis_longitude, created_at, updated_at
        ) VALUES (
          $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15,
          $16, $17, $18, $19, $20, $21, $22, $23, $24, $25, $26, $27, $28,
          $29, $30, $31, $32, $33, $34, $35, $36, NOW(), NOW()
        )
        ON CONFLICT (case_reference_no) DO UPDATE SET
          recovery_location = EXCLUDED.recovery_location,
          status = EXCLUDED.status,
          clothing_worn = EXCLUDED.clothing_worn,
          physical_marks = EXCLUDED.physical_marks,
          updated_at = NOW()`,
        [
          r.case_reference_no, r.source_portal, r.input_team, r.recovery_date, r.recovery_time,
          r.recovery_location, r.police_jurisdiction_thana, r.district, r.division,
          r.crpc_inquest_no, r.thana_gd_no, r.estimated_age_min, r.estimated_age_max, r.age_group,
          r.gender, r.height_cm, r.complexion, r.body_condition, r.status, r.clothing_worn,
          r.physical_marks, r.tattoos, r.dental_features, r.belongings_found, r.autopsy_summary,
          r.dna_profile_ref, r.afis_fingerprint_status, r.burial_reference,
          r.recovery_officer_name, r.recovery_officer_rank, r.recovery_officer_bp,
          r.recovery_officer_unit, r.recovery_officer_phone, r.assigned_forensic_expert,
          r.gis_latitude, r.gis_longitude
        ]
      );
    }

    // 3. Seed Sample Official Access Request
    console.log('[Seeder] Seeding initial official access requests...');
    await client.query(
      `INSERT INTO official_access_requests (
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
      ON CONFLICT (id) DO NOTHING`
    );

    // 4. Seed Sample Citizen Reports
    console.log('[Seeder] Seeding initial citizen reports...');
    await client.query(
      `INSERT INTO citizen_reports (
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
      ON CONFLICT (id) DO NOTHING`
    );

    await client.query('COMMIT');
    console.log('✅ [UDBMS Database Seeder] Successfully populated PostgreSQL database with tiered users and 26 deceased cases!');
  } catch (err) {
    if (client) await client.query('ROLLBACK');
    console.error('❌ [UDBMS Database Seeder Error]:', err.message);
  } finally {
    if (client) client.release();
    pool.end();
  }
}

if (require.main === module) {
  seedDatabase();
}

module.exports = { seedDatabase, DEMO_USERS, SEED_RECORDS };
