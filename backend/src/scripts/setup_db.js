const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

async function setupDatabase() {
  let connection;
  try {
    console.log('Connecting to MySQL server...');
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      multipleStatements: true
    });

    const dbName = process.env.DB_NAME || 'enviora_db';
    console.log(`Creating database '${dbName}' if not exists...`);
    await connection.query(`CREATE DATABASE IF NOT EXISTS \`${dbName}\`;`);
    await connection.query(`USE \`${dbName}\`;`);

    const tables = [
      {
        name: 'users',
        query: `CREATE TABLE IF NOT EXISTS users (
          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL UNIQUE,
          password_hash VARCHAR(255) NOT NULL,
          total_points INT UNSIGNED DEFAULT 0,
          preferred_language VARCHAR(10) DEFAULT 'en',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        )`
      },
      {
        name: 'activities',
        query: `CREATE TABLE IF NOT EXISTS activities (
          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
          user_id INT UNSIGNED NOT NULL,
          action_type VARCHAR(255) NOT NULL,
          points_earned INT NOT NULL,
          date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`
      },
      {
        name: 'notifications',
        query: `CREATE TABLE IF NOT EXISTS notifications (
          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
          user_id INT UNSIGNED NOT NULL,
          message TEXT NOT NULL,
          is_read BOOLEAN DEFAULT FALSE,
          date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
        )`
      },
      {
        name: 'waste_categories',
        query: `CREATE TABLE IF NOT EXISTS waste_categories (
          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
          name VARCHAR(255) NOT NULL,
          slug VARCHAR(255) NOT NULL UNIQUE,
          description TEXT,
          image_url TEXT,
          color_hex VARCHAR(10) DEFAULT '#4CAF50',
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )`
      },
      {
        name: 'waste_items',
        query: `CREATE TABLE IF NOT EXISTS waste_items (
          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
          category_id INT UNSIGNED NOT NULL,
          name VARCHAR(255) NOT NULL,
          image_url TEXT,
          short_description TEXT,
          disposal_instructions JSON,
          youtube_video_url TEXT,
          tags JSON,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (category_id) REFERENCES waste_categories(id) ON DELETE CASCADE
        )`
      },
      {
        name: 'recycling_tips',
        query: `CREATE TABLE IF NOT EXISTS recycling_tips (
          id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
          tip TEXT NOT NULL,
          source VARCHAR(255),
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )`
      }
    ];

    for (const table of tables) {
      try {
        console.log(`Ensuring table '${table.name}' exists...`);
        await connection.query(table.query);
      } catch (err) {
        console.warn(`Warning ensuring table '${table.name}':`, err.message);
      }
    }

    // Seed Data
    console.log('Seeding initial data...');
    try {
      await connection.query(`
        INSERT IGNORE INTO waste_categories (id, name, slug, description, image_url, color_hex)
        VALUES 
        (1, 'Organic', 'organic', 'Food scraps and garden waste', 'https://images.unsplash.com/photo-1542838132-92c53300491e', '#8BC34A'),
        (2, 'Recyclable', 'recyclable', 'Plastic, metal and glass', 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b', '#2196F3'),
        (3, 'Paper', 'paper', 'Cardboard and paper products', 'https://images.unsplash.com/photo-1595079676339-1534801ad6cf', '#FF9800'),
        (4, 'Plastic', 'plastic', 'Plastic bottles and containers', 'https://images.unsplash.com/photo-1526951521990-620dc14c214b', '#E91E63'),
        (5, 'Glass', 'glass', 'Glass bottles and jars', 'https://images.unsplash.com/photo-1618544250420-237362db855c', '#00BCD4'),
        (6, 'E-Waste', 'e-waste', 'Electronic devices and batteries', 'https://images.unsplash.com/photo-1550009158-9ebf69173e03', '#607D8B');

        INSERT IGNORE INTO waste_items (category_id, name, short_description, disposal_instructions, tags)
        VALUES 
        (1, 'Banana Peel', 'Fruit waste', '["Add to compost bin", "Do not include labels"]', '["organic", "fruit"]'),
        (2, 'Plastic Bottle', 'PET bottles', '["Rinse thoroughly", "Remove cap", "Crush to save space"]', '["plastic", "bottle", "PET"]'),
        (3, 'Cardboard Box', 'Packaging material', '["Flatten before disposal", "Remove plastic tape"]', '["paper", "cardboard"]');
      `);
    } catch (err) {
      console.warn('Warning during seeding:', err.message);
    }

    console.log('Database setup process finished.');
  } catch (error) {
    console.error('Fatal error during database setup:', error);
  } finally {
    if (connection) await connection.end();
  }
}

setupDatabase();
