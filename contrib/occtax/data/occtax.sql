SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;


CREATE SCHEMA pr_occtax;


SET search_path = pr_occtax, pg_catalog;
SET default_with_oids = false;


-------------
--FUNCTIONS--
-------------
CREATE OR REPLACE FUNCTION get_default_nomenclature_value(myidtype integer, myidorganism integer DEFAULT 0, myregne character varying(20) DEFAULT '0', mygroup2inpn character varying(255) DEFAULT '0') RETURNS integer
IMMUTABLE
LANGUAGE plpgsql
AS $$
--Function that return the default nomenclature id with wanteds nomenclature type, organism id, regne, group2_inpn 
--Return -1 if nothing matche with given parameters
  DECLARE
    thenomenclatureid integer;
  BEGIN
      SELECT INTO thenomenclatureid id_nomenclature
      FROM pr_occtax.defaults_nomenclatures_value 
      WHERE id_type = myidtype 
      AND (id_organism = 0 OR id_organism = myidorganism)
      AND (regne = '0' OR regne = myregne)
      AND (group2_inpn = '0' OR group2_inpn = mygroup2inpn)
      ORDER BY group2_inpn DESC, regne DESC, id_organism DESC LIMIT 1;
    IF (thenomenclatureid IS NOT NULL) THEN
      RETURN thenomenclatureid;
    END IF;
    RETURN NULL;
  END;
$$;


------------------------
--TABLES AND SEQUENCES--
------------------------

CREATE TABLE t_releves_occtax (
    id_releve_occtax bigint NOT NULL,
    unique_id_sinp_grp uuid NOT NULL DEFAULT public.uuid_generate_v4(),
    id_dataset integer NOT NULL,
    id_digitiser integer,
    observers_txt varchar(500),
    id_nomenclature_obs_technique integer NOT NULL, --DEFAULT get_default_nomenclature_value(343)
    id_nomenclature_grp_typ integer NOT NULL, --DEFAULT get_default_nomenclature_value(150),
    date_min timestamp without time zone DEFAULT now() NOT NULL,
    date_max timestamp without time zone DEFAULT now() NOT NULL,
    hour_min time,
    hour_max time,
    altitude_min integer,
    altitude_max integer,
    deleted boolean DEFAULT false NOT NULL,
    meta_device_entry character varying(20),
    meta_create_date timestamp without time zone DEFAULT now(),
    meta_update_date timestamp without time zone DEFAULT now(),
    comment text,
    geom_local public.geometry(Geometry,MYLOCALSRID),
    geom_4326 public.geometry(Geometry,4326),
    precision integer DEFAULT 100,    
    CONSTRAINT enforce_dims_geom_4326 CHECK ((public.st_ndims(geom_4326) = 2)),
    CONSTRAINT enforce_dims_geom_local CHECK ((public.st_ndims(geom_local) = 2)),
    CONSTRAINT enforce_srid_geom_4326 CHECK ((public.st_srid(geom_4326) = 4326)),
    CONSTRAINT enforce_srid_geom_local CHECK ((public.st_srid(geom_local) = MYLOCALSRID))
);
COMMENT ON COLUMN t_releves_occtax.id_nomenclature_obs_technique IS 'Correspondance nomenclature CAMPANULE = technique_obs';
COMMENT ON COLUMN t_releves_occtax.id_nomenclature_grp_typ IS 'Correspondance nomenclature INPN = Type de regroupement';

CREATE SEQUENCE t_releves_occtax_id_releve_occtax_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE t_releves_occtax_id_releve_occtax_seq OWNED BY t_releves_occtax.id_releve_occtax;
ALTER TABLE ONLY t_releves_occtax ALTER COLUMN id_releve_occtax SET DEFAULT nextval('t_releves_occtax_id_releve_occtax_seq'::regclass);
SELECT pg_catalog.setval('t_releves_occtax_id_releve_occtax_seq', 1, false);


