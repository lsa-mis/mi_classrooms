SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

-- *not* creating schema, since initdb creates it


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: action_text_rich_texts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.action_text_rich_texts (
    id bigint NOT NULL,
    name character varying NOT NULL,
    body text,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.action_text_rich_texts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: action_text_rich_texts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.action_text_rich_texts_id_seq OWNED BY public.action_text_rich_texts.id;


--
-- Name: active_storage_attachments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_attachments (
    id bigint NOT NULL,
    name character varying NOT NULL,
    record_type character varying NOT NULL,
    record_id bigint NOT NULL,
    blob_id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_attachments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_attachments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_attachments_id_seq OWNED BY public.active_storage_attachments.id;


--
-- Name: active_storage_blobs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_blobs (
    id bigint NOT NULL,
    key character varying NOT NULL,
    filename character varying NOT NULL,
    content_type character varying,
    metadata text,
    service_name character varying NOT NULL,
    byte_size bigint NOT NULL,
    checksum character varying,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_blobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_blobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_blobs_id_seq OWNED BY public.active_storage_blobs.id;


--
-- Name: active_storage_variant_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.active_storage_variant_records (
    id bigint NOT NULL,
    blob_id bigint NOT NULL,
    variation_digest character varying NOT NULL
);


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.active_storage_variant_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: active_storage_variant_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.active_storage_variant_records_id_seq OWNED BY public.active_storage_variant_records.id;


--
-- Name: announcements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.announcements (
    id bigint NOT NULL,
    location character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: announcements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.announcements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: announcements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.announcements_id_seq OWNED BY public.announcements.id;


--
-- Name: api_update_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_update_logs (
    id bigint NOT NULL,
    result text NOT NULL,
    status character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: api_update_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_update_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_update_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_update_logs_id_seq OWNED BY public.api_update_logs.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: buildings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.buildings (
    bldrecnbr bigint NOT NULL,
    latitude double precision,
    longitude double precision,
    name character varying,
    nick_name character varying,
    abbreviation character varying,
    address character varying,
    city character varying,
    state character varying,
    zip character varying,
    country character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tsv tsvector,
    campus_record_id bigint,
    visible boolean DEFAULT true
);


--
-- Name: buildings_bldrecnbr_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.buildings_bldrecnbr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: buildings_bldrecnbr_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.buildings_bldrecnbr_seq OWNED BY public.buildings.bldrecnbr;


--
-- Name: campus_records; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campus_records (
    id bigint NOT NULL,
    campus_cd integer,
    campus_description character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: campus_records_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campus_records_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campus_records_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campus_records_id_seq OWNED BY public.campus_records.id;


--
-- Name: floors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.floors (
    id bigint NOT NULL,
    floor character varying,
    building_bldrecnbr bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: floors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.floors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: floors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.floors_id_seq OWNED BY public.floors.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    noteable_type character varying NOT NULL,
    noteable_id bigint NOT NULL,
    parent_id integer,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    alert boolean DEFAULT false
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: omni_auth_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.omni_auth_services (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    provider character varying,
    uid character varying,
    access_token character varying,
    access_token_secret character varying,
    refresh_token character varying,
    expires_at timestamp without time zone,
    auth text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: omni_auth_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.omni_auth_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: omni_auth_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.omni_auth_services_id_seq OWNED BY public.omni_auth_services.id;


--
-- Name: omniauth_services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.omniauth_services (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    provider character varying,
    uid character varying,
    access_token character varying,
    access_token_secret character varying,
    refresh_token character varying,
    expires_at timestamp without time zone,
    auth text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: omniauth_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.omniauth_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: omniauth_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.omniauth_services_id_seq OWNED BY public.omniauth_services.id;


--
-- Name: pg_search_documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pg_search_documents (
    id bigint NOT NULL,
    content text,
    searchable_type character varying,
    searchable_id bigint,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pg_search_documents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pg_search_documents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pg_search_documents_id_seq OWNED BY public.pg_search_documents.id;


--
-- Name: room_characteristics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_characteristics (
    id bigint NOT NULL,
    rmrecnbr bigint NOT NULL,
    chrstc integer,
    chrstc_eff_status integer,
    chrstc_descrshort character varying,
    chrstc_descr character varying,
    chrstc_desc254 character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: room_characteristics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_characteristics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_characteristics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_characteristics_id_seq OWNED BY public.room_characteristics.id;


--
-- Name: room_contacts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.room_contacts (
    rmrecnbr bigint NOT NULL,
    rm_schd_cntct_name character varying,
    rm_schd_email character varying,
    rm_schd_cntct_phone character varying,
    rm_det_url character varying,
    rm_usage_guidlns_url character varying,
    rm_sppt_deptid character varying,
    rm_sppt_dept_descr character varying,
    rm_sppt_cntct_email character varying,
    rm_sppt_cntct_phone character varying,
    rm_sppt_cntct_url character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    id bigint NOT NULL
);


--
-- Name: room_contacts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.room_contacts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: room_contacts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.room_contacts_id_seq OWNED BY public.room_contacts.id;


--
-- Name: rooms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rooms (
    rmrecnbr bigint NOT NULL,
    floor character varying,
    room_number character varying,
    rmtyp_description character varying,
    dept_id integer,
    dept_grp character varying,
    dept_description character varying,
    facility_code_heprod character varying,
    square_feet integer,
    instructional_seating_count integer,
    characteristics text[] DEFAULT '{}'::text[],
    visible boolean,
    building_bldrecnbr bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    tsv tsvector,
    dept_group_description character varying,
    building_name character varying,
    campus_record_id bigint,
    ada_seat_count integer,
    nickname character varying
);


--
-- Name: rooms_rmrecnbr_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rooms_rmrecnbr_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rooms_rmrecnbr_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rooms_rmrecnbr_seq OWNED BY public.rooms.rmrecnbr;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    email character varying DEFAULT ''::character varying NOT NULL,
    encrypted_password character varying DEFAULT ''::character varying NOT NULL,
    reset_password_token character varying,
    reset_password_sent_at timestamp without time zone,
    remember_created_at timestamp without time zone,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    avatar_url character varying,
    provider character varying,
    uid character varying,
    mcommunity_groups text DEFAULT ''::text NOT NULL,
    uniqname character varying,
    principal_name character varying,
    display_name character varying,
    person_affiliation character varying
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: action_text_rich_texts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts ALTER COLUMN id SET DEFAULT nextval('public.action_text_rich_texts_id_seq'::regclass);


--
-- Name: active_storage_attachments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments ALTER COLUMN id SET DEFAULT nextval('public.active_storage_attachments_id_seq'::regclass);


--
-- Name: active_storage_blobs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs ALTER COLUMN id SET DEFAULT nextval('public.active_storage_blobs_id_seq'::regclass);


--
-- Name: active_storage_variant_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records ALTER COLUMN id SET DEFAULT nextval('public.active_storage_variant_records_id_seq'::regclass);


--
-- Name: announcements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements ALTER COLUMN id SET DEFAULT nextval('public.announcements_id_seq'::regclass);


--
-- Name: api_update_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_update_logs ALTER COLUMN id SET DEFAULT nextval('public.api_update_logs_id_seq'::regclass);


--
-- Name: buildings bldrecnbr; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings ALTER COLUMN bldrecnbr SET DEFAULT nextval('public.buildings_bldrecnbr_seq'::regclass);


--
-- Name: campus_records id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campus_records ALTER COLUMN id SET DEFAULT nextval('public.campus_records_id_seq'::regclass);


--
-- Name: floors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floors ALTER COLUMN id SET DEFAULT nextval('public.floors_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: omni_auth_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.omni_auth_services ALTER COLUMN id SET DEFAULT nextval('public.omni_auth_services_id_seq'::regclass);


--
-- Name: omniauth_services id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.omniauth_services ALTER COLUMN id SET DEFAULT nextval('public.omniauth_services_id_seq'::regclass);


--
-- Name: pg_search_documents id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents ALTER COLUMN id SET DEFAULT nextval('public.pg_search_documents_id_seq'::regclass);


--
-- Name: room_characteristics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_characteristics ALTER COLUMN id SET DEFAULT nextval('public.room_characteristics_id_seq'::regclass);


--
-- Name: room_contacts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_contacts ALTER COLUMN id SET DEFAULT nextval('public.room_contacts_id_seq'::regclass);


--
-- Name: rooms rmrecnbr; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms ALTER COLUMN rmrecnbr SET DEFAULT nextval('public.rooms_rmrecnbr_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: action_text_rich_texts action_text_rich_texts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.action_text_rich_texts
    ADD CONSTRAINT action_text_rich_texts_pkey PRIMARY KEY (id);


--
-- Name: active_storage_attachments active_storage_attachments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT active_storage_attachments_pkey PRIMARY KEY (id);


--
-- Name: active_storage_blobs active_storage_blobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_blobs
    ADD CONSTRAINT active_storage_blobs_pkey PRIMARY KEY (id);


--
-- Name: active_storage_variant_records active_storage_variant_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT active_storage_variant_records_pkey PRIMARY KEY (id);


--
-- Name: announcements announcements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.announcements
    ADD CONSTRAINT announcements_pkey PRIMARY KEY (id);


--
-- Name: api_update_logs api_update_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_update_logs
    ADD CONSTRAINT api_update_logs_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: buildings buildings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT buildings_pkey PRIMARY KEY (bldrecnbr);


--
-- Name: campus_records campus_records_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campus_records
    ADD CONSTRAINT campus_records_pkey PRIMARY KEY (id);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: omni_auth_services omni_auth_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.omni_auth_services
    ADD CONSTRAINT omni_auth_services_pkey PRIMARY KEY (id);


--
-- Name: omniauth_services omniauth_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.omniauth_services
    ADD CONSTRAINT omniauth_services_pkey PRIMARY KEY (id);


--
-- Name: pg_search_documents pg_search_documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pg_search_documents
    ADD CONSTRAINT pg_search_documents_pkey PRIMARY KEY (id);


--
-- Name: room_characteristics room_characteristics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_characteristics
    ADD CONSTRAINT room_characteristics_pkey PRIMARY KEY (id);


--
-- Name: room_contacts room_contacts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_contacts
    ADD CONSTRAINT room_contacts_pkey PRIMARY KEY (id);


--
-- Name: rooms rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (rmrecnbr);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_action_text_rich_texts_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_action_text_rich_texts_uniqueness ON public.action_text_rich_texts USING btree (record_type, record_id, name);


--
-- Name: index_active_storage_attachments_on_blob_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_active_storage_attachments_on_blob_id ON public.active_storage_attachments USING btree (blob_id);


--
-- Name: index_active_storage_attachments_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_attachments_uniqueness ON public.active_storage_attachments USING btree (record_type, record_id, name, blob_id);


--
-- Name: index_active_storage_blobs_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_blobs_on_key ON public.active_storage_blobs USING btree (key);


--
-- Name: index_active_storage_variant_records_uniqueness; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_active_storage_variant_records_uniqueness ON public.active_storage_variant_records USING btree (blob_id, variation_digest);


--
-- Name: index_buildings_on_campus_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_campus_record_id ON public.buildings USING btree (campus_record_id);


--
-- Name: index_buildings_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_buildings_on_tsv ON public.buildings USING gin (tsv);


--
-- Name: index_floors_on_building_bldrecnbr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_floors_on_building_bldrecnbr ON public.floors USING btree (building_bldrecnbr);


--
-- Name: index_notes_on_noteable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_noteable ON public.notes USING btree (noteable_type, noteable_id);


--
-- Name: index_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_user_id ON public.notes USING btree (user_id);


--
-- Name: index_omni_auth_services_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_omni_auth_services_on_user_id ON public.omni_auth_services USING btree (user_id);


--
-- Name: index_omniauth_services_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_omniauth_services_on_user_id ON public.omniauth_services USING btree (user_id);


--
-- Name: index_pg_search_documents_on_searchable; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pg_search_documents_on_searchable ON public.pg_search_documents USING btree (searchable_type, searchable_id);


--
-- Name: index_room_characteristics_on_chrstc_and_rmrecnbr; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_room_characteristics_on_chrstc_and_rmrecnbr ON public.room_characteristics USING btree (chrstc, rmrecnbr);


--
-- Name: index_room_characteristics_on_rmrecnbr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_room_characteristics_on_rmrecnbr ON public.room_characteristics USING btree (rmrecnbr);


--
-- Name: index_room_contacts_on_rmrecnbr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_room_contacts_on_rmrecnbr ON public.room_contacts USING btree (rmrecnbr);


--
-- Name: index_rooms_on_building_bldrecnbr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rooms_on_building_bldrecnbr ON public.rooms USING btree (building_bldrecnbr);


--
-- Name: index_rooms_on_campus_record_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rooms_on_campus_record_id ON public.rooms USING btree (campus_record_id);


--
-- Name: index_rooms_on_tsv; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rooms_on_tsv ON public.rooms USING gin (tsv);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_reset_password_token; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_reset_password_token ON public.users USING btree (reset_password_token);


--
-- Name: index_users_on_uniqname; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_uniqname ON public.users USING btree (uniqname);


--
-- Name: buildings tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.buildings FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('tsv', 'pg_catalog.english', 'name', 'nick_name', 'abbreviation');


--
-- Name: rooms tsvectorupdate; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON public.rooms FOR EACH ROW EXECUTE FUNCTION tsvector_update_trigger('tsv', 'pg_catalog.english', 'room_number', 'facility_code_heprod');


--
-- Name: rooms fk_rails_0b29405d74; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT fk_rails_0b29405d74 FOREIGN KEY (building_bldrecnbr) REFERENCES public.buildings(bldrecnbr);


--
-- Name: omniauth_services fk_rails_185801cf32; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.omniauth_services
    ADD CONSTRAINT fk_rails_185801cf32 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: omni_auth_services fk_rails_2f283dbddd; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.omni_auth_services
    ADD CONSTRAINT fk_rails_2f283dbddd FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: room_contacts fk_rails_40b2d3daf6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_contacts
    ADD CONSTRAINT fk_rails_40b2d3daf6 FOREIGN KEY (rmrecnbr) REFERENCES public.rooms(rmrecnbr);


--
-- Name: rooms fk_rails_41c309f023; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rooms
    ADD CONSTRAINT fk_rails_41c309f023 FOREIGN KEY (campus_record_id) REFERENCES public.campus_records(id);


--
-- Name: buildings fk_rails_6a75b39956; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.buildings
    ADD CONSTRAINT fk_rails_6a75b39956 FOREIGN KEY (campus_record_id) REFERENCES public.campus_records(id);


--
-- Name: notes fk_rails_7f2323ad43; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT fk_rails_7f2323ad43 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: active_storage_variant_records fk_rails_993965df05; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_variant_records
    ADD CONSTRAINT fk_rails_993965df05 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: floors fk_rails_b87e6d71a9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT fk_rails_b87e6d71a9 FOREIGN KEY (building_bldrecnbr) REFERENCES public.buildings(bldrecnbr);


--
-- Name: active_storage_attachments fk_rails_c3b3935057; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.active_storage_attachments
    ADD CONSTRAINT fk_rails_c3b3935057 FOREIGN KEY (blob_id) REFERENCES public.active_storage_blobs(id);


--
-- Name: room_characteristics fk_rails_d00a2d31b3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.room_characteristics
    ADD CONSTRAINT fk_rails_d00a2d31b3 FOREIGN KEY (rmrecnbr) REFERENCES public.rooms(rmrecnbr);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20201008212537'),
('20201008212542'),
('20201008212544'),
('20201008214301'),
('20201012144235'),
('20201013193636'),
('20201015185412'),
('20201015193542'),
('20201022165543'),
('20201023153614'),
('20210816183531'),
('20210910182654'),
('20210910182736'),
('20211018211216'),
('20211018211648'),
('20211018211722'),
('20211021092659'),
('20211021115852'),
('20211101125649'),
('20211102213452'),
('20211109130147'),
('20211112035428'),
('20211112035659'),
('20211113230614'),
('20211113231859'),
('20211129210918'),
('20220104182624'),
('20220111201258'),
('20220222151031'),
('20220318205639'),
('20220328201915'),
('20220328220102'),
('20220331125213'),
('20220412123134'),
('20250206205459'),
('20250206205460'),
('20250319192338'),
('20250319192339'),
('20250319192340');


