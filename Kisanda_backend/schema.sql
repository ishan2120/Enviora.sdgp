-- Enviora Database Schema
-- Run this file to create all tables manually (optional — db.js does this automatically)

PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;

-- ── Users ──────────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  full_name   TEXT    NOT NULL,
  email       TEXT    NOT NULL UNIQUE,
  mobile      TEXT,
  password    TEXT    NOT NULL,
  role        TEXT    NOT NULL CHECK(role IN ('citizen', 'supervisor')) DEFAULT 'citizen',
  is_active   INTEGER NOT NULL DEFAULT 1,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now')),
  updated_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ── Password Reset Tokens ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token       TEXT    NOT NULL UNIQUE,
  expires_at  TEXT    NOT NULL,
  used        INTEGER NOT NULL DEFAULT 0,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ── Refresh Tokens ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id          INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token       TEXT    NOT NULL UNIQUE,
  expires_at  TEXT    NOT NULL,
  created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
);

-- ── Indexes ────────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_users_email           ON users(email);
CREATE INDEX IF NOT EXISTS idx_reset_tokens_token    ON password_reset_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token  ON refresh_tokens(token);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user   ON refresh_tokens(user_id);