CREATE TABLE t_occurrences_occtax (
    id_occurrence_occtax bigint NOT NULL,
    unique_id_occurence_occtax uuid NOT NULL DEFAULT uuid_generate_v4(),
    id_releve_occtax bigint NOT NULL,
    id_nomenclature_obs_meth integer NOT NULL, --DEFAULT get_default_nomenclature_value(14),
    id_nomenclature_bio_condition integer NOT NULL, --DEFAULT get_default_nomenclature_value(7),
    id_nomenclature_bio_status integer, --DEFAULT get_default_nomenclature_value(13),
    id_nomenclature_naturalness integer, --DEFAULT get_default_nomenclature_value(8),
    id_nomenclature_exist_proof integer, --DEFAULT get_default_nomenclature_value(15),
    id_nomenclature_diffusion_level integer, --DEFAULT get_default_nomenclature_value(5),
    id_nomenclature_observation_status integer, --DEFAULT get_default_nomenclature_value(18),
    id_nomenclature_blurring integer, --DEFAULT get_default_nomenclature_value(4),
    determiner character varying(255),
    id_nomenclature_determination_method integer, --DEFAULT get_default_nomenclature_value(106),
    cd_nom integer,
    nom_cite character varying(255),
    meta_v_taxref character varying(50) DEFAULT 'SELECT get_default_parameter(''taxref_version'')',
    sample_number_proof text,
    digital_proof text,
    non_digital_proof text,
    deleted boolean DEFAULT false NOT NULL,
    meta_create_date timestamp without time zone,
    meta_update_date timestamp without time zone,
    comment character varying
);
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_obs_meth IS 'Correspondance nomenclature INPN = methode_obs';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_bio_condition IS 'Correspondance nomenclature INPN = etat_bio';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_bio_status IS 'Correspondance nomenclature INPN = statut_bio';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_naturalness IS 'Correspondance nomenclature INPN = naturalite';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_exist_proof IS 'Correspondance nomenclature INPN = preuve_exist';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_diffusion_level IS 'Correspondance nomenclature INPN = niv_precis';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_observation_status IS 'Correspondance nomenclature INPN = statut_obs';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_blurring IS 'Correspondance nomenclature INPN = dee_flou';
COMMENT ON COLUMN t_occurrences_occtax.id_nomenclature_determination_method IS 'Correspondance nomenclature GEONATURE = meth_determin';

CREATE SEQUENCE t_occurrences_occtax_id_occurrence_occtax_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE t_occurrences_occtax_id_occurrence_occtax_seq OWNED BY t_occurrences_occtax.id_occurrence_occtax;
ALTER TABLE ONLY t_occurrences_occtax ALTER COLUMN id_occurrence_occtax SET DEFAULT nextval('t_occurrences_occtax_id_occurrence_occtax_seq'::regclass);
SELECT pg_catalog.setval('t_occurrences_occtax_id_occurrence_occtax_seq', 1, false);


CREATE TABLE cor_counting_occtax (
    id_counting_occtax bigint NOT NULL,
    unique_id_sinp_occtax uuid NOT NULL DEFAULT public.uuid_generate_v4(),
    id_occurrence_occtax bigint NOT NULL,
    id_nomenclature_life_stage integer NOT NULL, --DEFAULT get_default_nomenclature_value(10),
    id_nomenclature_sex integer NOT NULL, --DEFAULT get_default_nomenclature_value(9),
    id_nomenclature_obj_count integer NOT NULL, --DEFAULT get_default_nomenclature_value(6),
    id_nomenclature_type_count integer, --DEFAULT get_default_nomenclature_value(21),
    count_min integer,
    count_max integer,
    meta_create_date timestamp without time zone,
    meta_update_date timestamp without time zone    
);
COMMENT ON COLUMN cor_counting_occtax.id_nomenclature_life_stage IS 'Correspondance nomenclature INPN = stade_vie (10)';
COMMENT ON COLUMN cor_counting_occtax.id_nomenclature_sex IS 'Correspondance nomenclature INPN = sexe (9)';
COMMENT ON COLUMN cor_counting_occtax.id_nomenclature_obj_count IS 'Correspondance nomenclature INPN = obj_denbr (6)';
COMMENT ON COLUMN cor_counting_occtax.id_nomenclature_type_count IS 'Correspondance nomenclature INPN = typ_denbr (21)';


