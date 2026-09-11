package com.x46.backend;

import static org.assertj.core.api.Assertions.assertThat;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest
class FlywayMigrationTest {

    @Autowired
    private Flyway flyway;

    @Test
    void migratesToLatestVersionCleanly() {
        var current = flyway.info().current();
        assertThat(current).isNotNull();
        assertThat(current.getVersion().toString()).isEqualTo("43");
        assertThat(flyway.info().pending()).isEmpty();
    }
}
