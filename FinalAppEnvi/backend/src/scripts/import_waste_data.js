const mysql = require('mysql2/promise');
const fs = require('fs');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

async function importSql() {
  let connection;
  try {
    const sqlPath = path.join(__dirname, '../../../waste_collection_db.sql');
    if (!fs.existsSync(sqlPath)) {
      console.error('SQL file not found at:', sqlPath);
      return;
    }

    console.log('Reading SQL file...');
    const sql = fs.readFileSync(sqlPath, 'utf8');

    console.log('Connecting to database...');
    console.log('DB Config:', {
      host: '127.0.0.1',
      user: process.env.DB_USER || 'root',
      database: process.env.DB_NAME || 'enviora_db'
    });

    connection = await mysql.createConnection({
      host: '127.0.0.1',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'enviora_db',
      multipleStatements: true
    });

    // The SQL file contains CREATE DATABASE/USE which might conflict with our current DB name.
    // We'll strip those specific lines or just let it create a second DB if needed, 
    // but better to keep it in the same DB.
    
    // Removing CREATE DATABASE and USE statements to stay in enviora_db
    const sanitizedSql = `
      SET FOREIGN_KEY_CHECKS = 0;
      START TRANSACTION;
      ${sql.replace(/CREATE DATABASE IF NOT EXISTS `cleantech_district05`[\s\S]*?;/, '').replace(/USE `cleantech_district05`;/, '')}
      COMMIT;
      SET FOREIGN_KEY_CHECKS = 1;
    `;

    console.log('Executing SQL script...');
    await connection.query(sanitizedSql);

    console.log('Import successful!');

    // Now update users table with address fields
    console.log('Adding address fields to users table...');
    try {
      await connection.query(`ALTER TABLE users 
        ADD COLUMN street VARCHAR(255),
        ADD COLUMN lane VARCHAR(255),
        ADD COLUMN city VARCHAR(100),
        ADD COLUMN ward_id TINYINT UNSIGNED;`);
        
      // Set default address for demo user
      await connection.query(`UPDATE users SET 
        street = 'Hampden Lane', 
        lane = '1st Lane', 
        city = 'Colombo',
        ward_id = 1
        WHERE id = 1;`);
    } catch (err) {
      if (err.code === 'ER_DUP_COLUMN_NAME') {
        console.log('Address columns already exist.');
      } else {
        throw err;
      }
    }

  } catch (error) {
    console.error('Import failed:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

importSql();
