// knexfile.js — Knex config for MySQL
require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });

module.exports = {
  client: 'mysql2',
  connection: {
    host: process.env.DB_HOST || 'localhost',
    port: Number(process.env.DB_PORT) || 3306,
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'enviora_db',
  },
  pool: { min: 2, max: 10 },
  migrations: {
    directory: './migrations',
    tableName: 'knex_migrations',
  },
  seeds: {
    directory: './seeds',
  },
};
