package com.x46.backend.identity.entity;

import java.io.Serializable;
import java.util.Objects;
import java.util.UUID;

/** Composite key for {@link UserRole}, mirroring user_roles' PRIMARY KEY (user_id, role_id). */
public class UserRoleId implements Serializable {

    private UUID userId;
    private UUID roleId;

    public UserRoleId() {
    }

    public UserRoleId(UUID userId, UUID roleId) {
        this.userId = userId;
        this.roleId = roleId;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (!(o instanceof UserRoleId that)) {
            return false;
        }
        return Objects.equals(userId, that.userId) && Objects.equals(roleId, that.roleId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(userId, roleId);
    }
}
