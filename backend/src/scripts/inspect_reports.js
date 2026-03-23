const mysql = require('mysql2/promise');
require('dotenv').config();

async function inspect() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    try {
        const [columns] = await connection.query('SHOW COLUMNS FROM reports');
        console.log(JSON.stringify(columns, null, 2));
    } catch (error) {
        console.error('Inspection failed:', error);
    } finally {
        await connection.end();
    }
}

inspect();
