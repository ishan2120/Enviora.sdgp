const mysql = require('mysql2/promise');
require('dotenv').config();

async function migrate() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log('Migrating users table and updating sample users...');
    
    try {
        // 1. Ensure address column exists (already checked, but being safe)
        const [columns] = await connection.query('SHOW COLUMNS FROM users LIKE "address"');
        if (columns.length === 0) {
            await connection.query('ALTER TABLE users ADD COLUMN address TEXT AFTER email');
            console.log('Added "address" column to users table.');
        }

        // 2. Ensure mobile column exists (since I saw "mobile" in previous check)
        
        // 3. Update or Insert the specific users requested
        const usersToUpdate = [
            { name: 'Senath', email: 'Senathpahalawatta@gmail.com', address: 'Hampden Lane' },
            { name: 'Ishan', email: 'ishansandeepa2222@gmail.com', address: 'Pinto Place' }
        ];

        for (const u of usersToUpdate) {
            // Check if user exists first to decide on password field name
            const [rows] = await connection.query('SELECT * FROM users WHERE email = ?', [u.email]);
            
            if (rows.length > 0) {
                await connection.query(
                    'UPDATE users SET address = ? WHERE email = ?',
                    [u.address, u.email]
                );
                console.log(`Updated user ${u.email} with address ${u.address}.`);
            } else {
                // Determine password column name (some tables use password, some password_hash)
                const [passCol] = await connection.query('SHOW COLUMNS FROM users LIKE "password_hash"');
                const passwordColumn = passCol.length > 0 ? 'password_hash' : 'password';
                
                await connection.query(
                    `INSERT INTO users (name, email, address, ${passwordColumn}, mobile) VALUES (?, ?, ?, ?, ?)`,
                    [u.name, u.email, u.address, 'demo123', '0000000000']
                );
                console.log(`Inserted user ${u.email} with address ${u.address}.`);
            }
        }

    } catch (error) {
        console.error('Migration failed:', error);
    } finally {
        await connection.end();
    }
}

migrate();
