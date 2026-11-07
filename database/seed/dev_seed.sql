-- =============================================================================
-- SAHAAYI SEED DATA (SANITIZED FOR DEVELOPMENT)
-- =============================================================================

INSERT INTO users (id, email, hashed_password, full_name, phone, language_preference, is_active, is_verified)
VALUES (
    'c1f7b6b2-6529-4d8b-944a-d68a30704901',
    'dev.elder@sahaayi.in',
    '$2b$12$e8kZ1f01v5eDqvKjZomgquE1q3QoF6B12O3LwV/F8rZz6K2Rk0Z/2', -- 'Password123!'
    'Madhavan Nair (മാധവൻ നായർ)',
    '+919876543210',
    'ml',
    true,
    true
) ON CONFLICT (email) DO NOTHING;

INSERT INTO personal_profile_fields (user_id, field_name, field_value, field_type, is_verified, confidence_score)
VALUES 
('c1f7b6b2-6529-4d8b-944a-d68a30704901', 'full_name', 'Madhavan Nair', 'TEXT', true, 1.0),
('c1f7b6b2-6529-4d8b-944a-d68a30704901', 'date_of_birth', '1952-04-12', 'DATE', true, 1.0),
('c1f7b6b2-6529-4d8b-944a-d68a30704901', 'blood_group', 'O+ve', 'TEXT', true, 1.0),
('c1f7b6b2-6529-4d8b-944a-d68a30704901', 'permanent_address', 'Shanti Nilayam, Near Temple, Kottayam, Kerala 686001', 'TEXT', true, 1.0)
ON CONFLICT (user_id, field_name) DO NOTHING;
