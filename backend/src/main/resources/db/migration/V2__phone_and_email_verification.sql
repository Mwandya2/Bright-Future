-- V2: one-time code verification for phone numbers and email addresses.
--
-- Both boolean columns carry a DEFAULT. Adding a NOT NULL column without one
-- fails on a table that already has rows - the mistake that took the course
-- catalogue down before Flyway was introduced.
--
-- Existing accounts are marked verified: they signed up before this existed
-- and must not be locked out of their own accounts by a new rule.

ALTER TABLE users
    ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN IF NOT EXISTS email_verified BOOLEAN NOT NULL DEFAULT FALSE;

UPDATE users SET phone_verified = TRUE, email_verified = TRUE;

CREATE TABLE IF NOT EXISTS verification_codes (
    id           UUID PRIMARY KEY,
    user_id      UUID NOT NULL REFERENCES users (id) ON DELETE CASCADE,
    channel      VARCHAR(8) NOT NULL,
    code_hash    VARCHAR(100) NOT NULL,
    destination  VARCHAR(160) NOT NULL,
    expires_at   TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    consumed_at  TIMESTAMP(6) WITH TIME ZONE,
    attempts     INTEGER NOT NULL DEFAULT 0,
    created_at   TIMESTAMP(6) WITH TIME ZONE NOT NULL,
    CONSTRAINT verification_codes_channel_check
        CHECK (channel IN ('PHONE', 'EMAIL'))
);

CREATE INDEX IF NOT EXISTS idx_verification_user_channel
    ON verification_codes (user_id, channel);
