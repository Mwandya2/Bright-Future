-- V1: baseline schema.
--
-- This reproduces the schema Hibernate had been generating with
-- ddl-auto=update, so a fresh database gets an identical structure.
--
-- On the existing production database this migration never runs: Flyway is
-- configured with baseline-on-migrate, so it records the current schema as
-- version 1 and only applies later versions. Every change from here on is a
-- new V-numbered file, applied in order, and a failure aborts start-up
-- instead of leaving the database half-migrated.
--
-- Generated from the JPA entities rather than written by hand, so it matches
-- what ddl-auto=validate will check against.

CREATE TABLE IF NOT EXISTS contact_messages (
    created_at timestamp(6) with time zone NOT NULL,
    id uuid NOT NULL,
    email character varying(255) NOT NULL,
    message text NOT NULL,
    name character varying(255) NOT NULL,
    subject character varying(255)
);
CREATE TABLE IF NOT EXISTS course_payments (
    amount integer NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    updated_at timestamp(6) with time zone,
    course_id uuid NOT NULL,
    id uuid NOT NULL,
    phone_number character varying(16),
    status character varying(16) NOT NULL,
    user_id uuid NOT NULL,
    order_reference character varying(64) NOT NULL,
    CONSTRAINT course_payments_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'PAID'::character varying, 'FAILED'::character varying, 'CANCELLED'::character varying])::text[])))
);
CREATE TABLE IF NOT EXISTS courses (
    duration_weeks integer,
    is_published boolean NOT NULL,
    price integer,
    created_at timestamp(6) with time zone NOT NULL,
    delivery_mode character varying(16) DEFAULT 'IN_PERSON'::character varying NOT NULL,
    id uuid NOT NULL,
    category character varying(255),
    cover_gradient character varying(255),
    description text,
    instructor_name character varying(255),
    level character varying(255) NOT NULL,
    slug character varying(255) NOT NULL,
    summary text,
    title character varying(255) NOT NULL,
    CONSTRAINT courses_delivery_mode_check CHECK (((delivery_mode)::text = ANY ((ARRAY['IN_PERSON'::character varying, 'ONLINE'::character varying])::text[]))),
    CONSTRAINT courses_level_check CHECK (((level)::text = ANY ((ARRAY['BEGINNER'::character varying, 'INTERMEDIATE'::character varying, 'ADVANCED'::character varying])::text[])))
);
CREATE TABLE IF NOT EXISTS enrollments (
    progress integer NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    course_id uuid NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    status character varying(255) NOT NULL,
    CONSTRAINT enrollments_status_check CHECK (((status)::text = ANY ((ARRAY['ACTIVE'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[])))
);
CREATE TABLE IF NOT EXISTS lab_bookings (
    booking_date date NOT NULL,
    duration_hours integer NOT NULL,
    start_time time(6) without time zone NOT NULL,
    created_at timestamp(6) with time zone NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    notes text,
    status character varying(255) NOT NULL,
    workstation_type character varying(255) NOT NULL,
    CONSTRAINT lab_bookings_status_check CHECK (((status)::text = ANY ((ARRAY['PENDING'::character varying, 'CONFIRMED'::character varying, 'COMPLETED'::character varying, 'CANCELLED'::character varying])::text[]))),
    CONSTRAINT lab_bookings_workstation_type_check CHECK (((workstation_type)::text = ANY ((ARRAY['COMPUTER'::character varying, 'GAMING'::character varying, 'RESEARCH'::character varying, 'PRINTING_STATION'::character varying])::text[])))
);
CREATE TABLE IF NOT EXISTS print_orders (
    color boolean NOT NULL,
    copies integer NOT NULL,
    estimated_price integer,
    created_at timestamp(6) with time zone NOT NULL,
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    description text,
    service_type character varying(255) NOT NULL,
    status character varying(255) NOT NULL,
    CONSTRAINT print_orders_service_type_check CHECK (((service_type)::text = ANY ((ARRAY['DOCUMENT'::character varying, 'POSTER'::character varying, 'BANNER'::character varying, 'BUSINESS_CARD'::character varying, 'PHOTO'::character varying])::text[]))),
    CONSTRAINT print_orders_status_check CHECK (((status)::text = ANY ((ARRAY['SUBMITTED'::character varying, 'IN_PROGRESS'::character varying, 'READY'::character varying, 'COLLECTED'::character varying, 'CANCELLED'::character varying])::text[])))
);
CREATE TABLE IF NOT EXISTS users (
    created_at timestamp(6) with time zone NOT NULL,
    id uuid NOT NULL,
    avatar_url character varying(255),
    email character varying(255) NOT NULL,
    full_name character varying(255),
    password_hash character varying(255) NOT NULL,
    phone character varying(255),
    role character varying(255) NOT NULL,
    CONSTRAINT users_role_check CHECK (((role)::text = ANY ((ARRAY['STUDENT'::character varying, 'INSTRUCTOR'::character varying, 'ADMIN'::character varying])::text[])))
);
ALTER TABLE ONLY contact_messages
    ADD CONSTRAINT contact_messages_pkey PRIMARY KEY (id);
ALTER TABLE ONLY course_payments
    ADD CONSTRAINT course_payments_order_reference_key UNIQUE (order_reference);
ALTER TABLE ONLY course_payments
    ADD CONSTRAINT course_payments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_pkey PRIMARY KEY (id);
ALTER TABLE ONLY courses
    ADD CONSTRAINT courses_slug_key UNIQUE (slug);
ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_pkey PRIMARY KEY (id);
ALTER TABLE ONLY enrollments
    ADD CONSTRAINT enrollments_user_id_course_id_key UNIQUE (user_id, course_id);
ALTER TABLE ONLY lab_bookings
    ADD CONSTRAINT lab_bookings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY print_orders
    ADD CONSTRAINT print_orders_pkey PRIMARY KEY (id);
ALTER TABLE ONLY users
    ADD CONSTRAINT users_email_key UNIQUE (email);
ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
CREATE INDEX IF NOT EXISTS idx_course_payments_user_course ON course_payments USING btree (user_id, course_id);
ALTER TABLE ONLY enrollments
    ADD CONSTRAINT fk3hjx6rcnbmfw368sxigrpfpx0 FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE ONLY print_orders
    ADD CONSTRAINT fk7ny4ahupxdd58qc3hroj0d6hs FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE ONLY course_payments
    ADD CONSTRAINT fkhix04adkbfbx1g6nme13awty1 FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE ONLY enrollments
    ADD CONSTRAINT fkho8mcicp4196ebpltdn9wl6co FOREIGN KEY (course_id) REFERENCES courses(id);
ALTER TABLE ONLY lab_bookings
    ADD CONSTRAINT fkrr1vx4s9ixhsu07o7geicmgli FOREIGN KEY (user_id) REFERENCES users(id);
ALTER TABLE ONLY course_payments
    ADD CONSTRAINT fksncm91smn47omwrob7i9061ol FOREIGN KEY (course_id) REFERENCES courses(id);
