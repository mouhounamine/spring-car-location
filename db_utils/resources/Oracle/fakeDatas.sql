INSERT INTO OWNER (owner_id, owner_name, contact_info)
VALUES (101, 'John Doe', 'john.doe@luxury.com');

INSERT INTO OWNER (owner_id, owner_name, contact_info)
VALUES (102, 'Jane Smith', 'jane.smith@luxury.com');

INSERT INTO OWNER (owner_id, owner_name, contact_info)
VALUES (103, 'Paul Dupont', 'paul.dupont@luxury.com');

INSERT INTO OWNER (owner_id, owner_name, contact_info)
VALUES (104, 'Mary Brown', 'mary.brown@luxury.com');

INSERT INTO OWNER (owner_id, owner_name, contact_info)
VALUES (105, 'David Johnson', 'david.johnson@luxury.com');

INSERT INTO PROPERTY (
    property_id, owner_id, address, property_type, number_of_rooms,
    total_living_area, lot_size, property_condition, listing_price,
    rental_or_sale, availability_date, exclusivity_tier,
    city_category, neighborhood_category
) VALUES (
    1001, 101,
    '1 Rue Royale, 75008, Paris, France',
    'mansion',
    7,
    500,
    1200,
    'excellent',
    3000000,
    'sale',
    DATE '2025-06-01',
    'premium',
    'Paris',
    'Champs-Elysées'
);

INSERT INTO PROPERTY (
    property_id, owner_id, address, property_type, number_of_rooms,
    total_living_area, lot_size, property_condition, listing_price,
    rental_or_sale, availability_date, exclusivity_tier,
    city_category, neighborhood_category
) VALUES (
    1002, 102,
    '22 Avenue Montaigne, 75008, Paris, France',
    'apartment',
    4,
    120,
    0,
    'good',
    1200000,
    'sale',
    DATE '2025-02-10',
    'standard',
    'Paris',
    'Quartier Montaigne'
);

INSERT INTO PROPERTY (
    property_id, owner_id, address, property_type, number_of_rooms,
    total_living_area, lot_size, property_condition, listing_price,
    rental_or_sale, availability_date, exclusivity_tier,
    city_category, neighborhood_category
) VALUES (
    1003, 101,
    '3 Avenue du Casino, 98000, Monte Carlo, Monaco',
    'villa',
    10,
    600,
    2000,
    'new',
    8200000,
    'sale',
    DATE '2025-05-15',
    'premium',
    'Monaco',
    'Monte-Carlo'
);

INSERT INTO PROPERTY (
    property_id, owner_id, address, property_type, number_of_rooms,
    total_living_area, lot_size, property_condition, listing_price,
    rental_or_sale, availability_date, exclusivity_tier,
    city_category, neighborhood_category
) VALUES (
    1004, 103,
    '15 Place Massena, 06000, Nice, France',
    'apartment',
    3,
    90,
    0,
    'needs_renovation',
    450000,
    'sale',
    DATE '2025-03-01',
    'limited_access',
    'Nice',
    'Massena'
);

INSERT INTO PROPERTY (
    property_id, owner_id, address, property_type, number_of_rooms,
    total_living_area, lot_size, property_condition, listing_price,
    rental_or_sale, availability_date, exclusivity_tier,
    city_category, neighborhood_category
) VALUES (
    1005, 104,
    '100 Ocean Drive, 33139, Miami, US',
    'penthouse',
    6,
    300,
    0,
    'excellent',
    2200000,
    'rental',
    DATE '2026-01-01',
    'premium',
    'Miami',
    'OceanDrive'
);


INSERT INTO ANCILLARY_FACILITY (
    facility_id, property_id, facility_type, description
) VALUES (
    501, 1001, 'garage', '2 cars - underground'
);

INSERT INTO ANCILLARY_FACILITY (
    facility_id, property_id, facility_type, description
) VALUES (
    502, 1001, 'pool', 'Indoor heated pool'
);

