const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

async function seedDatabase() {
  let connection;
  try {
    const dbName = process.env.DB_NAME || 'enviora_db';
    console.log(`Connecting to database '${dbName}'...`);
    connection = await mysql.createConnection({
      host: process.env.DB_HOST,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      database: dbName
    });

    // Check if user 1 exists
    const [users] = await connection.query('SELECT * FROM users WHERE id = 1');
    
    if (users.length === 0) {
      console.log('Seeding default user...');
      await connection.query(`
        INSERT INTO users (id, name, email, password, points, language_preference)
        VALUES (1, 'G.G.K.Ranudaya', 'ggkranudaya@gmail.com', 'demo123', 1000, 'en')
      `);

      console.log('Seeding sample activities...');
      await connection.query(`
        INSERT INTO activities (user_id, action_type, points_earned)
        VALUES 
        (1, 'Illegal Dumping Reported', 50),
        (1, 'Recycling Collection', 20)
      `);

      console.log('Seeding sample notifications...');
      await connection.query(`
        INSERT INTO notifications (user_id, message)
        VALUES 
        (1, 'Your report #EV-7740 has been updated to In Progress.'),
        (1, 'Next garbage collection in your area is tomorrow.')
      `);
    } else {
      console.log('User 1 already exists. Skipping seed.');
    }

    console.log('Seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding database:', error);
  } finally {
    if (connection) {
      await connection.end();
    }
  }
}

seedDatabase();
