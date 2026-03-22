const mysql = require('mysql2/promise');
require('dotenv').config();

async function alterDatabase() {
    let connection;
    try {
        connection = await mysql.createConnection({
            host: process.env.DB_HOST,
            user: process.env.DB_USER,
            password: process.env.DB_PASSWORD,
            database: process.env.DB_NAME || 'enviora_db'
        });

        console.log('Altering users table...');
        await connection.query(`
            ALTER TABLE users 
            ADD COLUMN reset_otp VARCHAR(10),
            ADD COLUMN reset_otp_expires TIMESTAMP NULL;
        `);
        console.log('Database altered successfully!');
    } catch (error) {
        if (error.code === 'ER_DUP_FIELDNAME') {
            console.log('Columns already exist.');
        } else {
            console.error('Error altering database:', error);
        }
    } finally {
        if (connection) {
            await connection.end();
        }
    }
}

alterDatabase();
