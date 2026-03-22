const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log('Checking reports table structure...');
    
    try {
        const [columns] = await connection.query('SHOW COLUMNS FROM reports LIKE "location"');
        
        if (columns.length === 0) {
            console.log('Adding "location" column to reports table...');
            await connection.query('ALTER TABLE reports ADD COLUMN location VARCHAR(255)');
            console.log('Column added successfully.');
        } else {
            console.log('"location" column already exists.');
        }
    } catch (error) {
        console.error('Migration failed:', error);
    } finally {
        await connection.end();
    }
}

migrate();
