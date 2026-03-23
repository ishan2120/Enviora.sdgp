const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

async function checkSegregationData() {
  let connection;
  try {
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'enviora_db'
    });

    try {
      const [sgi] = await connection.query('DESCRIBE segregation_guide_items');
      console.log('segregation_guide_items Schema:', sgi);
      const [data] = await connection.query('SELECT * FROM segregation_guide_items LIMIT 5');
      console.log('segregation_guide_items Sample:', data);
    } catch (e) {
      console.log('segregation_guide_items NOT FOUND');
    }

    try {
      const [wi] = await connection.query('DESCRIBE waste_items');
      console.log('waste_items Schema:', wi);
      const [data2] = await connection.query('SELECT * FROM waste_items LIMIT 5');
      console.log('waste_items Sample:', data2);
    } catch (e) {
      console.log('waste_items NOT FOUND');
    }

    try {
        const [tips] = await connection.query('SELECT * FROM recycling_tips LIMIT 5');
        console.log('Recycling Tips Sample:', tips);
    } catch (e) {
        console.log('recycling_tips NOT FOUND');
    }

  } catch (error) {
    console.error('Check failed:', error.message);
  } finally {
    if (connection) await connection.end();
  }
}
checkSegregationData();