CREATE SEQUENCE cor_counting_occtax_id_counting_occtax_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
ALTER SEQUENCE cor_counting_occtax_id_counting_occtax_seq OWNED BY t_occurrences_occtax.id_occurrence_occtax;
ALTER TABLE ONLY cor_counting_occtax ALTER COLUMN id_counting_occtax SET DEFAULT nextval('cor_counting_occtax_id_counting_occtax_seq'::regclass);
SELECT pg_catalog.setval('cor_counting_occtax_id_counting_occtax_seq', 1, false);


CREATE TABLE cor_role_releves_occtax (
    id_releve_occtax bigint NOT NULL,
    id_role integer NOT NULL
);


CREATE TABLE defaults_nomenclatures_value (
    id_type integer NOT NULL,
    id_organism integer NOT NULL DEFAULT 0,
    regne character varying(20) NOT NULL DEFAULT '0',
    group2_inpn character varying(255) NOT NULL DEFAULT '0',
    id_nomenclature integer NOT NULL
);


---------------
--PRIMARY KEY--
---------------
ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT pk_t_occurrences_occtax PRIMARY KEY (id_occurrence_occtax);

ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT pk_t_releves_occtax PRIMARY KEY (id_releve_occtax);

ALTER TABLE ONLY cor_counting_occtax
    ADD CONSTRAINT pk_cor_counting_occtax_occtax PRIMARY KEY (id_counting_occtax);

ALTER TABLE ONLY cor_role_releves_occtax
    ADD CONSTRAINT pk_cor_role_releves_occtax PRIMARY KEY (id_releve_occtax, id_role);

ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT pk_pr_occtax_defaults_nomenclatures_value PRIMARY KEY (id_type, id_organism, regne, group2_inpn);


