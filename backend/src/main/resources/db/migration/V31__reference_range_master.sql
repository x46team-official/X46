-- Module 031 : Reference Range Master


BEGIN;

CREATE TABLE reference_range_master(

  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  organization_id UUID NOT NULL
      REFERENCES organizations(id),

  branch_id UUID NOT NULL
      REFERENCES branches(id),

  parameter_id UUID NOT NULL
      REFERENCES parameter_master(id)
      ON DELETE CASCADE,

  gender VARCHAR(10) NOT NULL
      DEFAULT 'ANY'
      CHECK (
        gender IN
        (
            'MALE',
            'FEMALE',
            'ANY'
        )
      ),

  age_min NUMERIC(6,2) NOT NULL
      DEFAULT 0,

  age_max NUMERIC(6,2) NOT NULL
      DEFAULT 150,

  age_unit VARCHAR(10) NOT NULL
      DEFAULT 'YEARS'
      CHECK (
        age_unit IN
        (
            'DAYS',
            'MONTHS',
            'YEARS'
        )
      ),

  pregnancy_flag BOOLEAN NOT NULL
      DEFAULT FALSE,

  reference_min NUMERIC(18,4),

  reference_max NUMERIC(18,4),

  reference_range VARCHAR(255),

  critical_low NUMERIC(18,4),

  critical_high NUMERIC(18,4),

  effective_from DATE NOT NULL
      DEFAULT CURRENT_DATE,

  effective_to DATE,

  is_active BOOLEAN NOT NULL
      DEFAULT TRUE,

  created_at TIMESTAMPTZ NOT NULL
      DEFAULT CURRENT_TIMESTAMP,

  created_by UUID
      REFERENCES users(id),

  updated_at TIMESTAMPTZ NOT NULL
      DEFAULT CURRENT_TIMESTAMP,

  updated_by UUID
      REFERENCES users(id),

  CONSTRAINT chk_reference_range_master_age
      CHECK (age_max >= age_min),

  CONSTRAINT chk_reference_range_master_effective
      CHECK (effective_to IS NULL OR effective_to >= effective_from),

  CONSTRAINT chk_reference_range_master_bounds
      CHECK (reference_max IS NULL OR reference_min IS NULL OR reference_max >= reference_min),

  CONSTRAINT uq_reference_range_master
      UNIQUE (organization_id, branch_id, parameter_id, gender, age_min, age_max, pregnancy_flag, effective_from)
);

CREATE INDEX idx_reference_range_master_org
ON reference_range_master(organization_id);

CREATE INDEX idx_reference_range_master_org_branch
ON reference_range_master(organization_id, branch_id);

CREATE INDEX idx_reference_range_master_parameter
ON reference_range_master(parameter_id);

CREATE INDEX idx_reference_range_master_lookup
ON reference_range_master(parameter_id, gender, pregnancy_flag, is_active);

CREATE INDEX idx_reference_range_master_active
ON reference_range_master(is_active);

CREATE INDEX idx_reference_range_master_effective
ON reference_range_master(effective_from, effective_to);

-- function: reject overlapping demographic bands for the same
-- parameter_id / gender / pregnancy_flag
CREATE OR REPLACE FUNCTION prevent_reference_range_overlap()
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
DECLARE
    v_conflict_id UUID;
BEGIN

    IF NEW.is_active THEN

        SELECT id
        INTO v_conflict_id
        FROM reference_range_master
        WHERE organization_id = NEW.organization_id
          AND branch_id = NEW.branch_id
          AND parameter_id = NEW.parameter_id
          AND gender = NEW.gender
          AND age_unit = NEW.age_unit
          AND pregnancy_flag = NEW.pregnancy_flag
          AND is_active = TRUE
          AND id IS DISTINCT FROM NEW.id
          AND NEW.age_min <= age_max
          AND NEW.age_max >= age_min
          AND NEW.effective_from <= COALESCE(effective_to, DATE 'infinity')
          AND COALESCE(NEW.effective_to, DATE 'infinity') >= effective_from
        LIMIT 1;

        IF v_conflict_id IS NOT NULL THEN
            RAISE EXCEPTION
                'reference_range_master: overlapping demographic band for parameter_id=%, gender=%, pregnancy_flag=% conflicts with existing row %',
                NEW.parameter_id, NEW.gender, NEW.pregnancy_flag, v_conflict_id;
        END IF;

    END IF;

    RETURN NEW;

END;
$$;

CREATE TRIGGER trg_prevent_reference_range_overlap
BEFORE INSERT OR UPDATE ON reference_range_master
FOR EACH ROW
EXECUTE FUNCTION prevent_reference_range_overlap();

COMMIT;
