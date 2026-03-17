const mysql = require('mysql2/promise');

// Create a connection pool to the XAMPP database
const pool = mysql.createPool({
  host: 'localhost',
  user: 'root',      // Default XAMPP username
  password: '',      // Default XAMPP password is empty
  database: 'sl_waste_dropoff',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

module.exports = pool;