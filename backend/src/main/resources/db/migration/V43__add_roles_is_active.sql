-- Chunk 1.3 (plan.md gap #1 / API-129 schema_gap_note): roles has no
-- is_active column, so Activate/Deactivate Role can't be implemented without
-- it. Additive, matches the contract's documented resolution exactly.
-- Numbered V43, not V42 as plan.md's original text names it: Chunk 1.1's
-- V42__platform_bootstrap_seed.sql claimed V42 first as a data-only seed.
ALTER TABLE roles ADD COLUMN is_active BOOLEAN NOT NULL DEFAULT TRUE;
