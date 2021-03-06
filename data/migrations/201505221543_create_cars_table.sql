﻿CREATE TYPE gender AS ENUM ('male', 'female');

CREATE TABLE customers (
    id serial PRIMARY KEY,
    email text,
    password text,
    name text,
    surname text,
    gender gender,
    birth_date date,
    birth_town text,
    birth_province text,
    birth_country varchar(2),
    vat text,
    tax_code text,
    language varchar(2),
    country varchar(2),
    province text,
    town text,
    address text,
    address_info text,
    zip_code text,
    phone text,
    mobile text,
    fax text,
    driver_license text,
    driver_license_categories text[],
    driver_license_expire date,
    pin varchar(4),
    notes text,
    card_code text,
    inserted_ts timestamp with time zone DEFAULT now(),
    update_id bigint,
    update_ts bigint
);
--- D:\wamp\www\publiclocal\public\data\migrations/201505121144_create_countries_table.sql
CREATE TABLE countries (
    code varchar(2) PRIMARY KEY,
    name text
);

;
--- D:\wamp\www\publiclocal\public\data\migrations/201505121921_add_driver_license_fields.sql
ALTER TABLE customers ADD driver_license_authority VARCHAR(255) DEFAULT NULL;
ALTER TABLE customers ADD driver_license_country VARCHAR(2) DEFAULT NULL;
ALTER TABLE customers ADD driver_license_release_date DATE DEFAULT NULL;
ALTER TABLE customers ADD driver_license_name VARCHAR(255) DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505122313_create_registration_completed_field.sql
ALTER TABLE customers ADD registration_completed BOOLEAN DEFAULT 'false' NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505130721_create_hash_field.sql
ALTER TABLE customers ADD hash text DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505130739_customers_unique_constraints.sql
-- ALTER TABLE customers ADD CONSTRAINT email_uk UNIQUE (email);

-- ALTER TABLE customers ADD CONSTRAINT tax_code_uk UNIQUE (tax_code);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505141921_create_firt_payment_field.sql
ALTER TABLE customers ADD first_payment_completed BOOLEAN DEFAULT 'false' NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505190936_add_discout_rate_field.sql
ALTER TABLE customers ADD discount_rate INT DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505191657_create_roles_tables.sql
CREATE TABLE IF NOT EXISTS "user" (
    user_id SERIAL NOT NULL,
    username varchar(32),
    email varchar(32) NOT NULL,
    display_name varchar(32),
    password varchar(255) NOT NULL,
    state smallint
);
--- D:\wamp\www\publiclocal\public\data\migrations/201505191748_create_provinces_table.sql
CREATE TABLE provinces (
    code varchar(2) NOT NULL,
    name text DEFAULT NULL,
    PRIMARY KEY(code));
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505221543_create_cars_table.sql
CREATE TYPE car_status AS ENUM (''); /*TODO: define the possible statuses*/
CREATE TYPE cleanliness AS ENUM ('clean', 'average', 'dirty');

/* to execute as a superuser */
-- Enable PostGIS (includes raster)
CREATE EXTENSION postgis;
-- Enable Topology
CREATE EXTENSION postgis_topology;
-- fuzzy matching needed for Tiger
CREATE EXTENSION fuzzystrmatch;
-- Enable US Tiger Geocoder
CREATE EXTENSION postgis_tiger_geocoder;

