/**
 * database/setup.js
 * Run this once to create schema and seed data:
 *   node database/setup.js
 */
require('dotenv').config();
const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');

async function setup() {
  let connection;

  try {
    // Connect WITHOUT a database selected so we can create it
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      port: parseInt(process.env.DB_PORT) || 3306,
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      multipleStatements: true,
    });

    console.log('✅ Connected to MySQL server');

    const sqlPath = path.join(__dirname, 'schema.sql');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('⏳ Running schema and seed...');
    await connection.query(sql);

    console.log('✅ Database setup complete!');
    console.log('   Database: enviora_db');
    console.log('   Tables  : waste_categories, waste_items, recycling_tips');
    console.log('   Seeded  : 6 categories, 37 items, 20 tips');
  } catch (err) {
    console.error('❌ Setup failed:', err.message);
    process.exit(1);
  } finally {
    if (connection) await connection.end();
  }
}

setup();
