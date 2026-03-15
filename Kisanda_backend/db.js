const Database = require('better-sqlite3');
const path = require('path');

const DB_PATH = path.join(__dirname, 'enviora.db');

const db = new Database(DB_PATH);

// Enable WAL mode for better performance
db.pragma('journal_mode = WAL');
db.pragma('foreign_keys = ON');

// ── Create tables ──────────────────────────────────────────────────────────────

db.exec(`
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

  CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT    NOT NULL UNIQUE,
    expires_at  TEXT    NOT NULL,
    used        INTEGER NOT NULL DEFAULT 0,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
  );

  CREATE TABLE IF NOT EXISTS refresh_tokens (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token       TEXT    NOT NULL UNIQUE,
    expires_at  TEXT    NOT NULL,
    created_at  TEXT    NOT NULL DEFAULT (datetime('now'))
  );
`);

console.log('✅  Database initialised at', DB_PATH);

module.exports = db;