/*back as a normal user*/
CREATE TABLE cars (
    plate text NOT NULL PRIMARY KEY,
    manufactures text NOT NULL,
    model text NOT NULL,
    status car_status NOT NULL,
    number int NOT NULL,
    active boolean DEFAULT true,
    int_cleanliness cleanliness NOT NULL,
    ext_cleanliness cleanliness NOT NULL,
    notes text,
    longitude numeric NOT NULL,
    latitude numeric NOT NULL,
    damages text, /*TODO: upgrade db to 9.4 to use jsonb*/
    battery int NOT NULL,
    frame text,
    location geometry NOT NULL,
    firmware_version text NOT NULL,
    software_version text NOT NULL,
    mac text NOT NULL,
    imei text NOT NULL,
    last_contact timestamp with time zone,
    last_location_time timestamp with time zone,
    busy boolean DEFAULT false,
    hidden boolean DEFAULT false,
    rpm int NOT NULL,
    speed int NOT NULL,
    obc_in_use int NOT NULL,
    obc_wl_size int NOT NULL,
    km int NOT NULL,
    running boolean DEFAULT false,
    parking boolean DEFAULT false,
    plug boolean DEFAULT false NOT NULL
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505221630_create_trips_table.sql
CREATE TABLE trips (
    id SERIAL PRIMARY KEY,
    car_plate text NOT NULL,
    customer_id int NOT NULL,
    timestamp_beginning timestamp with time zone NOT NULL,
    km_beginning int NOT NULL,
    battery_beginning int NOT NULL,
    longitude_beginning numeric NOT NULL,
    latitude_beginning numeric NOT NULL,
    geo_beginning geometry NOT NULL,
    beginning_tx timestamp with time zone NOT NULL,
    address_beginning text,
    timestamp_end timestamp with time zone NOT NULL,
    km_end int NOT NULL,
    battery_end int NOT NULL,
    longitude_end numeric NOT NULL,
    latitude_end numeric NOT NULL,
    geo_end geometry NOT NULL,
    end_tx timestamp with time zone NOT NULL,
    address_end text,
    park_seconds int NOT NULL,
    payable boolean DEFAULT true,
    price_cent int NOT NULL,
    vat_cent int NOT NULL,
    error_code integer DEFAULT 0 NOT NULL
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505251726_create_user_password_reset_table.sql
CREATE TABLE user_password_reset (request_key VARCHAR(32) NOT NULL, user_id INT NOT NULL, request_time TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, PRIMARY KEY(request_key));
CREATE UNIQUE INDEX UNIQ_DA84AD0BA76ED395 ON user_password_reset (user_id);;
--- D:\wamp\www\publiclocal\public\data\migrations/201505261211_create_authority_table.sql
CREATE TABLE authority (
    code varchar(3) PRIMARY KEY,
    name text NOT NULL
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505261313_create_reprofiling_option_field.sql
ALTER TABLE customers ADD reprofiling_option INT DEFAULT 0 NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505270925_profiling_counter_column.sql
ALTER TABLE customers ADD profiling_counter integer NOT NULL DEFAULT 0;;
--- D:\wamp\www\publiclocal\public\data\migrations/201505271757_create_reservations_table.sql
CREATE TABLE reservations (
    id SERIAL PRIMARY KEY,
    ts timestamp with time zone NOT NULL,
    car_plate text NOT NULL,
    customer_id integer NOT NULL,
    beginning_ts timestamp with time zone NOT NULL,
    active boolean NOT NULL DEFAULT true,
    cards jsonb, -- text if psql 9.1,
    length int NOT NULL,
    to_send boolean DEFAULT true,
    sent_ts timestamp with time zone NOT NULL,
    consumed_ts timestamp with time zone 
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505281823_add_foreign_keys.sql
ALTER TABLE trips ADD CONSTRAINT car_fk FOREIGN KEY (car_plate) REFERENCES cars (plate);
ALTER TABLE trips ADD CONSTRAINT customer_fk FOREIGN KEY (customer_id) REFERENCES customers (id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506011146_define_car_statuses.sql
ALTER TYPE car_status ADD VALUE 'operative';
ALTER TYPE car_status ADD VALUE 'not operative';
ALTER TYPE car_status ADD VALUE 'maintenance';;
--- D:\wamp\www\publiclocal\public\data\migrations/201506011207_datetime_without_milliseconds.sql
ALTER TABLE customers ALTER inserted_ts TYPE timestamp(0) with time zone;

ALTER TABLE cars ALTER last_contact TYPE timestamp(0) with time zone;
ALTER TABLE cars ALTER last_location_time TYPE timestamp(0) with time zone;

ALTER TABLE trips ALTER timestamp_beginning TYPE timestamp(0) with time zone;
ALTER TABLE trips ALTER beginning_tx TYPE timestamp(0) with time zone;
ALTER TABLE trips ALTER timestamp_end TYPE timestamp(0) with time zone;
ALTER TABLE trips ALTER end_tx TYPE timestamp(0) with time zone;

ALTER TABLE reservations ALTER ts TYPE timestamp(0) with time zone;
ALTER TABLE reservations ALTER beginning_ts TYPE timestamp(0) with time zone;
ALTER TABLE reservations ALTER sent_ts TYPE timestamp(0) with time zone;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506011428_add_webusers.sql
CREATE TABLE webuser (id INT NOT NULL, email VARCHAR(100) NOT NULL, display_name VARCHAR(100) NOT NULL, password VARCHAR(64) NOT NULL, role VARCHAR(100) NOT NULL, PRIMARY KEY(id));
CREATE SEQUENCE webuser_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE UNIQUE INDEX email_idx ON webuser (email);

;
--- D:\wamp\www\publiclocal\public\data\migrations/201506011429_create_table_cars_maintenance.sql
CREATE TABLE cars_maintenance (
    id SERIAL PRIMARY KEY,
    car_plate text NOT NULL,
    webuser_id integer NOT NULL,
    location text NOT NULL,
    notes text,
    update_ts timestamp without time zone NOT NULL
);

ALTER TABLE public.cars_maintenance OWNER TO sharengo;
ALTER TABLE cars_maintenance ADD CONSTRAINT webuser_fk FOREIGN KEY (webuser_id) REFERENCES webuser (id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506031212_allow_null_cars_fields.sql
ALTER TABLE cars ALTER COLUMN status SET DEFAULT 'maintenance';
ALTER TABLE cars ALTER COLUMN "number" SET DEFAULT 0 ;
ALTER TABLE cars ALTER COLUMN int_cleanliness SET DEFAULT 'clean';
ALTER TABLE cars ALTER COLUMN ext_cleanliness SET DEFAULT 'clean';
ALTER TABLE cars ALTER COLUMN battery SET DEFAULT  0;
ALTER TABLE cars ALTER COLUMN rpm SET DEFAULT  0;
ALTER TABLE cars ALTER COLUMN speed SET DEFAULT  0;
ALTER TABLE cars ALTER COLUMN obc_in_use SET DEFAULT  0;
ALTER TABLE cars ALTER COLUMN obc_wl_size SET DEFAULT  0;
ALTER TABLE cars ALTER COLUMN km SET DEFAULT  0;


ALTER TABLE cars ALTER COLUMN manufactures DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN model DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN location DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN longitude DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN latitude DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN firmware_version DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN software_version DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN mac DROP NOT NULL;
ALTER TABLE cars ALTER COLUMN imei DROP NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506031214_number_to_label.sql
ALTER TABLE cars RENAME "number" to label;
ALTER TABLE cars ALTER label TYPE text;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506031224_alter_car_statuses.sql
DROP TYPE car_status CASCADE;

CREATE TYPE car_status AS ENUM ('operative', 'out_of_order', 'maintenance');

ALTER TABLE cars ADD status car_status DEFAULT 'maintenance';;
--- D:\wamp\www\publiclocal\public\data\migrations/201506051642_create_pois_table.sql
CREATE TABLE pois
(
  id  serial,
  type text NOT NULL,
  code text,
  name text,
  brand text,
  address text,
  town text,
  zip_code text,
  province text,
  lon numeric,
  lat numeric,
  update bigserial,
  CONSTRAINT pois_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);

ALTER TABLE pois
  OWNER TO sharengo;


CREATE OR REPLACE FUNCTION public.f_pois_update_sequence()
  RETURNS trigger AS
$BODY$
BEGIN
   NEW.update = nextval('pois_update_seq'::regclass);
   RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_pois_update_sequence()
  OWNER TO sharengo;


CREATE TRIGGER trigger_pois_update
  BEFORE UPDATE
  ON public.pois
  FOR EACH ROW
  EXECUTE PROCEDURE public.f_pois_update_sequence();
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506051652_add_customer_enabled_field.sql
ALTER TABLE customers ADD enabled BOOLEAN NOT NULL DEFAULT false;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506080924_add_foreign_keys.sql
ALTER TABLE customers ADD CONSTRAINT authority_fk FOREIGN KEY (driver_license_authority) REFERENCES authority (code);
ALTER TABLE customers ADD CONSTRAINT birth_province_fk FOREIGN KEY (birth_province) REFERENCES  provinces (code);

;
--- D:\wamp\www\publiclocal\public\data\migrations/201506090932_remove_a_from_vatican.sql
UPDATE countries SET name = 'Citt&agrave; del vaticano' WHERE code = 'va';;
--- D:\wamp\www\publiclocal\public\data\migrations/201506100924_update_customers_pin.sql
ALTER TABLE customers ALTER pin DROP DEFAULT;
ALTER TABLE customers ALTER COLUMN pin TYPE JSONB USING pin::JSONB;
ALTER TABLE customers ALTER pin SET NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506101000_add_foreign_keys_reservations.sql
ALTER TABLE reservations ADD CONSTRAINT car_fk FOREIGN KEY (car_plate) REFERENCES cars (plate);
ALTER TABLE reservations ADD CONSTRAINT customer_fk FOREIGN KEY (customer_id) REFERENCES customers (id);;
--- D:\wamp\www\publiclocal\public\data\migrations/201506101225_add_fields_customers.sql
ALTER TABLE customers ADD gold_list BOOLEAN NOT NULL DEFAULT false;
ALTER TABLE customers ADD maintainer BOOLEAN NOT NULL DEFAULT false;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506111554_create_cartasi_tables.sql
CREATE SEQUENCE transactions_id_seq INCREMENT BY 1 MINVALUE 10000 START 10000;
CREATE SEQUENCE contracts_id_seq INCREMENT BY 1 MINVALUE 10000 START 10000;
CREATE TABLE transactions (id INT NOT NULL, contract_id INT DEFAULT NULL, amount INT NOT NULL, currency VARCHAR(3) NOT NULL, email VARCHAR(255) DEFAULT NULL, name VARCHAR(255) DEFAULT NULL, surname VARCHAR(255) DEFAULT NULL, brand VARCHAR(255) DEFAULT NULL, outcome TEXT DEFAULT NULL, datetime TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, cod_aut VARCHAR(255) DEFAULT NULL, region VARCHAR(255) DEFAULT NULL, country VARCHAR(255) DEFAULT NULL, message VARCHAR(255) DEFAULT NULL, hash VARCHAR(255) DEFAULT NULL, "check" VARCHAR(255) DEFAULT NULL, convention_code VARCHAR(255) DEFAULT NULL, transaction_type VARCHAR(255) DEFAULT NULL, product_type VARCHAR(255) DEFAULT NULL, first_transaction BOOLEAN NOT NULL, inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_EAA81A4C2576E0FD ON transactions (contract_id);
CREATE TABLE contracts (id INT NOT NULL, customer_id INT DEFAULT NULL, pan VARCHAR(19) DEFAULT NULL, pan_expiry VARCHAR(6) DEFAULT NULL, inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_950A9739395C3F3 ON contracts (customer_id);
ALTER TABLE transactions ADD CONSTRAINT FK_EAA81A4C2576E0FD FOREIGN KEY (contract_id) REFERENCES contracts (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE contracts ADD CONSTRAINT FK_950A9739395C3F3 FOREIGN KEY (customer_id) REFERENCES customers (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506130900_trigger_customers.sql

CREATE SEQUENCE public.customers_update_seq
  INCREMENT 1
  MINVALUE 1
  MAXVALUE 9223372036854775807
  START 13
  CACHE 1;
ALTER TABLE public.customers_update_seq
  OWNER TO sharengo;



CREATE OR REPLACE FUNCTION public.f_customers_update_sequence()
  RETURNS trigger AS
$BODY$
BEGIN
   NEW.update_id= nextval('customers_update_seq'::regclass);
   NEW.update_ts= floor(date_part('epoch',now()));
   RETURN NEW;
END;

$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.f_customers_update_sequence()
  OWNER TO sharengo;


CREATE TRIGGER trigger_customers_update BEFORE INSERT OR UPDATE
   ON customers FOR EACH ROW
   EXECUTE PROCEDURE public.f_customers_update_sequence();;
--- D:\wamp\www\publiclocal\public\data\migrations/201506130901_create_rfid_cards.sql
CREATE TABLE public.cards
(
  rfid text NOT NULL,
  code text NOT NULL,
  is_assigned boolean NOT NULL DEFAULT false,
  notes text,
  CONSTRAINT cards_pkey PRIMARY KEY (rfid),
  CONSTRAINT cards_code_key UNIQUE (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE cards
  OWNER TO  sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506130902_remove_notnull_trips.sql
ALTER TABLE trips ALTER COLUMN timestamp_end DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN km_end DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN battery_end DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN longitude_end DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN latitude_end DROP NOT NULL;

ALTER TABLE trips ALTER COLUMN geo_end DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN end_tx DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN park_seconds DROP NOT NULL;

ALTER TABLE trips ALTER COLUMN price_cent DROP NOT NULL;
ALTER TABLE trips ALTER COLUMN vat_cent DROP NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506130903_add_cars_fields.sql
ALTER TABLE cars
   ADD COLUMN soc integer NOT NULL DEFAULT 0;

ALTER TABLE cars
   ADD COLUMN vin text;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506130905_create_events.sql
CREATE TABLE events
(
  id  bigserial,
  event_time timestamp with time zone,
  server_time timestamp with time zone,
  car_plate text,
  event_id integer,
  label text,
  level integer,
  customer_id integer,
  trip_id integer,
  txtval text,
  intval integer,
  geo geometry,
  lon numeric,
  lat numeric,
  km integer,
  battery integer,
  mac text,
  imei text,
  data jsonb,
  CONSTRAINT pk_events_id PRIMARY KEY (id)
  )
WITH (
  OIDS=FALSE
);
ALTER TABLE events
  OWNER TO sharengo;


-- Index: public.idx_eventi_id_evento

-- DROP INDEX public.idx_eventi_id_evento;

CREATE INDEX idx_events_event_id
  ON events
  USING btree
  (event_id);

-- Index: public.idx_eventi_id_veicolo

-- DROP INDEX public.idx_eventi_id_veicolo;

CREATE INDEX idx_events_car_plate
  ON events
  USING btree
  (car_plate COLLATE pg_catalog."default");

-- Index: public.idx_eventi_timestamp

-- DROP INDEX public.idx_eventi_timestamp;

CREATE INDEX idx_events_event_time
  ON events
  USING btree
  (event_time);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506130915_update_reservations_fields.sql
ALTER TABLE reservations ALTER sent_ts DROP NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506131156_create_bonus_promocodes_tables.sql
CREATE SEQUENCE customersbonus_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE SEQUENCE promocodes_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE SEQUENCE promocodesinfo_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE customers_bonus (id INT NOT NULL, customer_id INT NOT NULL, webuser_id INT DEFAULT NULL, active BOOLEAN NOT NULL, insert_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, update_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, total INT NOT NULL, residual INT NOT NULL, type VARCHAR(100) NOT NULL, operator VARCHAR(100) DEFAULT NULL, valid_from TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, duration_days INT DEFAULT NULL, valid_to TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, description TEXT DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_AC781C5F9395C3F3 ON customers_bonus (customer_id);
CREATE INDEX IDX_AC781C5F49279951 ON customers_bonus (webuser_id);
CREATE TABLE promo_codes (id INT NOT NULL, promocodesinfo_id INT DEFAULT NULL, promocode VARCHAR(255) NOT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_C84FDDB41AFEBC1 ON promo_codes (promocodesinfo_id);
CREATE TABLE promo_codes_info (id INT NOT NULL, webuser_id INT DEFAULT NULL, active BOOLEAN NOT NULL, insert_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, type VARCHAR(100) NOT NULL, minutes INT NOT NULL, valid_from TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, duration_days INT DEFAULT NULL, valid_to TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_560C3D2E49279951 ON promo_codes_info (webuser_id);
ALTER TABLE customers_bonus ADD CONSTRAINT FK_AC781C5F9395C3F3 FOREIGN KEY (customer_id) REFERENCES customers (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE customers_bonus ADD CONSTRAINT FK_AC781C5F49279951 FOREIGN KEY (webuser_id) REFERENCES webuser (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE promo_codes ADD CONSTRAINT FK_C84FDDB41AFEBC1 FOREIGN KEY (promocodesinfo_id) REFERENCES promo_codes_info (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE promo_codes_info ADD CONSTRAINT FK_560C3D2E49279951 FOREIGN KEY (webuser_id) REFERENCES webuser (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506161045_add_foreign_keys_customers.sql
ALTER TABLE customers ADD CONSTRAINT card_code_fk FOREIGN KEY (card_code) REFERENCES cards (code);;
--- D:\wamp\www\publiclocal\public\data\migrations/201506191309_add_cars_keystatus.sql
ALTER TABLE cars ADD key_status TEXT DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506191320_create_logs.sql
CREATE TABLE logs
(
  log_time timestamp with time zone NOT NULL DEFAULT now(),
  car_plate text NOT NULL,
  km integer,
  battery integer,
  speed integer,
  key_status boolean,
  lon double precision,
  lat double precision,
  geo geometry,
  on_charge boolean,
  on_trip boolean,
  id_trip integer,
  cputemp integer,
  uptime integer,
  imei text,
  gps_info jsonb,
  detail jsonb,
  CONSTRAINT pk_log PRIMARY KEY (log_time, car_plate)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE logs
  OWNER TO sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506212333_alter_customers_promocodes.sql
ALTER TABLE promo_codes ADD description TEXT DEFAULT NULL;
ALTER TABLE promo_codes ADD active BOOLEAN NOT NULL;
ALTER TABLE customers_bonus ADD promocode_id INT DEFAULT NULL;
ALTER TABLE customers_bonus ADD CONSTRAINT FK_AC781C5FC76C06D9 FOREIGN KEY (promocode_id) REFERENCES promo_codes (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
CREATE INDEX IDX_AC781C5FC76C06D9 ON customers_bonus (promocode_id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506261416_create_account_trips_tables.sql
CREATE SEQUENCE trip_bills_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE SEQUENCE trip_bonuses_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE trip_bills (id INT NOT NULL, trip_id INT DEFAULT NULL, minutes INT NOT NULL, cost INT NOT NULL, timestamp_beginning TIMESTAMP(0) WITH TIME ZONE NOT NULL, timestamp_end TIMESTAMP(0) WITH TIME ZONE NOT NULL, notes TEXT DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_F83CDD93A5BC2E0E ON trip_bills (trip_id);
CREATE TABLE trip_bonuses (id INT NOT NULL, trip_id INT DEFAULT NULL, bonus_id INT DEFAULT NULL, minutes INT NOT NULL, timestamp_beginning TIMESTAMP(0) WITH TIME ZONE NOT NULL, 
timestamp_end TIMESTAMP(0) WITH TIME ZONE NOT NULL, notes TEXT DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_B3D98A7FA5BC2E0E ON trip_bonuses (trip_id);
CREATE INDEX IDX_B3D98A7F69545666 ON trip_bonuses (bonus_id);
ALTER TABLE trip_bills ADD CONSTRAINT FK_F83CDD93A5BC2E0E FOREIGN KEY (trip_id) REFERENCES trips (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_bonuses ADD CONSTRAINT FK_B3D98A7FA5BC2E0E FOREIGN KEY (trip_id) REFERENCES trips (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_bonuses ADD CONSTRAINT FK_B3D98A7F69545666 FOREIGN KEY (bonus_id) REFERENCES customers_bonus (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trips ADD is_accounted BOOLEAN DEFAULT 'false' NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506291749_create_free_fares_table.sql
CREATE SEQUENCE free_fares_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE free_fares (id INT NOT NULL default nextval('free_fares_id_seq'::regClass), conditions VARCHAR(255) NOT NULL, PRIMARY KEY(id));
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506301058_create_trip_free_fares_table.sql
CREATE SEQUENCE trip_free_fares_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE trip_free_fares (id INT NOT NULL, trip_id INT DEFAULT NULL, free_fare_id INT DEFAULT NULL, minutes INT NOT NULL, timestamp_beginning TIMESTAMP(0) WITH TIME ZONE NOT NULL, timestamp_end TIMESTAMP(0) WITH TIME ZONE NOT NULL, notes TEXT DEFAULT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_BB724A6AA5BC2E0E ON trip_free_fares (trip_id);
CREATE INDEX IDX_BB724A6A8AEC039C ON trip_free_fares (free_fare_id);
ALTER TABLE trip_free_fares ADD CONSTRAINT FK_BB724A6AA5BC2E0E FOREIGN KEY (trip_id) REFERENCES trips (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_free_fares ADD CONSTRAINT FK_BB724A6A8AEC039C FOREIGN KEY (free_fare_id) REFERENCES free_fares (id) NOT DEFERRABLE INITIALLY IMMEDIATE;;
--- D:\wamp\www\publiclocal\public\data\migrations/201506301908_update_reservations_fields.sql
ALTER TABLE reservations ALTER customer_id DROP NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507011034_add_car_charging_field.sql
ALTER TABLE cars ADD charging BOOLEAN DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201507011052_add_field_cards.sql
ALTER TABLE cards ADD assignable boolean DEFAULT true;;
--- D:\wamp\www\publiclocal\public\data\migrations/201507031150_update_reservation_consumed_ts.sql
DROP VIEW IF EXISTS "Prenotazioni ALARMS";

ALTER TABLE reservations ALTER consumed_ts TYPE timestamp(0) with time zone;

CREATE OR REPLACE VIEW "Prenotazioni ALARMS" AS
SELECT reservations.id,
reservations.ts,
reservations.car_plate,
reservations.customer_id,
reservations.beginning_ts,
reservations.active,
reservations.length,
reservations.to_send,
reservations.sent_ts,
reservations.consumed_ts
FROM reservations
WHERE reservations.active IS TRUE AND reservations.length = (-1);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507031235_create_reservations_archive_table.sql
CREATE TYPE reservations_archive_reason AS ENUM ('EXPIRED', 'USED', 'DELETED');

CREATE TABLE reservations_archive (
    id SERIAL PRIMARY KEY,
    ts timestamp with time zone NOT NULL,
    car_plate text NOT NULL,
    customer_id integer,
    beginning_ts timestamp with time zone NOT NULL,
    active boolean NOT NULL DEFAULT true,
    cards jsonb, -- text if psql 9.1,
    length int NOT NULL,
    to_send boolean DEFAULT true,
    sent_ts timestamp with time zone,
    consumed_ts timestamp with time zone,
    reason reservations_archive_reason NOT NULL ,
    archived_ts timestamp with time zone NOT NULL
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507061713_create_commands.sql
CREATE TABLE commands
(
  id bigserial NOT NULL,
  car_plate text,
  command text,
  intarg1 integer DEFAULT 0,
  intarg2 integer DEFAULT 0,
  txtarg1 text,
  txtarg2 text,
  queued timestamp with time zone,
  to_send boolean DEFAULT false,
  received timestamp with time zone,
  ttl integer DEFAULT 0,
  payload jsonb,
  CONSTRAINT commands_pk PRIMARY KEY (id)
)

;
--- D:\wamp\www\publiclocal\public\data\migrations/201507061714_alter_commands_cars_tables.sql
ALTER TABLE ONLY cars ALTER COLUMN charging TYPE boolean;
ALTER TABLE ONLY cars ALTER COLUMN charging SET DEFAULT false;
ALTER TABLE cars ADD COLUMN battery_offset integer NOT NULL DEFAULT 0;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507061715_functions.sql.sql
CREATE OR REPLACE FUNCTION public.notifycommand()
  RETURNS trigger AS
$BODY$
DECLARE
BEGIN
  IF (NEW.to_send <> OLD.to_send) THEN
	PERFORM pg_notify(CAST('commands' AS text),CAST(NEW.id AS text)|| ','
|| CAST(NEW.car_plate AS text)|| ',' || CAST(NEW.to_send AS TEXT));
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.notifycommand()
  OWNER TO sharengo;


CREATE TRIGGER notifycommand
  AFTER UPDATE
  ON public.commands
  FOR EACH ROW
  EXECUTE PROCEDURE public.notifycommand();

CREATE OR REPLACE FUNCTION public.notifynewcommand()
  RETURNS trigger AS
$BODY$
DECLARE
BEGIN
  IF (NEW.to_send) THEN
	PERFORM pg_notify(CAST('commands' AS text),CAST(NEW.id AS text)|| ','
|| CAST(NEW.car_plate AS text) || ',true');
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION public.notifynewcommand()
  OWNER TO sharengo;

CREATE TRIGGER notifynewcommand
  AFTER INSERT
  ON public.commands
  FOR EACH ROW
  EXECUTE PROCEDURE public.notifynewcommand();

CREATE OR REPLACE FUNCTION notifyreservation()
  RETURNS trigger AS
$BODY$
DECLARE
BEGIN
  IF (NEW.to_send <> OLD.to_send) THEN
	PERFORM pg_notify(CAST('reservations' AS text),CAST(NEW.id AS text)||
',' || CAST(NEW.car_plate AS text)|| ',' || CAST(NEW.to_send AS TEXT));
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION notifyreservation()
  OWNER TO sharengo;


CREATE OR REPLACE FUNCTION notifynewreservation()
  RETURNS trigger AS
$BODY$
DECLARE
BEGIN
  IF (NEW.to_send) THEN
	PERFORM pg_notify(CAST('reservations' AS text),CAST(NEW.id AS text)||
',' || CAST(NEW.car_plate AS text) || ',true');
  END IF;
  RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION notifynewreservation()
  OWNER TO sharengo;


CREATE TRIGGER notifyreservation
  AFTER UPDATE
  ON reservations
  FOR EACH ROW
  EXECUTE PROCEDURE notifyreservation();


CREATE TRIGGER notifynewreservation
  AFTER INSERT
  ON reservations
  FOR EACH ROW
  EXECUTE PROCEDURE notifynewreservation();;
--- D:\wamp\www\publiclocal\public\data\migrations/201507081033_add_reservations_archive_foreign_keys.sql
ALTER TABLE reservations_archive ADD CONSTRAINT car_fk FOREIGN KEY (car_plate) REFERENCES cars (plate);
ALTER TABLE reservations_archive ADD CONSTRAINT customer_fk FOREIGN KEY (customer_id) REFERENCES customers (id);
CREATE INDEX IDX_4DA2399395C3F3 ON reservations_archive (customer_id);
CREATE INDEX IDX_4DA239AE35528C ON reservations_archive (car_plate);;
--- D:\wamp\www\publiclocal\public\data\migrations/201507091541_add_deleted_ts.sql
ALTER TABLE reservations ADD deleted_ts timestamp(0) with time zone;
ALTER TABLE reservations_archive ADD deleted_ts timestamp(0) with time zone;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507150900_update_reservations.sql
ALTER TYPE reservations_archive_reason ADD VALUE 'ALARM-OFF';
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507151630_update_customers.sql
ALTER TABLE customers ADD general_condition1 BOOLEAN DEFAULT null;
ALTER TABLE customers ADD general_condition2 BOOLEAN DEFAULT null;
ALTER TABLE customers ADD regulation_condition1 BOOLEAN DEFAULT null;
ALTER TABLE customers ADD regulation_condition2 BOOLEAN DEFAULT null;
ALTER TABLE customers ADD privacy_condition BOOLEAN DEFAULT null;
ALTER TABLE customers ADD commercial_condition1 BOOLEAN DEFAULT false;
ALTER TABLE customers ADD commercial_condition2 BOOLEAN DEFAULT false;

UPDATE customers
    SET general_condition1 = true,
        general_condition2 = true,
        regulation_condition1 = true,
        regulation_condition2 = true,
        privacy_condition = true,
        commercial_condition1 = false,
        commercial_condition2 = false;

ALTER TABLE customers ALTER COLUMN general_condition1 SET NOT NULL;
ALTER TABLE customers ALTER COLUMN general_condition2 SET NOT NULL;
ALTER TABLE customers ALTER COLUMN regulation_condition1 SET NOT NULL;
ALTER TABLE customers ALTER COLUMN regulation_condition2 SET NOT NULL;
ALTER TABLE customers ALTER COLUMN privacy_condition SET NOT NULL;
ALTER TABLE customers ALTER COLUMN commercial_condition1 SET NOT NULL;
ALTER TABLE customers ALTER COLUMN commercial_condition2 SET NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507220933_update_customers.sql
ALTER TABLE customers DROP COLUMN IF EXISTS commercial_condition1;
ALTER TABLE customers DROP COLUMN IF EXISTS commercial_condition2;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201507281701_create_invoices.sql
CREATE TYPE invoice_type AS ENUM ('FIRST_PAYMENT', 'TRIP', 'PENALTY');

CREATE TABLE invoices (
    id SERIAL PRIMARY KEY,
    invoice_number TEXT,
    customer_id integer NOT NULL,
    generated_ts timestamp(0) with time zone NOT NULL,
    content jsonb NOT NULL, -- text if psql 9.1,
    version int NOT NULL,
    type invoice_type NOT NULL,
    invoice_date integer NOT NULL,
    amount int NOT NULL
);

CREATE SEQUENCE sequence_invoice_number OWNED BY invoices.invoice_number;

CREATE OR REPLACE FUNCTION before_insert_invoice()
    RETURNS trigger
    LANGUAGE plpgsql
    AS
    $$
        DECLARE base_val  bigint;
        DECLARE next_val bigint;
        BEGIN
            base_val := (EXTRACT(YEAR FROM now())::bigint * 10000000000);

            IF ((SELECT last_value FROM sequence_invoice_number) < base_val) THEN
                PERFORM setval('sequence_invoice_number', base_val);
            END IF;

            next_val := nextval('sequence_invoice_number');
            NEW.invoice_number := to_char((next_val / 10000000000), 'FM9999') || '/' || to_char((next_val % 10000000000), 'FM0999999999');

            RETURN NEW;
        END;
    $$;

CREATE TRIGGER trigger_invoice_created
    BEFORE INSERT ON invoices
    FOR EACH ROW EXECUTE PROCEDURE before_insert_invoice();
;
--- D:\wamp\www\publiclocal\public\data\migrations/201508041251_create_fares_table.sql
CREATE SEQUENCE fares_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE fares (
    id INT NOT NULL,
    motion_cost_per_minute INT NOT NULL,
    park_cost_per_minute INT NOT NULL,
    cost_steps JSONB NOT NULL,
    PRIMARY KEY(id)
);

;
--- D:\wamp\www\publiclocal\public\data\migrations/201508051516_create_payment_tables.sql
CREATE TYPE trip_payment_status AS ENUM ('not_payed', 'payed_correctly', 'wrong_payment', 'invoiced');

CREATE SEQUENCE trip_payments_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE SEQUENCE trip_payment_tries_id_seq INCREMENT BY 1 MINVALUE 1 START 1;

CREATE TABLE trip_payments (
    id INT NOT NULL,
    trip_id INT NOT NULL,
    fare_id INT NOT NULL,
    invoice_id INT,
    trip_minutes INT NOT NULL,
    parking_minutes INT NOT NULL,
    discount_percentage INT NOT NULL,
    total_cost INT NOT NULL,
    status trip_payment_status DEFAULT 'not_payed' NOT NULL,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    payed_successfully_at TIMESTAMP(0) WITHOUT TIME ZONE,
    invoiced_at TIMESTAMP(0) WITHOUT TIME ZONE,
    PRIMARY KEY(id)
);

CREATE INDEX IDX_CD83A822A5BC2E0E ON trip_payments (trip_id);
CREATE INDEX IDX_CD83A822A048D2E2 ON trip_payments (fare_id);
CREATE INDEX IDX_CD83A8222989F1FD ON trip_payments (invoice_id);

CREATE TABLE trip_payment_tries (
    id INT NOT NULL,
    trip_payment_id INT NOT NULL,
    webuser_id INT,
    transaction_id INT,
    ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    outcome VARCHAR(255) NOT NULL,
    PRIMARY KEY(id)
);

CREATE INDEX IDX_435112D7F1D178AD ON trip_payment_tries (trip_payment_id);
CREATE INDEX IDX_435112D749279951 ON trip_payment_tries (webuser_id);
CREATE INDEX IDX_435112D72FC0CB0F ON trip_payment_tries (transaction_id);

ALTER TABLE trip_payments ADD CONSTRAINT FK_CD83A822A5BC2E0E FOREIGN KEY (trip_id) REFERENCES trips (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_payments ADD CONSTRAINT FK_CD83A822A048D2E2 FOREIGN KEY (fare_id) REFERENCES fares (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_payments ADD CONSTRAINT FK_CD83A8222989F1FD FOREIGN KEY (invoice_id) REFERENCES invoices (id) NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE trip_payment_tries ADD CONSTRAINT FK_435112D7F1D178AD FOREIGN KEY (trip_payment_id) REFERENCES trip_payments (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_payment_tries ADD CONSTRAINT FK_435112D749279951 FOREIGN KEY (webuser_id) REFERENCES webuser (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE trip_payment_tries ADD CONSTRAINT FK_435112D72FC0CB0F FOREIGN KEY (transaction_id) REFERENCES transactions (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201508051545_remove_unuseful_fields.sql
ALTER TABLE trips
    DROP price_cent CASCADE,
    DROP vat_cent CASCADE;

ALTER TABLE trip_bills
    DROP cost;

CREATE OR REPLACE VIEW "Corse aperte" AS
    SELECT * FROM trips WHERE trips.timestamp_end IS NULL;

CREATE OR REPLACE VIEW "Corse di oggi" AS
    SELECT * FROM trips WHERE trips.timestamp_beginning > 'now'::text::date;;
--- D:\wamp\www\publiclocal\public\data\migrations/201508171717_add-payment_able_field.sql
ALTER TABLE customers ADD payment_able BOOLEAN DEFAULT 'true' NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201508211854_create_gps_alarms.sql
ALTER TABLE cars ADD COLUMN gps_data jsonb;
ALTER TABLE cars ADD COLUMN park_enabled boolean NOT NULL DEFAULT false;

CREATE TABLE public.gps_alarms
(
   alarm_time timestamp with time zone,
   car_plate text,
   lon numeric,
   lat numeric,
   gps_data jsonb,
   CONSTRAINT pk_gps_alarms PRIMARY KEY (alarm_time, car_plate)
)
WITH (
  OIDS = FALSE
);;
--- D:\wamp\www\publiclocal\public\data\migrations/201508211854_trips_alter_indexes.sql
CREATE INDEX idx_trips_car_plate ON trips (car_plate ASC NULLS LAST);
CREATE INDEX idx_trips_customer_id ON trips (customer_id ASC NULLS LAST);
CREATE INDEX idx_trips_timestamp_beginning ON trips (timestamp_beginning ASC NULLS LAST);
ALTER TABLE trips ADD COLUMN parent_id integer;;
--- D:\wamp\www\publiclocal\public\data\migrations/201508251613_create_zone_alarms_table.sql
CREATE TABLE zone_alarms (
    id SERIAL PRIMARY KEY,
    name text NOT NULL,
    geo polygon NOT NULL
);


;
--- D:\wamp\www\publiclocal\public\data\migrations/201508311228_create_customers_bonus_packages.sql
CREATE TABLE customers_bonus_packages (
    id SERIAL PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    minutes INT NOT NULL,
    type VARCHAR(100) NOT NULL,
    valid_from TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    duration INT DEFAULT NULL,
    valid_to TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL,
    buyable_until TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    description TEXT DEFAULT NULL,
    cost INT NOT NULL
    CHECK (duration IS NULL or valid_to IS NULL),
    CHECK (duration IS NOT NULL or valid_to IS NOT NULL)
);

ALTER TYPE invoice_type ADD VALUE IF NOT EXISTS 'BONUS_PACKAGE';

;
--- D:\wamp\www\publiclocal\public\data\migrations/201508311633_update_customer_email_lowercase.sql
UPDATE customers SET email = lower(email);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509041530_create_extra_payments_table.sql
CREATE SEQUENCE extra_payments_id_seq INCREMENT BY 1 MINVALUE 1 START 1;

CREATE TABLE extra_payments (id INT NOT NULL, customer_id INT NOT NULL, invoice_id INT DEFAULT NULL, amount INT NOT NULL, payment_type VARCHAR(255) NOT NULL, 
reason VARCHAR(255) NOT NULL, invoiced_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL, PRIMARY KEY(id));;
--- D:\wamp\www\publiclocal\public\data\migrations/201509071006_add_iva_to_invoices.sql
/**
 * Adds a column for iva with value 22 and sets it to NOT NULL
 */
ALTER TABLE invoices ADD iva integer;
UPDATE invoices SET iva = 22;
ALTER TABLE invoices ALTER COLUMN iva SET NOT NULL;

/**
 * Adds the iva value to the content column by:
 * - converting the jsonb to text (without first '{')
 * - appending iva to the front
 * - converting result back to jsonb
 */
UPDATE invoices
    SET content = (
        '{"iva":22,' ||
        substring(
            content::text
            from 2
            for (char_length(content::text) - 1)
        )
    )::jsonb;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509071501_add_cost_computed_field.sql
ALTER TABLE trips ADD cost_computed BOOLEAN DEFAULT 'false' NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201509071603_fix_card_codes.sql
/**
 * @param text crfid the rfid of a card
 * @param text ccode the code of a card
 *
 * Checks if the card's code is of the right length by extracting the longest
 * substring. If it isn't, it will:
 * - retrieve the customer with that code,
 * - remove the card from the customer,
 * - update the card with the correct code,
 * - reassign the card to the customer
 */
CREATE OR REPLACE FUNCTION fix_card_code(crfid text, ccode text)
    RETURNS void
    LANGUAGE plpgsql
    AS
    $$
        DECLARE customer_id int;
        DECLARE origin_code text;
        BEGIN
            origin_code = ccode;
            ccode = substring(ccode from 1 for 8);
            IF (ccode != origin_code) THEN
                customer_id = (SELECT customers.id FROM customers WHERE customers.card_code LIKE (ccode || '%'));
                UPDATE customers SET card_code = NULL WHERE id = customer_id;
                UPDATE cards SET code = ccode WHERE rfid = crfid;
                UPDATE customers SET card_code = ccode WHERE id = customer_id;
            END IF;
        END;
    $$;

/**
 * Calls the fix_card_code() function for every card, passing the rfid and code
 */
SELECT fix_card_code(cards.rfid, cards.code) FROM cards;

/**
 * Adds a constraint to the cards code column so that only capital alphanumeric
 * values can be used
 */
ALTER TABLE cards ADD CONSTRAINT alnum_code CHECK (code ~ '^[A-Z0-9]+$');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509081634_create_penalties_table.sql
CREATE SEQUENCE penalties_id_seq INCREMENT BY 1 MINVALUE 1 START 1;

CREATE TABLE penalties (id INT NOT NULL, reason VARCHAR(255) NOT NULL, amount INT DEFAULT NULL, PRIMARY KEY(id));


;
--- D:\wamp\www\publiclocal\public\data\migrations/201509090919_allign_json_to_invoice_date.sql
/**
 * updates the content column's field "invoice_date"
 * with the value of the invoice_date column by:
 * - converting the jsonb content to text
 * - using a regex to find the "invoice_date" field
 * - replacing that field with the value from the invoice_date column
 * - converting the result back to jsonb and storing it
 */
UPDATE invoices SET content = regexp_replace(content::text, '"invoice_date": [0-9]+', '"invoice_date": ' || invoice_date || '')::jsonb;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509111037_add_free_fares_description.sql
ALTER TABLE free_fares ADD COLUMN description varchar(255);
UPDATE free_fares SET description = 'Compleanno' WHERE id = 2;
UPDATE free_fares SET description = 'Gratuità donne 01:00-06:00' WHERE id = 1;
ALTER TABLE free_fares ALTER COLUMN description SET NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/20150914_add_promocodeinfo_field.sql
ALTER TABLE promo_codes_info ADD overridden_subscription_cost INT DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201509161145_fix_invoices_foreign_key.sql
/**
 * Fix missing reference to customers from invoices
 */
ALTER TABLE invoices ADD FOREIGN KEY (customer_id) REFERENCES customers (id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509171909_contracts_disabled_date.sql
ALTER TABLE contracts ADD disabled_date TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201509201441_create_fleet_table.sql
CREATE SEQUENCE fleet_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE fleets (id INT NOT NULL, code VARCHAR(2) NOT NULL, name TEXT NOT NULL, choropleth_params jsonb, PRIMARY KEY(id));

ALTER TABLE cars ADD fleet_id INT DEFAULT NULL;
ALTER TABLE cars ADD CONSTRAINT FK_95C71D144B061DF9 FOREIGN KEY (fleet_id) REFERENCES fleets (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
CREATE INDEX IDX_95C71D144B061DF9 ON cars (fleet_id);
ALTER TABLE trips ADD fleet_id INT DEFAULT NULL;
ALTER TABLE trips ADD CONSTRAINT FK_AA7370DA4B061DF9 FOREIGN KEY (fleet_id) REFERENCES fleets (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
CREATE INDEX IDX_AA7370DA4B061DF9 ON trips (fleet_id);

ALTER TABLE cars ALTER fleet_id SET NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509211254_alter_payment_status_enum.sql
UPDATE pg_enum SET enumlabel = 'to_be_payed'
WHERE enumlabel = 'not_payed' AND enumtypid = (
  SELECT oid FROM pg_type WHERE typname = 'trip_payment_status'
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509221103_field_to_be_payed_from.sql
ALTER TABLE trip_payments ADD to_be_payed_from TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL DEFAULT NOW();

UPDATE trip_payments SET to_be_payed_from = created_at;

ALTER TABLE trip_payments ALTER COLUMN to_be_payed_from DROP DEFAULT;;
--- D:\wamp\www\publiclocal\public\data\migrations/201509241201_add_first_payment_field.sql
/**
 * Check if there are any trip_payents with status = wrong_payment that do not
 * have a related trip_payment_try. This is unexpected so this will show there
 * is a problem if it returns any row. Do not proceed!
 */
SELECT *
FROM trip_payments tp
WHERE tp.status = 'wrong_payment'
AND NOT EXISTS(
    SELECT 1
    FROM trip_payment_tries tpt
    WHERE tpt.trip_payment_id = tp.id
);

/**
 * Add the column first_trip_payment_ts
 */
ALTER TABLE trip_payments ADD first_payment_try_ts TIMESTAMP(0) WITHOUT TIME ZONE;

/**
 * Set the column first_trip_payment_ts with the value from the
 * first (chronologically) trip_payment_tries that references that trip_payment
 * except for trip_payments with status = 'to_be_payed'
 */
UPDATE trip_payments tp
SET first_payment_try_ts = (
    SELECT tpt.ts
    FROM trip_payment_tries tpt
    WHERE tpt.trip_payment_id = tp.id
    AND tp.status != 'to_be_payed'
    ORDER BY tpt.id
    LIMIT 1
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509261636_add_userevent_table.sql
CREATE SEQUENCE userevents_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE user_events (id INT NOT NULL, webuser_id INT NOT NULL, insert_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, topic VARCHAR(100) NOT NULL, details JSONB NOT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_D96CF1FF49279951 ON user_events (webuser_id);
ALTER TABLE user_events ADD CONSTRAINT FK_D96CF1FF49279951 FOREIGN KEY (webuser_id) REFERENCES webuser (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
;
--- D:\wamp\www\publiclocal\public\data\migrations/20150928_update_fleets_table.sql
ALTER TABLE fleets ADD longitude NUMERIC DEFAULT NULL;
ALTER TABLE fleets ADD latitude NUMERIC DEFAULT NULL;
ALTER TABLE fleets ADD zoom_level INT DEFAULT NULL;
ALTER TABLE fleets ADD is_default BOOLEAN DEFAULT NULL;

UPDATE fleets SET latitude = 45.4627338, longitude = 9.1777323, zoom_level = 13, is_default = true WHERE id = 1;
UPDATE fleets SET latitude = 43.7794624, longitude = 11.2414829, zoom_level = 13, is_default = false WHERE id = 2;

ALTER TABLE fleets ALTER zoom_level SET NOT NULL;
ALTER TABLE fleets ALTER longitude SET NOT NULL;
ALTER TABLE fleets ALTER latitude SET NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201509301345_add_fleet_to_invoices.sql
/**
 * Add a column to specify the code used in invoices
 */
ALTER TABLE fleets ADD int_code TEXT UNIQUE;
/**
 * Set the codes for the current fleets and set the column as NOT NULL
 * Make sure 00 is the code for Milano and 01 for Firenze
 */
UPDATE fleets SET int_code = '00' WHERE id = 1;
UPDATE fleets SET int_code = '01' WHERE id = 2;
ALTER TABLE fleets ALTER COLUMN int_code SET NOT NULL;

/**
 * Add a column for the fleet to enable filtering and
 * easier access to this information.
 */
ALTER TABLE invoices ADD fleet_id INTEGER REFERENCES fleets(id);
/**
 * Set the current invoices with fleet for Milano. Make sure 1 is for Milano.
 * Now that it is populated, set the column as NOT NULL.
 */
UPDATE invoices SET fleet_id = 1;
ALTER TABLE invoices ALTER COLUMN fleet_id SET NOT NULL;
/**
 * Drop the trigger that was called when a new row was inserted.
 */
DROP TRIGGER IF EXISTS trigger_invoice_created ON invoices;
/**
 * Drop the function that is called when a new row is inserted.
 * This function used to generate the invoice_number value.
 */
DROP FUNCTION IF EXISTS before_insert_invoice();
/**
 * Now that the invoice_number value is generated in php and not by postgresql,
 * it makes sense to set the column as NOT NULL.
 */
ALTER TABLE invoices ALTER COLUMN invoice_number SET NOT NULL;

/**
 * Add UNIQUE key to invoice_number to avoid flushing multiple invoices at the
 * same time that would generate multiple invoice numbers with the same value.
 */
ALTER TABLE invoices ADD CONSTRAINT unique_invoice_number UNIQUE (invoice_number);

ALTER TABLE fleets ADD CONSTRAINT unique_code UNIQUE (code);;
--- D:\wamp\www\publiclocal\public\data\migrations/201510011549_extra_payments_fleet_column.sql
/*
 * make sure that 1 is in fact the id of the Milano fleet
 */
ALTER TABLE extra_payments ADD fleet_id INT NOT NULL DEFAULT 1 REFERENCES fleets(id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510020924_add_customer_fleet.sql
/*
 * assicurarsi che 1 sia il fleet_id di Milano
 */
ALTER TABLE customers ADD fleet_id INT NOT NULL DEFAULT 1 REFERENCES fleets(id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510051610_invoice_number_table.sql
CREATE TABLE invoice_number
(
  id serial NOT NULL,
  year integer NOT NULL,
  fleet_id integer NOT NULL,
  "number" integer NOT NULL,
  CONSTRAINT pk PRIMARY KEY (id)
);

ALTER TABLE invoice_number
  OWNER TO sharengo;

;
--- D:\wamp\www\publiclocal\public\data\migrations/201510051740_fleet_invoice_header.sql
ALTER TABLE fleets ADD invoice_header TEXT;

UPDATE fleets SET invoice_header =
'<span class="name">CS Milano SRL</span><br>
Sede legale<br>
Via dei Pelaghi, 162 – 57121 Livorno (LI)<br>
P.IVA: 01808470494<br>
Sede operativa<br>
Via Casati Felice 1/A – 20124 Milano (MI)<br>
Tel: 0586.1975772<br>
Email: servizioclienti@sharengo.eu'
WHERE id = 1; /*ensure that 1 is the id corresponding to Milano*/
UPDATE fleets SET invoice_header =
'<span class="name">CS Milano SRL</span><br>
Sede legale<br>
Via dei Pelaghi, 162 – 57124 Livorno (LI)<br>
P .IVA: 01823770498 - REA: LI161360<br>
Email: servizioclienti@sharengo.eu'
WHERE id = 2; /*ensure that 1 is the id corresponding to Firenze*/


ALTER TABLE fleets ALTER COLUMN invoice_header SET NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201510061402_fix_zone_alarms.sql
/**
 * Remove the column that references the fleet
 */
ALTER TABLE zone_alarms DROP COLUMN name;

/**
 * Add active column to specify if zone should be considered or not
 */
ALTER TABLE zone_alarms ADD active boolean DEFAULT true NOT NULL;

/**
 * Create table for many-to-many relationship
 */
CREATE TABLE zone_alarms_fleets (
    zone_alarm_id int REFERENCES zone_alarms (id) ON UPDATE CASCADE,
    fleet_id int REFERENCES fleets (id) ON UPDATE CASCADE,
    CONSTRAINT "zone_alarms_fleets_pkey" PRIMARY KEY (zone_alarm_id, fleet_id)
);


;
--- D:\wamp\www\publiclocal\public\data\migrations/201510121754_extra_invoice_able.sql
ALTER TABLE extra_payments ADD invoice_able BOOLEAN DEFAULT 'true';
ALTER TABLE extra_payments ADD generated_ts TIMESTAMP(0) WITHOUT TIME ZONE;

UPDATE extra_payments SET generated_ts = '2015-10-01 00:00:00';

/* check if all the extra payments present need to be invoice_able */
UPDATE extra_payments SET invoice_able = TRUE;

ALTER TABLE extra_payments ALTER COLUMN generated_ts SET NOT NULL;
ALTER TABLE extra_payments ALTER COLUMN invoice_able SET NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201510131517_bonus_validity_promo_code.sql
ALTER TABLE promo_codes_info ADD bonus_valid_from TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL;
ALTER TABLE promo_codes_info ADD bonus_valid_to TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL;

/* le date sono da verificare */
UPDATE promo_codes_info SET bonus_valid_from = '2015-01-01 00:00:00', bonus_valid_to = '2015-12-31 23:59:59';

ALTER TABLE promo_codes_info ALTER COLUMN bonus_valid_from SET NOT NULL;
ALTER TABLE promo_codes_info ALTER COLUMN bonus_valid_to SET NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201510161436_fix_uppercase_emails.sql
UPDATE customers SET email = lower(email);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510221722_bonus_package_reference.sql
ALTER TABLE customers_bonus ADD package_id INT DEFAULT NULL;
ALTER TABLE customers_bonus ADD CONSTRAINT FK_AC781C5FF44CABFF FOREIGN KEY (package_id) REFERENCES customers_bonus_packages (id) NOT DEFERRABLE INITIALLY IMMEDIATE;;
--- D:\wamp\www\publiclocal\public\data\migrations/201510231630_customer_bonus_transaction.sql
ALTER TABLE customers_bonus ADD transaction_id INT DEFAULT NULL;
ALTER TABLE customers_bonus ADD CONSTRAINT FK_AC781C5F2FC0CB0F FOREIGN KEY (transaction_id) REFERENCES transactions (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
CREATE UNIQUE INDEX UNIQ_AC781C5F2FC0CB0F ON customers_bonus (transaction_id);;
--- D:\wamp\www\publiclocal\public\data\migrations/201510261434_invoice_package_bonus.sql
ALTER TABLE customers_bonus ADD invoice_id INT DEFAULT NULL;
ALTER TABLE customers_bonus ADD invoiced_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL;
ALTER TABLE customers_bonus ADD CONSTRAINT FK_AC781C5F2989F1FD FOREIGN KEY (invoice_id) REFERENCES invoices (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
CREATE INDEX IDX_AC781C5F2989F1FD ON customers_bonus (invoice_id);;
--- D:\wamp\www\publiclocal\public\data\migrations/201510270937_add_cars_damages.sql
CREATE TABLE cars_damages (name TEXT NOT NULL, PRIMARY KEY(name));
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510281106_customer_bonuses_end.sql
update customers_bonus
set valid_to = (valid_to + '23 hours 59 minutes 59 seconds')
where to_char(valid_to, 'HH24:MI:SS') = '00:00:00';;
--- D:\wamp\www\publiclocal\public\data\migrations/201510291244_extra_payments_tranasction.sql
ALTER TABLE extra_payments ADD transaction_id INT DEFAULT NULL;
ALTER TABLE extra_payments ADD CONSTRAINT FK_2B0EC3612FC0CB0F FOREIGN KEY (transaction_id) REFERENCES transactions (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
CREATE UNIQUE INDEX UNIQ_2B0EC3612FC0CB0F ON extra_payments (transaction_id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510291550_subscription_payments_table.sql
CREATE SEQUENCE subscription_payments_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
ALTER SEQUENCE subscription_payments_id_seq OWNER TO sharengo;
CREATE TABLE subscription_payments (id INT NOT NULL, customer_id INT NOT NULL, fleet_id INT NOT NULL, transaction_id INT NOT NULL, amount INT NOT NULL, insert_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL, PRIMARY KEY(id));
ALTER TABLE subscription_payments OWNER TO sharengo;
CREATE INDEX IDX_27CC41E9395C3F3 ON subscription_payments (customer_id);
CREATE INDEX IDX_27CC41E4B061DF9 ON subscription_payments (fleet_id);
CREATE UNIQUE INDEX UNIQ_27CC41E2FC0CB0F ON subscription_payments (transaction_id);
ALTER TABLE subscription_payments ADD CONSTRAINT FK_27CC41E9395C3F3 FOREIGN KEY (customer_id) REFERENCES customers (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE subscription_payments ADD CONSTRAINT FK_27CC41E4B061DF9 FOREIGN KEY (fleet_id) REFERENCES fleets (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
ALTER TABLE subscription_payments ADD CONSTRAINT FK_27CC41E2FC0CB0F FOREIGN KEY (transaction_id) REFERENCES transactions (id) NOT DEFERRABLE INITIALLY IMMEDIATE;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510301732_create_customers_notes.sql
CREATE TABLE customer_notes (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers (id) NOT NULL,
    webuser_id INT REFERENCES webuser (id) NOT NULL,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    note TEXT NOT NULL
);

ALTER TABLE customer_notes OWNER TO sharengo;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201511050913_customer_bonus_package_notes.sql
ALTER TABLE customers_bonus_packages ADD notes TEXT DEFAULT NULL;

/* here I'm supposing there is only one bonus package */
UPDATE customers_bonus_packages SET notes = 'Acquistando questo pacchetto potrai guidare le equomobili di Sharen`go per soli 6€ / ora (0,10€ / minuto). I tuoi 1.000 minuti saranno aggiunti ai tuoi minuti bonus e potrai utilizzarli nei successivi 90 giorni';
--- D:\wamp\www\publiclocal\public\data\migrations/201511091546_insert_subscription_payments.sql
insert into subscription_payments
select nextval('subscription_payments_id_seq'), c.id, c.fleet_id, t.id, t.amount, now()
from customers c
join contracts co on co.customer_id = c.id
join transactions t on t.contract_id = co.id and (t.amount = 1000 or t.amount = 100) and t.outcome = 'OK'
where c.first_payment_completed = true
order by c.id;
--- D:\wamp\www\publiclocal\public\data\migrations/201511101348_add_driver_license_foreign.sql
ALTER TABLE customers ADD driver_license_foreign BOOLEAN DEFAULT 'false' NOT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201511101940_create_bonus_package_payments.sql
/**
 * Create table for payments for customers_bonus from packages
 */
CREATE TABLE bonus_package_payments (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    bonus_id INT NOT NULL REFERENCES customers_bonus(id),
    package_id INT NOT NULL REFERENCES customers_bonus_packages(id),
    fleet_id INT NOT NULL REFERENCES fleets(id),
    transaction_id INT NOT NULL REFERENCES transactions(id),
    invoice_id INT REFERENCES invoices(id) DEFAULT NULL,
    invoiced_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL,
    amount INT NOT NULL,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);

/**
 * Change ownership to sharengo
 */
ALTER TABLE bonus_package_payments OWNER TO sharengo;
ALTER SEQUENCE bonus_package_payments_id_seq OWNER TO sharengo;

;
--- D:\wamp\www\publiclocal\public\data\migrations/201511191117_alter_extra_apyemnts_reason.sql
ALTER TABLE extra_payments
ADD COLUMN reasons jsonb;

CREATE TYPE extra_payments_types AS ENUM('extra', 'penalty');

ALTER TABLE extra_payments
ADD COLUMN types_temp extra_payments_types;

UPDATE extra_payments
SET reasons = ('{"' || replace(reason, E'\t', '') || '": ' || amount::text || '}')::jsonb,
    types_temp = payment_type::extra_payments_types;

ALTER TABLE extra_payments
ALTER COLUMN reasons SET NOT NULL;

ALTER TABLE extra_payments
ALTER COLUMN types_temp SET NOT NULL;

ALTER TABLE extra_payments
DROP COLUMN reason;

ALTER TABLE extra_payments
DROP COLUMN payment_type;

ALTER TABLE extra_payments
RENAME COLUMN types_temp TO payment_type;

ALTER TABLE extra_payments ADD FOREIGN KEY (customer_id) REFERENCES customers (id);
ALTER TABLE extra_payments ADD FOREIGN KEY (invoice_id) REFERENCES invoices (id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201511260918_create_customer_deactivations.sql
CREATE TYPE disabled_reason AS ENUM (
    'FIRST_PAYMENT_NOT_COMPLETED',
    'FAILED_PAYMENT',
    'INVALID_DRIVERS_LICENSE',
    'DISABLED_BY_WEBUSER'
);

CREATE TABLE customer_deactivations (
    id SERIAL PRIMARY KEY,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    customer_id INT NOT NULL REFERENCES customers(id),
    reason disabled_reason NOT NULL,
    start_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    end_ts TIMESTAMP(0) WITHOUT TIME ZONE,
    deactivator_webuser_id INT REFERENCES webuser(id),
    reactivator_webuser_id INT REFERENCES webuser(id),
    details jsonb NOT NULL
);

ALTER TABLE customer_deactivations OWNER TO sharengo;


;
--- D:\wamp\www\publiclocal\public\data\migrations/201511271227_create_table_configuration.sql
/**
 * Create table configurations
 */
CREATE TABLE configurations (
    id serial PRIMARY KEY,
    slug text NOT NULL,
    config_key text NOT NULL,
    config_value text NOT NULL
);

ALTER TABLE configurations OWNER TO sharengo;

;
--- D:\wamp\www\publiclocal\public\data\migrations/201512141203_add_driver_surname.sql
ALTER TABLE customers ADD driver_license_surname VARCHAR(255) DEFAULT NULL;
ALTER TABLE customers ADD driver_license_firstname VARCHAR(255) DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201512161006_create_municipalities_table.sql
CREATE SEQUENCE italian_municipalities_id_seq INCREMENT BY 1 MINVALUE 0 START 0;
CREATE TABLE italian_municipalities (id INT NOT NULL, cadastral_code VARCHAR(255) NOT NULL, province VARCHAR(255) NOT NULL, name VARCHAR(255) NOT NULL, foreign_name VARCHAR(255) DEFAULT NULL, istat_code VARCHAR(255) DEFAULT NULL, active BOOLEAN NOT NULL, PRIMARY KEY(id));
CREATE INDEX IDX_3396B6374ADAD40B ON italian_municipalities (province);
ALTER SEQUENCE italian_municipalities_id_seq OWNER TO sharengo;
ALTER TABLE italian_municipalities OWNER TO sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201601071807_create_trip_payment_tries_canceled.sql
CREATE TABLE trip_payments_canceled (
    id SERIAL PRIMARY KEY,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    webuser_id INT NOT NULL REFERENCES webuser(id),
    original_end_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    trip_id INT NOT NULL REFERENCES trips(id),
    fare_id INT NOT NULL REFERENCES fares(id),
    trip_minutes INT NOT NULL,
    parking_minutes INT NOT NULL,
    discount_percentage INT NOT NULL,
    total_cost INT NOT NULL,
    created_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    to_be_payed_from TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    first_payment_try_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);

CREATE TABLE trip_payment_tries_canceled (
    id SERIAL PRIMARY KEY,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    trip_payment_canceled_id INT NOT NULL REFERENCES trip_payments_canceled(id),
    webuser_id INT REFERENCES webuser(id),
    transaction_id INT REFERENCES transactions(id),
    ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    outcome VARCHAR(255) NOT NULL
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201601141032_add_unique_trip_id_to_trip_payments.sql
ALTER TABLE trip_payments ADD UNIQUE (trip_id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201601151604_add_cvs_tables.sql
CREATE TYPE csv_anomaly_type AS ENUM (
    'MISSING_FROM_TRANSACTIONS',
    'OUTCOME_ERROR',
    'AMOUNT_ERROR'
);

CREATE TABLE cartasi_csv_files (
    id SERIAL PRIMARY KEY,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    filename TEXT NOT NULL,
    webuser_id INT NOT NULL REFERENCES webuser(id)
);

CREATE TABLE cartasi_csv_anomalies (
    id SERIAL PRIMARY KEY,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    cartasi_csv_file_id INT NOT NULL REFERENCES cartasi_csv_files(id),
    type csv_anomaly_type NOT NULL,
    amount INT NOT NULL,
    resolved BOOLEAN DEFAULT false NOT NULL,
    resolved_ts TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL,
    webuser_id INT REFERENCES webuser(id) DEFAULT NULL,
    csv_data jsonb NOT NULL,
    transaction_id INT REFERENCES transactions(id) DEFAULT NULL,
    updates jsonb DEFAULT NULL
);

ALTER TABLE cartasi_csv_files OWNER TO sharengo;

ALTER TABLE cartasi_csv_anomalies OWNER TO sharengo;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201601181512_add_countries_mctc_field.sql
ALTER TABLE countries ADD mctc VARCHAR(3) DEFAULT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201601221650_rename_promo_codes_duration_column.sql
ALTER TABLE promo_codes_info RENAME COLUMN duration_days TO bonus_duration_days;;
--- D:\wamp\www\publiclocal\public\data\migrations/201601291433_fix_trip_payments_status_invoiced.sql
/**
 * Fixes an error where status was not set correctly after invoice was generated
 */
UPDATE trip_payments
SET status = 'invoiced'
WHERE invoice_id IS NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201602081036_add_events_types_table.sql
/**
 * Create the events_types table
 */
CREATE SEQUENCE events_types_id_seq INCREMENT BY 1 MINVALUE 1 START 1;
CREATE TABLE events_types (id INT NOT NULL, label VARCHAR(255) NOT NULL, map_logic VARCHAR(255) NOT NULL, description TEXT NOT NULL, notes TEXT DEFAULT NULL, PRIMARY KEY(id));


;
--- D:\wamp\www\publiclocal\public\data\migrations/201602181651_create_foreign_drivers_license_upload_table.sql
CREATE SEQUENCE foreign_drivers_license_upload_id_seq INCREMENT BY 1 MINVALUE 1 START 1;

CREATE TABLE foreign_drivers_license_upload (
    id INT NOT NULL,
    customer_id INT NOT NULL,
    customer_name VARCHAR(255) DEFAULT NULL,
    customer_surname VARCHAR(255) DEFAULT NULL,
    customer_birth_town VARCHAR(255) DEFAULT NULL,
    customer_birth_province VARCHAR(255) DEFAULT NULL,
    customer_birth_country VARCHAR(2) DEFAULT NULL,
    customer_birth_date DATE DEFAULT NULL,
    customer_country VARCHAR(2) DEFAULT NULL,
    customer_town VARCHAR(255) DEFAULT NULL,
    customer_address VARCHAR(255) DEFAULT NULL,
    drivers_license_number VARCHAR(255) DEFAULT NULL,
    drivers_license_authority VARCHAR(255) DEFAULT NULL,
    drivers_license_country VARCHAR(2) DEFAULT NULL,
    drivers_license_release_date DATE DEFAULT NULL,
    drivers_license_firstname VARCHAR(255) DEFAULT NULL,
    drivers_license_surname VARCHAR(255) DEFAULT NULL,
    drivers_license_categories VARCHAR(255) DEFAULT NULL,
    drivers_license_expire DATE DEFAULT NULL,
    file_name VARCHAR(255) NOT NULL,
    file_type VARCHAR(255) DEFAULT NULL,
    file_location VARCHAR(255) DEFAULT NULL,
    file_size INT DEFAULT NULL,
    valid BOOLEAN DEFAULT NULL,
    validated_by INT DEFAULT NULL,
    validated_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL,
    uploaded_at TIMESTAMP(0) WITHOUT TIME ZONE DEFAULT NULL,
    PRIMARY KEY(id)
);

CREATE INDEX IDX_E910C5F29395C3F3 ON foreign_drivers_license_upload (customer_id);
CREATE INDEX IDX_E910C5F2F54EF1C ON foreign_drivers_license_upload (validated_by);

ALTER TABLE foreign_drivers_license_upload
    ADD CONSTRAINT FK_E910C5F29395C3F3 FOREIGN KEY (customer_id) REFERENCES customers (id) NOT DEFERRABLE INITIALLY IMMEDIATE,
    ADD CONSTRAINT FK_E910C5F2F54EF1C FOREIGN KEY (validated_by) REFERENCES webuser (id) NOT DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE foreign_drivers_license_upload OWNER TO sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201602251110_create_cartasi_csv_anomalies_notes.sql
CREATE TABLE cartasi_csv_anomalies_notes (
    id SERIAL PRIMARY KEY,
    inserted_at TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL,
    cartasi_csv_anomaly_id INT REFERENCES cartasi_csv_anomalies(id),
    webuser_id INT REFERENCES webuser(id),
    note VARCHAR(255)
);

ALTER TABLE cartasi_csv_anomalies_notes OWNER TO sharengo;

--remove column from updates from cartasi_csv_anomalies
ALTER TABLE cartasi_csv_anomalies
DROP COLUMN updates;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201603141605_add_zone_alarms_description_field.sql
ALTER TABLE zone_alarms ADD description TEXT;;
--- D:\wamp\www\publiclocal\public\data\migrations/201603151700_create_foreign_dl_validations.sql
CREATE TABLE foreign_drivers_license_validation (
    id SERIAL PRIMARY KEY,
    foreign_drivers_license_upload_id INT REFERENCES foreign_drivers_license_upload(id),
    validated_by INT REFERENCES webuser(id),
    validated_at TIMESTAMP(0) WITHOUT TIME ZONE,
    revoked_by INT REFERENCES webuser(id),
    revoked_at TIMESTAMP(0) WITHOUT TIME ZONE
);

;
--- D:\wamp\www\publiclocal\public\data\migrations/201604081311_customer_providers.sql
CREATE TABLE provider_authenticated_customers (
    id UUID NOT NULL,
    provider VARCHAR(255) NOT NULL,
    identifier VARCHAR(255) DEFAULT NULL,
    website_url VARCHAR(255) DEFAULT NULL,
    profile_url VARCHAR(255) DEFAULT NULL,
    photo_url VARCHAR(255) DEFAULT NULL,
    display_name VARCHAR(255) DEFAULT NULL,
    description VARCHAR(255) DEFAULT NULL,
    first_name VARCHAR(255) DEFAULT NULL,
    last_name VARCHAR(255) DEFAULT NULL,
    gender VARCHAR(255) DEFAULT NULL,
    language VARCHAR(255) DEFAULT NULL,
    age INT DEFAULT NULL,
    birth_day INT DEFAULT NULL,
    birth_month INT DEFAULT NULL,
    birth_year INT DEFAULT NULL,
    email VARCHAR(255) DEFAULT NULL,
    email_verified VARCHAR(255) DEFAULT NULL,
    phone VARCHAR(255) DEFAULT NULL,
    address VARCHAR(255) DEFAULT NULL,
    country VARCHAR(255) DEFAULT NULL,
    region VARCHAR(255) DEFAULT NULL,
    city VARCHAR(255) DEFAULT NULL,
    zip VARCHAR(255) DEFAULT NULL,
    customer_id INT DEFAULT NULL REFERENCES customers(id),
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE,
    PRIMARY KEY(id)
);
COMMENT ON COLUMN provider_authenticated_customers.id IS '(DC2Type:uuid)';

ALTER TABLE provider_authenticated_customers OWNER TO sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191435_create_cars_configurations.sql
CREATE TABLE cars_configurations (
    id integer NOT NULL,
    fleet_id integer,
    model text,
    car_plate text,
    key text NOT NULL,
    value text NOT NULL
);

CREATE SEQUENCE car_configs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER TABLE ONLY cars_configurations ALTER COLUMN id SET DEFAULT nextval('car_configs_id_seq'::regclass);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191439_create_cars_info.sql

CREATE TABLE cars_info (
    car_plate text NOT NULL,
    int_lat double precision,
    int_lon double precision,
    int_geo geometry,
    gprs_lat double precision,
    gprs_lon double precision,
    gprs_geo geometry,
    fw_ver text,
    hw_ver text,
    sw_ver text,
    sdk text,
    sdk_ver text,
    gsm_ver text,
    android_device text,
    android_build text,
    tbox_sw text,
    tbox_hw text,
    mcu_model text,
    mcu text,
    hw_version text,
    hb_ver text,
    vehicle_type text,
    lastupdate timestamp with time zone,
    gps text
);

--
-- Name: COLUMN cars_info.fw_ver; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.fw_ver IS 'Versione Firmware GPRS Box';


--
-- Name: COLUMN cars_info.hw_ver; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.hw_ver IS 'Versione Hardware Android';


--
-- Name: COLUMN cars_info.sw_ver; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.sw_ver IS 'Versione OBC';


--
-- Name: COLUMN cars_info.sdk; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.sdk IS 'Versione Servizio Android HIKSDK';


--
-- Name: COLUMN cars_info.gsm_ver; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.gsm_ver IS 'Versione Modulo 3G';


--
-- Name: COLUMN cars_info.android_device; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.android_device IS 'Modello Android (rilevato dal S.O. Android)';


--
-- Name: COLUMN cars_info.android_build; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.android_build IS 'Versione O.S.';


--
-- Name: COLUMN cars_info.tbox_sw; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.tbox_sw IS 'Versione Firmware Box GPRS';


--
-- Name: COLUMN cars_info.tbox_hw; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.tbox_hw IS 'Versione Hardware Box GPRS';


--
-- Name: COLUMN cars_info.mcu_model; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.mcu_model IS 'Modello MCU';


--
-- Name: COLUMN cars_info.mcu; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.mcu IS 'Versione Software MCU';


--
-- Name: COLUMN cars_info.vehicle_type; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.vehicle_type IS 'Modello Automobile';


--
-- Name: COLUMN cars_info.gps; Type: COMMENT; Schema: public; Owner: cs
--

COMMENT ON COLUMN cars_info.gps IS 'Fonte Coordinate GPS ( INT=Android | EXT=GPRS Box )';
;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191441_create_countries_code_seq.sql
CREATE SEQUENCE countries_code_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191456_create_urban_areas.sql

CREATE TABLE urban_areas (
    id integer NOT NULL,
    id_fleet integer NOT NULL,
    area geometry(Polygon,4326),
    id_area numeric(6,0),
    name character varying(100),
    area_ha numeric(18,5),
    area_mq numeric(18,5)
);

CREATE SEQUENCE urban_areas_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE urban_areas_id_seq OWNED BY urban_areas.id;

ALTER TABLE ONLY urban_areas ALTER COLUMN id SET DEFAULT nextval('urban_areas_id_seq'::regclass);

ALTER TABLE ONLY urban_areas
    ADD CONSTRAINT urban_areas_pkey PRIMARY KEY (id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191456_create_zone_groups.sql
CREATE SEQUENCE zone_groups_id_seq
    START WITH 13
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE zone_groups (
    id integer DEFAULT nextval('zone_groups_id_seq'::regclass) NOT NULL,
    description text,
    fleet_id integer,
    company_id integer,
    close_trip boolean DEFAULT true NOT NULL,
    id_zone integer[]
);


ALTER TABLE ONLY zone_groups
    ADD CONSTRAINT zone_groups_pk PRIMARY KEY (id);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191456_create_zone_price.sql
CREATE SEQUENCE zone_price_id_seq
    START WITH 2
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE zone_price (
    id integer DEFAULT nextval('zone_price_id_seq'::regclass) NOT NULL,
    id_group_open integer,
    id_group_close integer,
    cost numeric,
    bonus numeric,
    note text
);

ALTER TABLE ONLY zone_price
    ADD CONSTRAINT pk_zone_price PRIMARY KEY (id);

ALTER TABLE ONLY zone_price
    ADD CONSTRAINT unique_zone_price UNIQUE (id_group_open, id_group_close);


;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191456_create_zones.sql
CREATE SEQUENCE zone_id_seq
    START WITH 17
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE zone (
    id integer DEFAULT nextval('zone_id_seq'::regclass) NOT NULL,
    name text,
    area_invoice geometry,
    id_parent integer,
    active boolean,
    hidden boolean,
    invoice_description text,
    rev_geo boolean DEFAULT false NOT NULL,
    area_use geometry
);


;
--- D:\wamp\www\publiclocal\public\data\migrations/201604191636_promocodes_discount_percentage.sql
ALTER TABLE promo_codes_info ADD discount_percentage INT DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201605251505_add_customers_bonus_packages_field.sql
ALTER TABLE customers_bonus_packages ADD name TEXT DEFAULT NULL;;
--- D:\wamp\www\publiclocal\public\data\migrations/201606091510_italian_tax_code_functions.sql
-- Function: public.cf_calcolo_nome(nome)

-- DROP FUNCTION public.cf_calcolo_nome(text);

CREATE OR REPLACE FUNCTION public.cf_calcolo_nome(nome text)
RETURNS text AS
$BODY$
	DECLARE
        i integer;
        y integer;
        n_ascii integer;
        v_cara char(1);
        v_vocali text;
        v_consonanti varchar(4);
        v_cod_fis text;
	BEGIN
        i := 0;
        y := 0; 

        while i < length(nome) and y <> 4 loop
            v_cara  := substr(upper(nome), i+1, 1); -- estraggo il carattere
            n_ascii := ascii(v_cara); -- estraggo il codice ascii
            -- controllo se il codice ascii appartiene al range di valori accettati compreso fra 65 e 90
            if(n_ascii > 64 and n_ascii < 91) then
                -- controllo se il codice ascii è una vocale
                if(
                    n_ascii = 65 or
                    n_ascii = 69 or
                    n_ascii = 73 or
                    n_ascii = 79 or
                    n_ascii = 85 ) then
                        v_vocali := concat(v_vocali,v_cara);
                    else
                        v_consonanti := concat(v_consonanti,v_cara);
                        y := y + 1;
                end if;
            end if;
            i := i + 1;
        end loop;

        -- assegno il valore del codice fiscale
        IF( length(v_consonanti)>3 ) THEN
            v_cod_fis := substr(upper(v_consonanti), 1, 1);
            v_cod_fis := concat(v_cod_fis,substr(upper(v_consonanti), 3, 2));
        ELSE
            v_cod_fis := substr(concat(v_consonanti,v_vocali), 1, 3);
            while length(v_cod_fis) < 3 loop
                v_cod_fis := concat(v_cod_fis,'X');
            end loop;
        END IF;

    RETURN(v_cod_fis);

    EXCEPTION WHEN OTHERS THEN RETURN('CF-002');
END;
$BODY$
LANGUAGE plpgsql STABLE STRICT
COST 100;

ALTER FUNCTION public.cf_calcolo_nome(text) OWNER TO sharengo;

-- Function: public.cf_calcolo_cognome(cognome)

-- DROP FUNCTION public.cf_calcolo_cognome(text);

CREATE OR REPLACE FUNCTION public.cf_calcolo_cognome(cognome text)
RETURNS text AS
$BODY$
	DECLARE
        i integer;
        y integer;
        z integer;
        n_ascii integer;
        v_cara char(1);
        v_vocali text;
        v_consonanti varchar(3);
        v_cod_fis text;
	BEGIN
        i := 0;
        y := 0; 
        z := 0;

        while i < length(cognome) and y <> 3 loop
            v_cara  := substr(upper(cognome), i+1, 1); -- estraggo il carattere
            n_ascii := ascii(v_cara); -- estraggo il codice ascii
            -- controllo se il codice ascii appartiene al range di valori accettati compreso fra 65 e 90
            if(n_ascii > 64 and n_ascii < 91) then
                -- controllo se il codice ascii è una vocale
                if(
                    n_ascii = 65 or
                    n_ascii = 69 or
                    n_ascii = 73 or
                    n_ascii = 79 or
                    n_ascii = 85 ) then
                        v_vocali := concat(v_vocali,v_cara);
                    else
                        v_consonanti := concat(v_consonanti,v_cara);
                        y := y + 1;
                end if;  
            end if;
            i := i + 1;
        end loop;
        --assegno il valore del codice fiscale
        v_cod_fis := substr(concat(v_consonanti,v_vocali), 1, 3);

        while length(v_cod_fis) < 3  loop 
            v_cod_fis := concat(v_cod_fis, 'X');
        end loop;
 
        RETURN(v_cod_fis);

        EXCEPTION WHEN OTHERS THEN RETURN('CF-001');
END;
$BODY$
LANGUAGE plpgsql STABLE STRICT
COST 100;

ALTER FUNCTION public.cf_calcolo_cognome(text) OWNER TO sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201606141828_add_no_standard_bonus_promo_codes.sql
ALTER TABLE promo_codes_info ADD no_standard_bonus BOOLEAN DEFAULT FALSE;;
--- D:\wamp\www\publiclocal\public\data\migrations/201606201702_old_customer_discounts.sql
CREATE SEQUENCE old_customer_discounts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE TABLE old_customer_discounts (
    id INT DEFAULT nextval('old_customer_discounts_id_seq'::regclass) NOT NULL,
    customer_id INT REFERENCES customers(id),
    discount INT,
    obsolete_from TIMESTAMP(0) WITHOUT TIME ZONE,
    PRIMARY KEY(id)
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201606231050_create_messages_outbox.sql
CREATE TABLE messages_transports
(
  name text NOT NULL,
  description text,
  CONSTRAINT messages_transports_pk PRIMARY KEY (name)
);

ALTER TABLE messages_transports OWNER TO sharengo;

CREATE TABLE messages_types
(
  name text NOT NULL,
  description text,
  default_transport text,
  CONSTRAINT messages_types_pk PRIMARY KEY (name),
  CONSTRAINT default_transport_fk FOREIGN KEY (default_transport)
      REFERENCES messages_transports (name) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE messages_types OWNER TO sharengo;

COMMENT ON COLUMN messages_types.default_transport IS 'The default transport to use to send this message type.
Can be overrided by any "messages_transports" records, specifing the transport in the homonym field.';

CREATE TABLE messages_outbox
(
  id serial NOT NULL,
  transport text,
  destination text,
  type text,
  subject text,
  text text,
  submitted timestamp with time zone,
  sent timestamp with time zone,
  acknowledged timestamp with time zone,
  meta jsonb,
  sent_meta jsonb,
  CONSTRAINT messages_outbox_pk PRIMARY KEY (id),
  CONSTRAINT transport_fk FOREIGN KEY (transport)
      REFERENCES messages_transports (name) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT type_fk FOREIGN KEY (type)
      REFERENCES messages_types (name) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION
);

ALTER TABLE messages_outbox OWNER TO sharengo;

COMMENT ON COLUMN messages_outbox.sent_meta IS 'This field contains send information in JSON type.
Shoud countain for example send errors. ';
;
--- D:\wamp\www\publiclocal\public\data\migrations/201606271239_changed_messages_outbox_datetime_types.sql
ALTER TABLE messages_outbox
    ALTER COLUMN submitted TYPE timestamp(0) with time zone,
    ALTER COLUMN sent TYPE timestamp(0) with time zone,
    ALTER COLUMN acknowledged TYPE timestamp(0) with time zone;;
--- D:\wamp\www\publiclocal\public\data\migrations/201606280906_discount_state_table.sql
CREATE SEQUENCE discount_state_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE discount_state_id_seq OWNER TO sharengo;

CREATE TABLE discount_state (
    id INT DEFAULT nextval('discount_state_id_seq'::regclass) NOT NULL,
    customer_id INT REFERENCES customers(id),
    discount_state VARCHAR(255),
    PRIMARY KEY(id)
);

ALTER TABLE discount_state OWNER TO sharengo;;
--- D:\wamp\www\publiclocal\public\data\migrations/201606281040_create_poi_field_type_group.sql
ALTER TABLE pois
    ADD COLUMN type_group text;;
--- D:\wamp\www\publiclocal\public\data\migrations/201607111404_fix_trip_payment_canceled.sql
ALTER TABLE trip_payments_canceled
ALTER COLUMN first_payment_try_ts
DROP NOT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201607111700_add_display_priority_on_packages.sql
ALTER TABLE customers_bonus_packages
    ADD COLUMN display_priority INTEGER NOT NULL DEFAULT 0;;
--- D:\wamp\www\publiclocal\public\data\migrations/201607151500_add_messages_outbox_trigger_and_notification_function.sql
CREATE OR REPLACE FUNCTION notifynewmessage()
RETURNS trigger AS
$BODY$
DECLARE
BEGIN
  PERFORM pg_notify(CAST('message_outbox' AS text),CAST(NEW.id AS text)|| ',true');
  RETURN NEW;
END;
$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

ALTER FUNCTION notifynewmessage()
  OWNER TO sharengo;

CREATE TRIGGER notifynewmessage
  AFTER INSERT
  ON public.messages_outbox
  FOR EACH ROW
  EXECUTE PROCEDURE public.notifynewmessage();;
--- D:\wamp\www\publiclocal\public\data\migrations/201607151500_add_messages_transports_column.sql
ALTER TABLE messages_transports ADD COLUMN options jsonb;;
--- D:\wamp\www\publiclocal\public\data\migrations/201607181542_create_carrefour_used_codes.sql
CREATE TABLE carrefour_used_codes (
    id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(id),
    customers_bonus_id INT NOT NULL REFERENCES customers_bonus(id),
    code VARCHAR(24) UNIQUE NOT NULL,
    inserted_ts TIMESTAMP(0) WITHOUT TIME ZONE NOT NULL
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201607220958_add_cars_maintenance_end_fields.sql
ALTER TABLE cars_maintenance
ADD end_webuser_id INT REFERENCES webuser (id) DEFAULT NULL;

ALTER TABLE cars_maintenance
ADD end_ts timestamp(0) DEFAULT NULL;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505121144_create_countries_table.data
INSERT INTO countries (code, name) VALUES
('it', 'Italia'),
('af', 'Afghanistan'),
('ax', 'Isole &Aring;land'),
('al', 'Albania'),
('dz', 'Algeria'),
('as', 'Samoa Americane'),
('ad', 'Andorra'),
('ao', 'Angola'),
('ai', 'Anguilla'),
('aq', 'Antartide'),
('ag', 'Antigua e Barbuda'),
('ar', 'Argentina'),
('am', 'Armenia'),
('aw', 'Aruba'),
('au', 'Australia'),
('at', 'Austria'),
('az', 'Azerbaigian'),
('bs', 'Bahamas'),
('bh', 'Bahrein'),
('bd', 'Bangladesh'),
('bb', 'Barbados'),
('by', 'Bielorussia'),
('be', 'Belgio'),
('bz', 'Belize'),
('bj', 'Benin'),
('bm', 'Bermuda'),
('bt', 'Bhutan'),
('bo', 'Bolivia'),
('ba', 'Bosnia Erzegovina'),
('bw', 'Botswana'),
('bv', 'Isola Bouvet'),
('br', 'Brasile'),
('vg', 'Isole Vergini Britanniche'),
('bn', 'Brunei'),
('bg', 'Bulgaria'),
('bf', 'Burkina Faso'),
('bi', 'Burundi'),
('kh', 'Cambogia'),
('cm', 'Camerun'),
('ca', 'Canada'),
('cv', 'Capo Verde'),
('ky', 'Isole Cayman'),
('cf', 'Repubblica Centrafricana'),
('td', 'Ciad'),
('cl', 'Cile'),
('cn', 'Cina'),
('cx', 'Isola di Natale'),
('cc', 'Isole Cocos (Keeling)'),
('co', 'Colombia'),
('km', 'Comore'),
('cg', 'Congo'),
('ck', 'Isole Cook'),
('cr', 'Costa Rica'),
('hr', 'Croazia'),
('cy', 'Cipro'),
('cz', 'Repubblica Ceca'),
('cd', 'Repubblica Democratica del Congo'),
('dk', 'Danimarca'),
('dj', 'Gibuti'),
('dm', 'Dominica'),
('do', 'Repubblica Dominicana'),
('tl', 'Timor Est'),
('ec', 'Ecuador'),
('eg', 'Egitto'),
('sv', 'El Salvador'),
('gq', 'Guinea Equatoriale'),
('er', 'Eritrea'),
('ee', 'Estonia'),
('et', 'Etiopia'),
('fk', 'Isole Falkland'),
('fo', 'Isole Faroe'),
('fm', 'Micronesia, Stati Federati della'),
('fj', 'Isole Figi'),
('fi', 'Finlandia'),
('fr', 'Francia'),
('gf', 'Guiana Francese'),
('pf', 'Polinesia Francese'),
('tf', 'Territori Australi Francesi'),
('ga', 'Gabon'),
('gm', 'Gambia'),
('ge', 'Georgia'),
('de', 'Germania'),
('gh', 'Ghana'),
('gi', 'Gibilterra'),
('gr', 'Grecia'),
('gl', 'Groenlandia'),
('gd', 'Grenada'),
('gp', 'Guadalupa'),
('gu', 'Guam'),
('gt', 'Guatemala'),
('gn', 'Guinea'),
('gw', 'Guinea-Bissau'),
('gy', 'Guyana'),
('ht', 'Haiti'),
('hm', 'Isole Heard e McDonald'),
('hn', 'Honduras'),
('hk', 'Hong Kong'),
('hu', 'Ungheria'),
('is', 'Islanda'),
('in', 'India'),
('id', 'Indonesia'),
('iq', 'Iraq'),
('xe', 'Zona neutra Iraq-Arabia Saudita'),
('ie', 'Irlanda'),
('il', 'Israele'),
('jm', 'Giamaica'),
('jp', 'Giappone'),
('jo', 'Giordania'),
('kz', 'Kazakistan'),
('ke', 'Kenya'),
('ki', 'Kiribati'),
('kw', 'Kuwait'),
('kg', 'Kirghizistan'),
('la', 'Laos'),
('lv', 'Lettonia'),
('lb', 'Libano'),
('ls', 'Lesotho'),
('lr', 'Liberia'),
('ly', 'Libia'),
('li', 'Liechtenstein'),
('lt', 'Lituania'),
('lu', 'Lussemburgo'),
('mo', 'Macau'),
('mk', 'Macedonia'),
('mg', 'Madagascar'),
('mw', 'Malawi'),
('my', 'Malesia'),
('mv', 'Maldive'),
('ml', 'Mali'),
('mt', 'Malta'),
('mh', 'Isole Marshall'),
('mq', 'Martinica'),
('mr', 'Mauritania'),
('mu', 'Mauritius'),
('yt', 'Mayotte'),
('mx', 'Messico'),
('md', 'Moldova'),
('mc', 'Monaco'),
('mn', 'Mongolia'),
('ms', 'Montserrat'),
('ma', 'Marocco'),
('mz', 'Mozambico'),
('mm', 'Myanmar (Birmania)'),
('na', 'Namibia'),
('nr', 'Nauru'),
('np', 'Nepal'),
('nl', 'Paesi Bassi'),
('an', 'Antille Olandesi'),
('nc', 'Nuova Caledonia'),
('nz', 'Nuova Zelanda'),
('ni', 'Nicaragua'),
('ne', 'Niger'),
('ng', 'Nigeria'),
('nu', 'Niue'),
('nf', 'Isola Norfolk'),
('kp', 'Corea del Nord'),
('mp', 'Isole Marianne Settentrionali'),
('no', 'Norvegia'),
('om', 'Oman'),
('pk', 'Pakistan'),
('pw', 'Palau'),
('pa', 'Panama'),
('pg', 'Papua Nuova Guinea'),
('py', 'Paraguay'),
('pe', 'Peru'),
('ph', 'Filippine'),
('pn', 'Isola Pitcairn'),
('pl', 'Polonia'),
('pt', 'Portogallo'),
('pr', 'Puerto Rico'),
('qa', 'Qatar'),
('re', 'Reunion'),
('ro', 'Romania'),
('ru', 'Russia'),
('rw', 'Ruanda'),
('kn', 'St. Kitts e Nevis'),
('lc', 'St. Lucia'),
('pm', 'St. Pierre e Miquelon'),
('vc', 'St. Vincent e Grenadine'),
('ws', 'Samoa'),
('sm', 'San Marino'),
('st', 'Sao Tome e Principe'),
('sa', 'Arabia Saudita'),
('sn', 'Senegal'),
('cs', 'Serbia e Montenegro'),
('sc', 'Seychelles'),
('sl', 'Sierra Leone'),
('sg', 'Singapore'),
('sk', 'Slovacchia'),
('si', 'Slovenia'),
('sb', 'Isole Solomon'),
('so', 'Somalia'),
('za', 'Sud Africa'),
('kr', 'Corea del Sud'),
('es', 'Spagna'),
('pi', 'Isole Spratly'),
('lk', 'Sri Lanka'),
('sr', 'Suriname'),
('sj', 'Isole Svalbard e Jan Mayen'),
('sz', 'Swaziland'),
('se', 'Svezia'),
('ch', 'Svizzera'),
('sy', 'Siria'),
('tw', 'Taiwan'),
('tj', 'Tagikistan'),
('tz', 'Tanzania'),
('th', 'Thailandia'),
('tg', 'Togo'),
('tk', 'Isole Tokelau'),
('to', 'Tonga'),
('tt', 'Trinidad e Tobago'),
('tn', 'Tunisia'),
('tr', 'Turchia'),
('tm', 'Turkmenistan'),
('tc', 'Isole Turks e Caicos'),
('tv', 'Tuvalu'),
('ug', 'Uganda'),
('ua', 'Ucraina'),
('ae', 'Emirati Arabi Uniti'),
('uk', 'Regno Unito'),
('xd', 'Zona neutra ONU'),
('us', 'Stati Uniti'),
('um', 'Isole minori degli Stati Uniti'),
('uy', 'Uruguay'),
('vi', 'Isole Vergini Statunitensi'),
('uz', 'Uzbekistan'),
('vu', 'Vanuatu'),
('va', 'Citta&agrave; del Vaticano'),
('ve', 'Venezuela'),
('vn', 'Vietnam'),
('wf', 'Isole Wallis e Futuna'),
('wh', 'Sahara Occidentale'),
('ye', 'Yemen'),
('zm', 'Zambia'),
('zw', 'Zimbabwe'),
('ir', 'Iran');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505191748_create_provinces_table.data
INSERT INTO provinces (code, name) VALUES
('AG','Agrigento'),
('AL','Alessandria'),
('AN','Ancona'),
('AO','Aosta'),
('AQ','L`Aquila'),
('AR','Arezzo'),
('AP','Ascoli-Piceno'),
('AT','Asti'),
('AV','Avellino'),
('BA','Bari'),
('BT','Barletta-Andria-Trani'),
('BL','Belluno'),
('BN','Benevento'),
('BG','Bergamo'),
('BI','Biella'),
('BO','Bologna'),
('BZ','Bolzano'),
('BS','Brescia'),
('BR','Brindisi'),
('CA','Cagliari'),
('CL','Caltanissetta'),
('CB','Campobasso'),
('CI','Carbonia Iglesias'),
('CE','Caserta'),
('CT','Catania'),
('CZ','Catanzaro'),
('CH','Chieti'),
('CO','Como'),
('CS','Cosenza'),
('CR','Cremona'),
('KR','Crotone'),
('CN','Cuneo'),
('EN','Enna'),
('FM','Fermo'),
('FE','Ferrara'),
('FI','Firenze'),
('FG','Foggia'),
('FC','Forli-Cesena'),
('FR','Frosinone'),
('GE','Genova'),
('GO','Gorizia'),
('GR','Grosseto'),
('IM','Imperia'),
('IS','Isernia'),
('SP','La-Spezia'),
('LT','Latina'),
('LE','Lecce'),
('LC','Lecco'),
('LI','Livorno'),
('LO','Lodi'),
('LU','Lucca'),
('MC','Macerata'),
('MN','Mantova'),
('MS','Massa-Carrara'),
('MT','Matera'),
('VS','Medio Campidano'),
('ME','Messina'),
('MI','Milano'),
('MO','Modena'),
('MB','Monza-Brianza'),
('NA','Napoli'),
('NO','Novara'),
('NU','Nuoro'),
('OG','Ogliastra'),
('OT','Olbia Tempio'),
('OR','Oristano'),
('PD','Padova'),
('PA','Palermo'),
('PR','Parma'),
('PV','Pavia'),
('PG','Perugia'),
('PU','Pesaro-Urbino'),
('PE','Pescara'),
('PC','Piacenza'),
('PI','Pisa'),
('PT','Pistoia'),
('PN','Pordenone'),
('PZ','Potenza'),
('PO','Prato'),
('RG','Ragusa'),
('RA','Ravenna'),
('RC','Reggio-'),
('RE','Reggio-Emilia'),
('RI','Rieti'),
('RN','Rimini'),
('RM','Roma'),
('RO','Rovigo'),
('SA','Salerno'),
('SS','Sassari'),
('SV','Savona'),
('SI','Siena'),
('SR','Siracusa'),
('SO','Sondrio'),
('TA','Taranto'),
('TE','Teramo'),
('TR','Terni'),
('TO','Torino'),
('TP','Trapani'),
('TN','Trento'),
('TV','Treviso'),
('TS','Trieste'),
('UD','Udine'),
('VA','Varese'),
('VE','Venezia'),
('VB','Verbania'),
('VC','Vercelli'),
('VR','Verona'),
('VV','Vibo-Valentia'),
('VI','Vicenza'),
('VT','Viterbo'),
('EE','Estero')
;
--- D:\wamp\www\publiclocal\public\data\migrations/201505261211_create_authority_table.data
INSERT INTO authority (code, name) VALUES
('DTT', 'Dipartimento dei Trasporti Terrestri'),
('MC', 'Motorizzazione Civile'),
('CO', 'Comune'),
('AE', 'Altro ente');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201506041045_add_cuba_in_countries.data
INSERT INTO countries (code, name) VALUES ('cu', 'Cuba');;
--- D:\wamp\www\publiclocal\public\data\migrations/201506061534_update_authority.data
INSERT INTO authority (code, name) VALUES ('UCO', 'Ufficio Centrale Operativo'), ('PRE', 'Prefettura');;
--- D:\wamp\www\publiclocal\public\data\migrations/201506291749_create_free_fares_table.data
INSERT INTO free_fares (conditions) VALUES
('{"customer":{"gender":"female"},"time":{"from":"00:00","to":"06:00"}}'),
('{"customer":{"birth_date":"today()"}}')
;
--- D:\wamp\www\publiclocal\public\data\migrations/201508041251_create_fares_table.data
INSERT INTO fares (id, motion_cost_per_minute, park_cost_per_minute, cost_steps)
VALUES (nextval('fares_id_seq'), 28, 10, '{"1440": 5000, "240": 3000, "60": 1200}');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201508251613_create_zone_alarms_table.data
INSERT INTO zone_alarms Values (
    nextval('zone_alarms_id_seq'::regclass),
    'MI',
    '(
        (7.965223053156447, 45.68915145978575),
        (7.983630622941107, 45.27246964462472),
        (8.325585685315209, 44.92629104348502),
        (8.963507534660105, 44.74812278972554),
        (9.668794186275632, 44.81680043259382),
        (10.09202627406631, 45.0474985061414),
        (10.30423643808943, 45.32984564294682),
        (10.31760314727177, 45.68905506333939),
        (10.15780174716197, 45.96424751530284),
        (9.699619699800547, 46.22914719310854),
        (9.150640707815853, 46.32630269019465),
        (8.600136601520561, 46.26994186580192),
        (8.173224949626611, 46.03691561326021)
    )'
);

INSERT INTO zone_alarms Values (
    nextval('zone_alarms_id_seq'::regclass),
    'FI',
    '(
        (10.44149502270095, 43.15865410027914),
        (10.844060389552, 43.12519105538249),
        (11.409778908574, 43.2366005713974),
        (11.75968205773335, 43.37349671071325),
        (11.90083216739408, 43.57085631701032),
        (11.8573187456678, 43.80699591103466),
        (11.73326483890559, 44.11082303275858),
        (11.34900520056145, 44.25746915663118),
        (10.96853366724944, 44.28768512985908),
        (10.51122229703521, 44.20217739861327),
        (10.30406529010262, 44.09460670730601),
        (10.10833699746678, 43.89133982898454),
        (10.44149502270095, 43.15865410027914)
    )'
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201508311228_create_customers_bonus_packages.data
SET datestyle = dmy;

INSERT INTO customers_bonus_packages VALUES (
    nextval('customers_bonus_packages_id_seq'::regClass),
    'CODE01',
    now(),
    1000,
    'promo',
    '02-11-2015 00:00:00',
    90,
    null,
    '31-12-2015 23:59:59',
    'Pacchetto bonus da 1000 minuti',
    10000
);

;
--- D:\wamp\www\publiclocal\public\data\migrations/201509081634_create_penalties_table.data
INSERT INTO penalties VALUES
(nextval('penalties_id_seq'), 'Notifica sanzioni e multe', 2000),
(nextval('penalties_id_seq'), 'Gestione pratiche rimozione veicolo o danni autoinflitti', 5000),
(nextval('penalties_id_seq'), 'Riattivazione del servizio, occorsa per sospensione patente, sospensione per mancati pagamenti, etc ', 2000),
(nextval('penalties_id_seq'), 'Pulizia straordinaria', 5000),
(nextval('penalties_id_seq'), 'Sanificazione dovuta a trasporto animali', 15000),
(nextval('penalties_id_seq'), 'Fumare all''interno del veicolo', 5000),
(nextval('penalties_id_seq'), 'Rilascio del veicolo con luci accese o finestrini abbassati', 5000),
(nextval('penalties_id_seq'), 'Rimozione del veicolo in caso di parcheggio in divieto di sosta o in area privata', 10000),
(nextval('penalties_id_seq'), 'Rimozione forzata del veicolo a seguito di una infrazione', 10000),
(nextval('penalties_id_seq'), 'Rilascio del veicolo senza aver terminato correttamente la procedura', 5000),
(nextval('penalties_id_seq'), 'Soccorso stradale perch&egrave; il Cliente non avendo osservato il segnale di riserva ha lasciato il veicolo con carica/autonomia inferiore al 10%', 12000),
(nextval('penalties_id_seq'), 'Soccorso stradale per danni causati dal Cliente, con o senza controparte (CID passivo)', 10000),
(nextval('penalties_id_seq'), 'Smarrimento o danneggiamento dei documenti del veicolo', 5000),
(nextval('penalties_id_seq'), 'Smarrimento cavo elettrico di emergenza sito nel baule', 5000),
(nextval('penalties_id_seq'), 'Smarrimento Kit di emergenza sito nel baule', 5000),
(nextval('penalties_id_seq'), 'Mancato rispetto delle istruzioni ricevute dal servizio clienti SHAREN''GO o dall''operatore intervenuto sul posto in caso di guasto o incidente', 5000),
(nextval('penalties_id_seq'), 'Estrazione o smarrimento della chiave di accensione', 25000),
(nextval('penalties_id_seq'), 'Guida all''estero', 25000),
(nextval('penalties_id_seq'), 'Guida del veicolo da parte di soggetto diverso da quello che ha effettuato la prenotazione', 10000),
(nextval('penalties_id_seq'), 'Gestione sinistri non comunicati dal Cliente', 10000),
(nextval('penalties_id_seq'), 'Recupero del veicolo fuori dall''area di copertura della citt&agrave; per responsabilit&agrave; del Cliente', NULL),
(nextval('penalties_id_seq'), 'Mancata pronta restituzione a seguito di richiesta del servizio clienti SHAREN''GO', NULL),
(nextval('penalties_id_seq'), 'Dichiarazioni verificatesi inequivocabilmente false in fase di profilazione-registrazione', NULL),
(nextval('penalties_id_seq'), 'Utilizzazione notturna da parte di un utente di sesso maschile di un auto a tariffa gratuita utilizzando i codici d''uso e accesso di un utente di sesso femminile', NULL),
(nextval('penalties_id_seq'), 'Affidamento del veicolo a minore anche se in possesso di patente B1', NULL);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201509201441_create_fleet_table.data
INSERT INTO fleets(id, code, name) VALUES(nextval('fleet_id_seq'), 'MI', 'Milano');
INSERT INTO fleets(id, code, name) VALUES(nextval('fleet_id_seq'), 'FI', 'Firenze');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510011905_insert_promo_codes.data
INSERT INTO promo_codes_info (id, active, insert_ts, type, minutes, valid_from, valid_to, overridden_subscription_cost) VALUES
(nextval('promocodesinfo_id_seq'::regclass),true, '2015-10-02 00:00:00', 'promo', 0, '2015-10-02 00:00:00', '2016-10-02 00:00:00', 100);


INSERT INTO promo_codes Values(
    nextval('promocodes_id_seq'::regclass),
    (select id from promo_codes_info order by id desc limit 1), -- usare l'id del promo_codes_info appena creato
    'BKGO',
    'Iscrizione ad 1 euro per soci BikeMi',
    true
);

INSERT INTO promo_codes Values(
    nextval('promocodes_id_seq'::regclass),
    (select id from promo_codes_info order by id desc limit 1), -- usare l'id del promo_codes_info appena creato
    'ELFO',
    'Iscrizione ad 1 euro per soci Teatro dell''Elfo Puccini',
    true
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510051610_invoice_number_table.data
/* change 4310 to match the last invoice number value */
INSERT INTO invoice_number (year, fleet_id, number) VALUES
(2015, 1, 4310);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510061402_fix_zone_alarms.data
/**
 * Check that the values are the same in production.
 * In this case the first 1 is for the Milano zone and the second 1 is for the
 * Milano fleet
 */
INSERT INTO zone_alarms_fleets Values(
    1,
    1
);
/**
 * In this case the first 2 is for the Firenze zone and the second 2 is for the
 * Firenze fleet
 */
INSERT INTO zone_alarms_fleets Values(
    2,
    2
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510101721_insert_promo_code_100fi.data
INSERT INTO promo_codes_info (id, active, insert_ts, type, minutes, valid_from, valid_to, overridden_subscription_cost) VALUES
(nextval('promocodesinfo_id_seq'::regclass),true, '2015-10-10 17:21:00', 'promo', 0, '2015-10-12 00:00:00', '2015-12-31 23:59:59', 100);


INSERT INTO promo_codes Values(
    nextval('promocodes_id_seq'::regclass),
    (select id from promo_codes order by id desc limit 1), --  usare l'id del promo_codes_info appena creato
    '100FI',
    'Iscrizione ad 1 euro per evento top 100 Firenze',
    true
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510231525_add_promo_code.data
INSERT INTO promo_codes_info (id, active, insert_ts, type, minutes, valid_from, valid_to, overridden_subscription_cost, bonus_valid_from, bonus_valid_to) VALUES
(nextval('promocodesinfo_id_seq'::regclass),true, '2015-10-23 00:00:00', 'promo', 0, '2015-10-23 00:00:00', '2016-01-23 23:59:59', 100, '2015-10-23 00:00:00', '2016-01-23 23:59:59');

INSERT INTO promo_codes Values(
    nextval('promocodes_id_seq'),
    (select id from promo_codes_info order by id desc limit 1),
    'LNGO',
    'Iscrizione ad 1 euro per soci Linear',
    true
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510270937_add_cars_damages.data
INSERT INTO cars_damages (name) VALUES ('Paraurti anteriore'), ('Paraurti posteriore'), ('Parafango anteriore des'), ('Parafango anteriore sin'), ('Parafango posteriore des'), ('Parafango posteriore sin'), ('Porta des'), ('Porta sin'), ('Portellone posteriore'), ('Specchietto des'), ('Specchietto sin'), ('Sportello benzina'), ('Tergicristalli anteriori'), ('Parabrezza'), ('Lunotto posteriore');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201510281559_add_promo_code.data
INSERT INTO promo_codes Values(
    nextval('promocodes_id_seq'),
    6,
    'FITEST',
    'Iscrizione ad 1 euro per promo Elettra',
    true
);
;
--- D:\wamp\www\publiclocal\public\data\migrations/201511091546_insert_subscription_payments.data
insert into subscription_payments
select nextval('subscription_payments_id_seq'), c.id, c.fleet_id, t.id, t.amount, now()
from customers c
join contracts co on co.customer_id = c.id
join transactions t on t.contract_id = co.id and (t.amount = 1000 or t.amount = 100) and t.outcome = 'OK'
where c.first_payment_completed = true
order by c.id;
--- D:\wamp\www\publiclocal\public\data\migrations/201511101940_create_bonus_package_payments.data
/**
 * Populate the table with existing data from other tables
 */
INSERT INTO bonus_package_payments
SELECT nextval('bonus_package_payments_id_seq'::regclass),
    c.id,
    cb.id,
    cb.package_id,
    c.fleet_id,
    cb.transaction_id,
    cb.invoice_id,
    cb.invoiced_at,
    cb.total,
    now()
FROM customers_bonus cb
LEFT JOIN customers c ON c.id = cb.customer_id
WHERE cb.package_id IS NOT NULL
ORDER BY cb.insert_ts ASC;

;
--- D:\wamp\www\publiclocal\public\data\migrations/201511260918_create_customer_deactivations.data
/**
 * Customers disabled for late payment
 */
INSERT INTO customer_deactivations
SELECT nextval('customer_deactivations_id_seq'),
    now(),
    c.id,
    'FAILED_PAYMENT',
    now(),
    NULL,
    NULL,
    NULL,
    ('{"deactivation":{"trip_payment_try_id":"' || COALESCE(max(tpt.id)::text, '') || '","note":"Generated automatically"}}')::jsonb
FROM customers c
LEFT JOIN trips t ON c.id = t.customer_id
LEFT JOIN trip_payments tp ON t.id = tp.trip_id
LEFT JOIN trip_payment_tries tpt ON tp.id = tpt.trip_payment_id
WHERE c.enabled = false
AND c.payment_able = false
AND c.first_payment_completed = true
AND c.maintainer = false
AND (tpt.outcome = 'KO' OR tpt IS NULL)
GROUP BY c.id;

INSERT INTO customer_deactivations
SELECT nextval('customer_deactivations_id_seq'),
    now(),
    c.id,
    'FAILED_PAYMENT',
    now(),
    NULL,
    NULL,
    NULL,
    '{"deactivation":{"trip_payment_try_id":"","note":"Generated automatically"}}'
FROM customers c
LEFT JOIN trips t ON c.id = t.customer_id
LEFT JOIN trip_payments tp ON t.id = tp.trip_id
LEFT JOIN trip_payment_tries tpt ON tp.id = tpt.trip_payment_id
WHERE c.enabled = false
AND c.payment_able = false
AND c.first_payment_completed = true
AND c.maintainer = false
AND (tpt.outcome = 'KO' OR tpt IS NULL)
GROUP BY c.id;

/**
 * Customers disabled by webusers
 */
INSERT INTO customer_deactivations
SELECT nextval('customer_deactivations_id_seq'),
    now(),
    c.id,
    'DISABLED_BY_WEBUSER',
    now(),
    NULL,
    NULL,
    NULL,
    '{"deactivation":{"note":"Generated automatically"}}'
FROM customers c
WHERE c.enabled = false
AND c.payment_able = true
AND c.first_payment_completed = true
AND c.maintainer = false;

/**
 * Customers not yet enabled after registration
 */
INSERT INTO customer_deactivations
SELECT nextval('customer_deactivations_id_seq'),
    now(),
    c.id,
    'FIRST_PAYMENT_NOT_COMPLETED',
    now(),
    NULL,
    NULL,
    NULL,
    '{"deactivation":{"note":"Generated automatically"}}'
FROM customers c
WHERE c.enabled = false
AND c.first_payment_completed = false
AND c.maintainer = false;
;
--- D:\wamp\www\publiclocal\public\data\migrations/201511271227_create_table_configuration.data
/**
 * Populate the table with existing data
 */
INSERT INTO configurations VALUES (1, 'alarm', 'battery', '20');
INSERT INTO configurations VALUES (2, 'alarm', 'delay', '31');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201602081036_add_events_types_table.data
/**
 * Add base events types
 */
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (1, 'SW_BOOT', '', 'Reboot OBC ver. {txtval}', 'Riavvio dell''applicazione OBC con in txtval la versione del SW OBC a bordo');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (2, 'RFID', 'intval=1', 'Inizio CORSA', 'Apertura corsa da CARD con CODICE RFID AABBCC');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (3, 'RFID', 'intval=2', 'Fine CORSA', 'Chiusura corsa da CARD con CODICE RFID AABBCC');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (5, 'RFID', 'intval=4', 'Fine SOSTA', 'Passaggio CARD con CODICE RFID AABBCC per disattivare la SOSTA');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (6, 'RFID', 'intval=5', 'RFID non permesso', 'Passaggio CARD con CODICE RFID AABBCC diversa da quella che ha aperto la corsa');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (7, 'PARK', 'intval=1', 'Tasto inizio SOSTA', 'Premuto il tasto a bordo per mettere in SOSTA');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (8, 'PARK', 'intval=2', 'Tasto fine SOSTA', 'Premuto il tasto a bordo per riprendere la corsa dalla SOSTA');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (9, 'CLEANLINESS', 'txtval=0;0', 'IN:VERDE - OUT:VERDE', 'Valutazione Pulizia IN;OUT [0=verde - 1=giallo - 2=rosso]');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (10, 'CLEANLINESS', 'txtval=1;1', 'IN:GIALLO - OUT:GIALLO', 'Valutazione Pulizia IN;OUT [0=verde - 1=giallo - 2=rosso]');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (11, 'CLEANLINESS', 'txtval=0;1', 'IN:VERDE - OUT:GIALLO', 'Valutazione Pulizia IN;OUT [0=verde - 1=giallo - 2=rosso]');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (12, 'CLEANLINESS', 'txtval=1;0', 'IN:GIALLO - OUT:VERDE', 'Valutazione Pulizia IN;OUT [0=verde - 1=giallo - 2=rosso]');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (13, 'GEAR', 'txtval=N', 'Cambio: FOLLE', 'Cambio Marcia - NO GEAR');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (14, 'GEAR', 'txtval=D', 'Cambio: PRIMA', 'Cambio Marcia - DRIVE');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (15, 'GEAR', 'txtval=R', 'Cambio: RETRO', 'Cambio Marcia - REVERSE');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (16, 'KEY', 'intval=1', 'Quadro: Posizione 1', 'Chiave in posizione 1');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (17, 'KEY', 'intval=2', 'Quadro: Posizione 2', 'Chiave in posizione 2');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (18, 'KEY', 'intval=3', 'Quadro: Posizione 3', 'Chiave in posizione 3');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (19, '3G', 'txtval=mobile', 'Riavvio 3G per {intval} volte', 'Ha ripreso la connessione internet su MOBILE dopo xx minuti (1 reset ogni 1 minuto)');
INSERT INTO events_types (id, label, map_logic, description, notes) VALUES (4, 'RFID', 'intval=3', 'Inizio SOSTA', 'Passaggio CARD con CODICE RFID AABBCC per attivare la SOSTA');
;
--- D:\wamp\www\publiclocal\public\data\migrations/201602251110_create_cartasi_csv_anomalies_notes.data
INSERT INTO cartasi_csv_anomalies_notes (cartasi_csv_anomaly_id, inserted_at, note, webuser_id)
    SELECT
        cartasi_csv_anomalies.id AS anomaly_id,
        json_data.key::timestamp AS inserted_at,
        json_data.value::json->>'content' AS content,
        CAST(json_data.value::json->>'webuser' AS INT) AS webuser
    FROM cartasi_csv_anomalies, jsonb_each_text(cartasi_csv_anomalies.updates) AS json_data;

;
--- D:\wamp\www\publiclocal\public\data\migrations/201603151700_create_foreign_dl_validations.data
INSERT INTO foreign_drivers_license_validation (foreign_drivers_license_upload_id, validated_by, validated_at)
    SELECT id, validated_by, validated_at
    FROM foreign_drivers_license_upload
    WHERE validated_by IS NOT NULL AND validated_at IS NOT NULL;
;
