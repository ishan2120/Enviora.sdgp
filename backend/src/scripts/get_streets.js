const mysql = require('mysql2/promise');
require('dotenv').config();

async function getStreets() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    try {
        const [rows] = await connection.query('SELECT road_name FROM route_stops LIMIT 10');
        console.log(JSON.stringify(rows, null, 2));
    } catch (error) {
        console.error('Failed to fetch streets:', error);
    } finally {
        await connection.end();
    }
}

getStreets();
