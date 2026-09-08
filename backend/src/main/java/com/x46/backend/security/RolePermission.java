package com.x46.backend.security;

import com.x46.backend.common.AbstractTenantEntity;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import java.util.UUID;

@Entity
@Table(name = "role_permission")
public class RolePermission extends AbstractTenantEntity {

    @Column(name = "role_id", nullable = false)
    private UUID roleId;

    @Column(name = "module_name", nullable = false)
    private String moduleName;

    @Column(name = "can_create", nullable = false)
    private boolean canCreate;

    @Column(name = "can_view", nullable = false)
    private boolean canView;

    @Column(name = "can_update", nullable = false)
    private boolean canUpdate;

    @Column(name = "can_delete", nullable = false)
    private boolean canDelete;

    @Column(name = "can_authorize", nullable = false)
    private boolean canAuthorize;

    @Column(name = "can_print", nullable = false)
    private boolean canPrint;

    @Column(name = "can_export", nullable = false)
    private boolean canExport;

    public boolean allows(PermissionAction action) {
        return switch (action) {
            case CREATE -> canCreate;
            case VIEW -> canView;
            case UPDATE -> canUpdate;
            case DELETE -> canDelete;
            case AUTHORIZE -> canAuthorize;
            case PRINT -> canPrint;
            case EXPORT -> canExport;
        };
    }

    public UUID getRoleId() {
        return roleId;
    }

    public void setRoleId(UUID roleId) {
        this.roleId = roleId;
    }

    public String getModuleName() {
        return moduleName;
    }

    public void setModuleName(String moduleName) {
        this.moduleName = moduleName;
    }

    public void setCanCreate(boolean canCreate) {
        this.canCreate = canCreate;
    }

    public void setCanView(boolean canView) {
        this.canView = canView;
    }

    public void setCanUpdate(boolean canUpdate) {
        this.canUpdate = canUpdate;
    }

    public void setCanDelete(boolean canDelete) {
        this.canDelete = canDelete;
    }

    public void setCanAuthorize(boolean canAuthorize) {
        this.canAuthorize = canAuthorize;
    }

    public void setCanPrint(boolean canPrint) {
        this.canPrint = canPrint;
    }

    public void setCanExport(boolean canExport) {
        this.canExport = canExport;
    }
}