---------------
--FOREIGN KEY--
---------------
ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT fk_t_releves_occtax_t_datasets FOREIGN KEY (id_dataset) REFERENCES gn_meta.t_datasets(id_dataset) ON UPDATE CASCADE;

ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT fk_t_releves_occtax_t_roles FOREIGN KEY (id_digitiser) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;

ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT fk_t_releves_occtax_obs_technique FOREIGN KEY (id_nomenclature_obs_technique) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT fk_t_releves_occtax_regroupement_typ FOREIGN KEY (id_nomenclature_grp_typ) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;



ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_t_releves_occtax FOREIGN KEY (id_releve_occtax) REFERENCES t_releves_occtax(id_releve_occtax) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_taxref FOREIGN KEY (cd_nom) REFERENCES taxonomie.taxref(cd_nom) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_obs_meth FOREIGN KEY (id_nomenclature_obs_meth) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_bio_condition FOREIGN KEY (id_nomenclature_bio_condition) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_bio_status FOREIGN KEY (id_nomenclature_bio_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_naturalness FOREIGN KEY (id_nomenclature_naturalness) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_exist_proof FOREIGN KEY (id_nomenclature_exist_proof) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_diffusion_level FOREIGN KEY (id_nomenclature_diffusion_level) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_observation_status FOREIGN KEY (id_nomenclature_observation_status) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_blurring FOREIGN KEY (id_nomenclature_blurring) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT fk_t_occurrences_occtax_determination_method FOREIGN KEY (id_nomenclature_determination_method) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


ALTER TABLE ONLY cor_counting_occtax
    ADD CONSTRAINT fk_cor_stage_number_id_taxon FOREIGN KEY (id_occurrence_occtax) REFERENCES t_occurrences_occtax(id_occurrence_occtax) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY cor_counting_occtax
    ADD CONSTRAINT fk_cor_counting_occtax_sexe FOREIGN KEY (id_nomenclature_sex) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_counting_occtax
    ADD CONSTRAINT fk_cor_counting_occtax_life_stage FOREIGN KEY (id_nomenclature_life_stage) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_counting_occtax
    ADD CONSTRAINT fk_cor_counting_occtax_obj_count FOREIGN KEY (id_nomenclature_obj_count) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;

ALTER TABLE ONLY cor_counting_occtax
    ADD CONSTRAINT fk_cor_counting_occtax_typ_count FOREIGN KEY (id_nomenclature_type_count) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


ALTER TABLE ONLY cor_role_releves_occtax
    ADD CONSTRAINT fk_cor_role_releves_occtax_t_releves_occtax FOREIGN KEY (id_releve_occtax) REFERENCES t_releves_occtax(id_releve_occtax) ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE ONLY cor_role_releves_occtax
    ADD CONSTRAINT fk_cor_role_releves_occtax_t_roles FOREIGN KEY (id_role) REFERENCES utilisateurs.t_roles(id_role) ON UPDATE CASCADE;


ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT fk_pr_occtax_defaults_nomenclatures_value_id_type FOREIGN KEY (id_type) REFERENCES ref_nomenclatures.bib_nomenclatures_types(id_type) ON UPDATE CASCADE;

ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT fk_pr_occtax_defaults_nomenclatures_value_id_organism FOREIGN KEY (id_organism) REFERENCES utilisateurs.bib_organismes(id_organisme) ON UPDATE CASCADE;

ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT fk_pr_occtax_defaults_nomenclatures_value_id_nomenclature FOREIGN KEY (id_nomenclature) REFERENCES ref_nomenclatures.t_nomenclatures(id_nomenclature) ON UPDATE CASCADE;


--------------
--CONSTRAINS--
--------------
ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT check_t_releves_occtax_altitude_max CHECK (altitude_max >= altitude_min);

ALTER TABLE ONLY t_releves_occtax
    ADD CONSTRAINT check_t_releves_occtax_date_max CHECK (date_max >= date_min);

ALTER TABLE t_releves_occtax
  ADD CONSTRAINT check_t_releves_occtax_hour_max CHECK (hour_min <= hour_max OR date_min < date_max);

ALTER TABLE t_releves_occtax
  ADD CONSTRAINT check_t_releves_occtax_obs_technique CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_obs_technique,100));

ALTER TABLE t_releves_occtax
  ADD CONSTRAINT check_t_releves_occtax_regroupement_typ CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_grp_typ,24));


ALTER TABLE ONLY t_occurrences_occtax
    ADD CONSTRAINT check_t_occurrences_occtax_cd_nom_isinbib_noms CHECK (taxonomie.check_is_inbibnoms(cd_nom));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_obs_meth CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_obs_meth,14));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_bio_condition CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_bio_condition,7));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_bio_status CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_bio_status,13));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_naturalness CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_naturalness,8));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_exist_proof CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_exist_proof,15));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_accur_level CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_diffusion_level,5));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_obs_status CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_observation_status,18));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_blurring CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_blurring,4));

ALTER TABLE t_occurrences_occtax
  ADD CONSTRAINT check_t_occurrences_occtax_determination_method CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_determination_method,106));


ALTER TABLE cor_counting_occtax
  ADD CONSTRAINT check_cor_counting_occtax_life_stage CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_life_stage,10));

ALTER TABLE cor_counting_occtax
  ADD CONSTRAINT check_cor_counting_occtax_sexe CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_sex,9));

ALTER TABLE cor_counting_occtax
  ADD CONSTRAINT check_cor_counting_occtax_obj_count CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_obj_count,6));

ALTER TABLE cor_counting_occtax
  ADD CONSTRAINT check_cor_counting_occtax_type_count CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature_type_count,21));

ALTER TABLE cor_counting_occtax
    ADD CONSTRAINT check_cor_counting_occtax_count_min CHECK (count_min > 0);

ALTER TABLE cor_counting_occtax
    ADD CONSTRAINT check_cor_counting_occtax_count_max CHECK (count_max >= count_min AND count_max > 0);


ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT check_pr_occtax_defaults_nomenclatures_value_is_nomenclature_in_type CHECK (ref_nomenclatures.check_nomenclature_type(id_nomenclature, id_type));

ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT check_pr_occtax_defaults_nomenclatures_value_isgroup2inpn CHECK (taxonomie.check_is_group2inpn(group2_inpn::text) OR group2_inpn::text = '0'::text);

