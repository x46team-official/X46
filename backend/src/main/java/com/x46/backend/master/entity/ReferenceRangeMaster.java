package com.x46.backend.master.entity;

import com.x46.backend.common.AbstractTenantEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.UUID;

@Entity
@Table(name = "reference_range_master")
public class ReferenceRangeMaster extends AbstractTenantEntity {

    @Column(name = "parameter_id", nullable = false)
    private UUID parameterId;

    @Column(name = "gender", nullable = false)
    private String gender;

    @Column(name = "age_min", nullable = false)
    private BigDecimal ageMin;

    @Column(name = "age_max", nullable = false)
    private BigDecimal ageMax;

    @Column(name = "age_unit", nullable = false)
    private String ageUnit;

    @Column(name = "pregnancy_flag", nullable = false)
    private boolean pregnancyFlag;

    @Column(name = "reference_min")
    private BigDecimal referenceMin;

    @Column(name = "reference_max")
    private BigDecimal referenceMax;

    @Column(name = "reference_range")
    private String referenceRange;

    @Column(name = "critical_low")
    private BigDecimal criticalLow;

    @Column(name = "critical_high")
    private BigDecimal criticalHigh;

    @Column(name = "effective_from", nullable = false)
    private LocalDate effectiveFrom;

    @Column(name = "effective_to")
    private LocalDate effectiveTo;

    @Column(name = "is_active", nullable = false)
    private boolean active;

    public UUID getParameterId() {
        return parameterId;
    }

    public void setParameterId(UUID parameterId) {
        this.parameterId = parameterId;
    }

    public String getGender() {
        return gender;
    }

    public void setGender(String gender) {
        this.gender = gender;
    }

    public BigDecimal getAgeMin() {
        return ageMin;
    }

    public void setAgeMin(BigDecimal ageMin) {
        this.ageMin = ageMin;
    }

    public BigDecimal getAgeMax() {
        return ageMax;
    }

    public void setAgeMax(BigDecimal ageMax) {
        this.ageMax = ageMax;
    }

    public String getAgeUnit() {
        return ageUnit;
    }

    public void setAgeUnit(String ageUnit) {
        this.ageUnit = ageUnit;
    }

    public boolean isPregnancyFlag() {
        return pregnancyFlag;
    }

    public void setPregnancyFlag(boolean pregnancyFlag) {
        this.pregnancyFlag = pregnancyFlag;
    }

    public BigDecimal getReferenceMin() {
        return referenceMin;
    }

    public void setReferenceMin(BigDecimal referenceMin) {
        this.referenceMin = referenceMin;
    }

    public BigDecimal getReferenceMax() {
        return referenceMax;
    }

    public void setReferenceMax(BigDecimal referenceMax) {
        this.referenceMax = referenceMax;
    }

    public String getReferenceRange() {
        return referenceRange;
    }

    public void setReferenceRange(String referenceRange) {
        this.referenceRange = referenceRange;
    }

    public BigDecimal getCriticalLow() {
        return criticalLow;
    }

    public void setCriticalLow(BigDecimal criticalLow) {
        this.criticalLow = criticalLow;
    }

    public BigDecimal getCriticalHigh() {
        return criticalHigh;
    }

    public void setCriticalHigh(BigDecimal criticalHigh) {
        this.criticalHigh = criticalHigh;
    }

    public LocalDate getEffectiveFrom() {
        return effectiveFrom;
    }

    public void setEffectiveFrom(LocalDate effectiveFrom) {
        this.effectiveFrom = effectiveFrom;
    }

    public LocalDate getEffectiveTo() {
        return effectiveTo;
    }

    public void setEffectiveTo(LocalDate effectiveTo) {
        this.effectiveTo = effectiveTo;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
