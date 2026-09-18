package com.x46.backend.master.entity;

import com.x46.backend.common.AbstractTenantEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "parameter_master")
public class ParameterMaster extends AbstractTenantEntity {

    @Column(name = "parameter_code", nullable = false)
    private String parameterCode;

    @Column(name = "parameter_name", nullable = false)
    private String parameterName;

    @Column(name = "unit")
    private String unit;

    @Column(name = "default_reference_range")
    private String defaultReferenceRange;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    public String getParameterCode() {
        return parameterCode;
    }

    public void setParameterCode(String parameterCode) {
        this.parameterCode = parameterCode;
    }

    public String getParameterName() {
        return parameterName;
    }

    public void setParameterName(String parameterName) {
        this.parameterName = parameterName;
    }

    public String getUnit() {
        return unit;
    }

    public void setUnit(String unit) {
        this.unit = unit;
    }

    public String getDefaultReferenceRange() {
        return defaultReferenceRange;
    }

    public void setDefaultReferenceRange(String defaultReferenceRange) {
        this.defaultReferenceRange = defaultReferenceRange;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
