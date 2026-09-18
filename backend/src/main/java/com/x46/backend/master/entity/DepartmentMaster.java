package com.x46.backend.master.entity;

import com.x46.backend.common.AbstractTenantEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;

@Entity
@Table(name = "department_master")
public class DepartmentMaster extends AbstractTenantEntity {

    @Column(name = "department_name", nullable = false)
    private String departmentName;

    @Column(name = "department_code")
    private String departmentCode;

    @Column(name = "description")
    private String description;

    // Boxed: is_active is nullable in the schema (DEFAULT TRUE, no NOT NULL).
    @Column(name = "is_active")
    private Boolean active;

    public String getDepartmentName() {
        return departmentName;
    }

    public void setDepartmentName(String departmentName) {
        this.departmentName = departmentName;
    }

    public String getDepartmentCode() {
        return departmentCode;
    }

    public void setDepartmentCode(String departmentCode) {
        this.departmentCode = departmentCode;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Boolean getActive() {
        return active;
    }

    public void setActive(Boolean active) {
        this.active = active;
    }
}
