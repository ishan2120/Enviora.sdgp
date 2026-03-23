const mysql = require('mysql2/promise');
require('dotenv').config();

async function seed() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST,
        user: process.env.DB_USER,
        password: process.env.DB_PASSWORD,
        database: process.env.DB_NAME
    });

    console.log('Seeding daily schedules for Hampden Lane and Pinto Place...');
    
    try {
        const PAMANKADA_WEST_ID = 1;
        const PERISHABLE_GARBAGE_ID = 2; // Mixed/Perishable
        const DAILY_ID = 8;
        const LORRY_1_ID = 1;

        // 1. Create a daily schedule if it doesn't exist for this combo
        // We'll create a special "Test Scale" entry
        const [existing] = await connection.query(
            'SELECT id FROM route_schedules WHERE ward_id = ? AND collection_type_id = ? AND day_id = ?',
            [PAMANKADA_WEST_ID, PERISHABLE_GARBAGE_ID, DAILY_ID]
        );

        let scheduleId;
        if (existing.length === 0) {
            const [result] = await connection.query(
                'INSERT INTO route_schedules (ward_id, collection_type_id, truck_id, day_id, load_number, time_starting, time_ending) VALUES (?, ?, ?, ?, ?, ?, ?)',
                [PAMANKADA_WEST_ID, PERISHABLE_GARBAGE_ID, LORRY_1_ID, DAILY_ID, 1, '08:00:00', '10:00:00']
            );
            scheduleId = result.insertId;
            console.log(`Created new daily schedule (ID: ${scheduleId}).`);
        } else {
            scheduleId = existing[0].id;
            console.log(`Using existing daily schedule (ID: ${scheduleId}).`);
        }

        // 2. Add Hampden Lane and Pinto Place to this schedule if not already there
        const roads = ['Hampden Lane', 'Pinto Place'];
        for (const road of roads) {
            const [stopExist] = await connection.query(
                'SELECT id FROM route_stops WHERE route_schedule_id = ? AND road_name = ?',
                [scheduleId, road]
            );

            if (stopExist.length === 0) {
                await connection.query(
                    'INSERT INTO route_stops (route_schedule_id, stop_order, road_name) VALUES (?, ?, ?)',
                    [scheduleId, 1, road]
                );
                console.log(`Added ${road} to daily schedule.`);
            } else {
                console.log(`${road} already exists in daily schedule.`);
            }
        }

        console.log('Seeding completed successfully.');

    } catch (error) {
        console.error('Seeding failed:', error);
    } finally {
        await connection.end();
    }
}

seed();