ALTER TABLE ONLY defaults_nomenclatures_value
    ADD CONSTRAINT check_pr_occtax_defaults_nomenclatures_value_isregne CHECK (taxonomie.check_is_regne(regne::text) OR regne::text = '0'::text);


----------------------
--FUNCTIONS TRIGGERS--
----------------------
CREATE OR REPLACE FUNCTION insert_occurrences_occtax()
  RETURNS trigger AS
$BODY$
DECLARE
    idsensitivity integer;
BEGIN
    --Calculate sensitivity value
    SELECT INTO idsensitivity ref_nomenclatures.calculate_sensitivity(new.cd_nom,new.id_nomenclature_obs_meth);
    new.id_nomenclature_diffusion_level = idsensitivity;
    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

CREATE OR REPLACE FUNCTION update_occurrences_occtax()
  RETURNS trigger AS
$BODY$
DECLARE
    idsensitivity integer;
BEGIN
    --Calculate sensitivity value
    SELECT INTO idsensitivity ref_nomenclatures.calculate_sensitivity(new.cd_nom,new.id_nomenclature_obs_meth);
    new.id_nomenclature_diffusion_level = idsensitivity;
    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


------------
--TRIGGERS--
------------
CREATE TRIGGER tri_insert_occurrences_occtax
  BEFORE INSERT
  ON t_occurrences_occtax
  FOR EACH ROW
  EXECUTE PROCEDURE insert_occurrences_occtax();

CREATE TRIGGER tri_update_occurrences_occtax
  BEFORE INSERT
  ON t_occurrences_occtax
  FOR EACH ROW
  EXECUTE PROCEDURE update_occurrences_occtax();

CREATE TRIGGER tri_meta_dates_change_occurrences_occtax
  BEFORE INSERT OR UPDATE
  ON t_occurrences_occtax
  FOR EACH ROW
  EXECUTE PROCEDURE public.fct_trg_meta_dates_change();

CREATE TRIGGER tri_meta_dates_change_t_releves_occtax
  BEFORE INSERT OR UPDATE
  ON t_releves_occtax
  FOR EACH ROW
  EXECUTE PROCEDURE public.fct_trg_meta_dates_change();

CREATE TRIGGER tri_meta_dates_change_cor_counting_occtax
  BEFORE INSERT OR UPDATE
  ON cor_counting_occtax
  FOR EACH ROW
  EXECUTE PROCEDURE public.fct_trg_meta_dates_change();

CREATE TRIGGER tri_insert_default_validation_status
  AFTER INSERT
  ON cor_counting_occtax
  FOR EACH ROW
  EXECUTE PROCEDURE gn_commons.fct_trg_add_default_validation_status();