INSERT INTO ANCILLARY_FACILITY (
    facility_id, property_id, facility_type, description
) VALUES (
    503, 1003, 'guest_house', '2 bedrooms guest cottage'
);

INSERT INTO ANCILLARY_FACILITY (
    facility_id, property_id, facility_type, description
) VALUES (
    504, 1004, 'cellar', 'Wine cellar for 300 bottles'
);

INSERT INTO ANCILLARY_FACILITY (
    facility_id, property_id, facility_type, description
) VALUES (
    505, 1005, 'gym', 'Private gym room'
);


INSERT INTO CLIENT (client_id, client_name, contact_info)
VALUES (201, 'Robert Wagner', 'robert.wagner@vip.com');

INSERT INTO CLIENT (client_id, client_name, contact_info)
VALUES (202, 'Anna Black', 'anna.black@vip.com');

INSERT INTO CLIENT (client_id, client_name, contact_info)
VALUES (203, 'Charles White', 'charles.white@vip.com');

INSERT INTO CLIENT (client_id, client_name, contact_info)
VALUES (204, 'Monica Green', 'monica.green@vip.com');

INSERT INTO CLIENT (client_id, client_name, contact_info)
VALUES (205, 'James Brown', 'james.brown@vip.com');


INSERT INTO TOUR (tour_id, property_id, client_id, tour_date, comments)
VALUES (3001, 1001, 201, DATE '2025-04-14', 'VIP request, very interested');

INSERT INTO TOUR (tour_id, property_id, client_id, tour_date, comments)
VALUES (3002, 1002, 202, DATE '2025-04-18', 'Asked for discount');

INSERT INTO TOUR (tour_id, property_id, client_id, tour_date, comments)
VALUES (3003, 1003, 201, DATE '2025-05-01', 'Potential investor');

INSERT INTO TOUR (tour_id, property_id, client_id, tour_date, comments)
VALUES (3004, 1004, 204, DATE '2025-03-12', 'Request for second visit');

INSERT INTO TOUR (tour_id, property_id, client_id, tour_date, comments)
VALUES (3005, 1005, 205, DATE '2026-01-22', 'Will come with family');


INSERT INTO LUX_TRANSACTION (
  transaction_id, property_id, transaction_date,
  transaction_amount, commission_amount, fiscal_period
)
VALUES (
  4001,
  1001,
  DATE '2025-06-25',
  2800000,
  0,
  '2025-Q2'
);

INSERT INTO LUX_TRANSACTION (
  transaction_id, property_id, transaction_date,
  transaction_amount, commission_amount, fiscal_period
)
VALUES (
  4002,
  1002,
  DATE '2025-04-20',
  1100000,
  0,
  '2025-Q2'
);

INSERT INTO LUX_TRANSACTION (
  transaction_id, property_id, transaction_date,
  transaction_amount, commission_amount, fiscal_period
)
VALUES (
  4003,
  1003,
  DATE '2025-05-05',
  8000000,
  0,
  '2025-Q2'
);

INSERT INTO LUX_TRANSACTION (
  transaction_id, property_id, transaction_date,
  transaction_amount, commission_amount, fiscal_period
)
VALUES (
  4004,
  1004,
  DATE '2025-04-01',
  420000,
  0,
  '2025-Q2'
);

INSERT INTO LUX_TRANSACTION (
  transaction_id, property_id, transaction_date,
  transaction_amount, commission_amount, fiscal_period
)
VALUES (
  4005,
  1005,
  DATE '2026-02-10',
  6000,
  0,
  '2026-Q1'
);


SELECT * FROM OWNER;
SELECT * FROM PROPERTY;
SELECT * FROM ANCILLARY_FACILITY;
SELECT * FROM CLIENT;
SELECT * FROM TOUR;
SELECT * FROM LUX_TRANSACTION;
