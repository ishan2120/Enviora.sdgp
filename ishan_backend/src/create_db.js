const mysql = require('mysql2/promise');
require('dotenv').config();

async function createDb() {
  const connection = await mysql.createConnection({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD,
  });

  try {
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${process.env.DB_NAME || 'enviora_db'}\`;`);
    console.log(`✅ Database ${process.env.DB_NAME || 'enviora_db'} created or already exists.`);
  } catch (err) {
    console.error('❌ Error creating database:', err);
    process.exit(1);
  } finally {
    await connection.end();
  }
}

createDb();