------------
--VIEWS--
------------
--Vue représentant l'ensemble des observations du protocole occtax pour la représentation du module carte liste
DROP VIEW IF EXISTS v_releve_occtax;
CREATE OR REPLACE VIEW pr_occtax.v_releve_occtax AS 
 SELECT rel.id_releve_occtax,
    rel.id_dataset,
    rel.id_digitiser,
    rel.date_min,
    rel.date_max,
    rel.altitude_min,
    rel.altitude_max,
    rel.deleted,
    rel.meta_device_entry,
    rel.meta_create_date,
    rel.meta_update_date,
    rel.comment,
    rel.geom_4326,
    rel."precision",
    occ.id_occurrence_occtax,
    occ.cd_nom,
    occ.nom_cite,
    occ.deleted AS occ_deleted,
    occ.meta_create_date AS occ_meta_create_date,
    occ.meta_update_date AS occ_meta_update_date,
    t.lb_nom,
    t.nom_valide,
    t.nom_vern,
    (((t.nom_complet_html::text || ' '::text) || rel.date_min::date) || '<br/>'::text) || string_agg((obs.nom_role::text || ' '::text) || obs.prenom_role::text, ', '::text) AS leaflet_popup,
    COALESCE ( string_agg((obs.nom_role::text || ' '::text) || obs.prenom_role::text, ', '::text),rel.observers_txt) AS observateurs
   FROM pr_occtax.t_releves_occtax rel
     LEFT JOIN pr_occtax.t_occurrences_occtax occ ON rel.id_releve_occtax = occ.id_releve_occtax
     LEFT JOIN taxonomie.taxref t ON occ.cd_nom = t.cd_nom
     LEFT JOIN pr_occtax.cor_role_releves_occtax cor_role ON cor_role.id_releve_occtax = rel.id_releve_occtax
     LEFT JOIN utilisateurs.t_roles obs ON cor_role.id_role = obs.id_role
  GROUP BY rel.id_releve_occtax, rel.id_dataset, rel.id_digitiser, rel.date_min, rel.date_max, rel.altitude_min, rel.altitude_max, rel.deleted, rel.meta_device_entry, rel.meta_create_date, rel.meta_update_date, rel.comment, rel.geom_4326, rel."precision", t.cd_nom, occ.nom_cite, occ.id_occurrence_occtax, occ.deleted, occ.meta_create_date, occ.meta_update_date, t.lb_nom, t.nom_valide, t.nom_complet_html, t.nom_vern;





--Vue représentant l'ensemble des relevés du protocole occtax pour la représentation du module carte liste
CREATE OR REPLACE VIEW pr_occtax.v_releve_list AS 
 SELECT rel.id_releve_occtax,
    rel.id_dataset,
    rel.id_digitiser,
    rel.date_min,
    rel.date_max,
    rel.altitude_min,
    rel.altitude_max,
    rel.deleted,
    rel.meta_device_entry,
    rel.meta_create_date,
    rel.meta_update_date,
    rel.comment,
    rel.geom_4326,
    rel."precision",
    string_agg(t.nom_valide::text, ','::text) AS taxons,
    (((string_agg(t.nom_valide::text, ','::text) || '<br/>'::text) || rel.date_min::date) || '<br/>'::text) || COALESCE(string_agg((obs.nom_role::text || ' '::text) || obs.prenom_role::text, ', '::text), rel.observers_txt) AS leaflet_popup,
    COALESCE(string_agg((obs.nom_role::text || ' '::text) || obs.prenom_role::text, ', '::text), rel.observers_txt::text) AS observateurs
   FROM pr_occtax.t_releves_occtax rel
     LEFT JOIN pr_occtax.t_occurrences_occtax occ ON rel.id_releve_occtax = occ.id_releve_occtax
     LEFT JOIN taxonomie.taxref t ON occ.cd_nom = t.cd_nom
     LEFT JOIN pr_occtax.cor_role_releves_occtax cor_role ON cor_role.id_releve_occtax = rel.id_releve_occtax
     LEFT JOIN utilisateurs.t_roles obs ON cor_role.id_role = obs.id_role
  GROUP BY rel.id_releve_occtax, rel.id_dataset, rel.id_digitiser, rel.date_min, rel.date_max, rel.altitude_min, rel.altitude_max, rel.deleted, rel.meta_device_entry, rel.meta_create_date, rel.meta_update_date, rel.comment, rel.geom_4326, rel."precision";


---------------
--SAMPLE DATA--
---------------

INSERT INTO pr_occtax.defaults_nomenclatures_value (id_type, id_organism, regne, group2_inpn, id_nomenclature) VALUES
(14,0,0,0,42)
,(7,0,0,0,178)
,(13,0,0,0,30)
,(8,0,0,0,182)
,(15,0,0,0,91)
,(101,0,0,0,494)
,(5,0,0,0,163)
,(106,0,0,0,370)
,(10,0,0,0,2)
,(9,0,0,0,194)
,(6,0,0,0,166)
,(21,0,0,0,109)
,(18,0,0,0,101)
,(4,0,0,0,200)
,(24,0,0,0,150)
,(100,0,0,0,343)
;