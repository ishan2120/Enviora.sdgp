const express = require('express');
const router = express.Router();
const db = require('../../config/database');

// GET announcements based on address
router.get('/', async (req, res) => {
    try {
        const { address } = req.query;
        let query = 'SELECT * FROM announcements ORDER BY created_at DESC';
        let params = [];

        if (address) {
            // Include announcements targeting the specific address, or 'all' if you want a global one
            query = 'SELECT * FROM announcements WHERE target_address LIKE ? OR target_address = "all" ORDER BY created_at DESC';
            params = [`%${address}%`];
        }

        const [rows] = await db.query(query, params);
        res.json({ success: true, announcements: rows });
    } catch (error) {
        console.error('Error fetching announcements:', error);
        res.status(500).json({ success: false, message: 'Failed to fetch announcements' });
    }
});

// POST a new announcement (Supervisor)
router.post('/', async (req, res) => {
    try {
        const { target_address, message, type } = req.body;
        
        if (!message) {
            return res.status(400).json({ success: false, message: 'Message is required' });
        }

        const [result] = await db.query(
            'INSERT INTO announcements (target_address, message, type) VALUES (?, ?, ?)',
            [target_address || 'all', message, type || 'general']
        );

        res.status(201).json({ 
            success: true, 
            message: 'Announcement created successfully',
            announcement: {
                id: result.insertId,
                target_address: target_address || 'all',
                message,
                type: type || 'general'
            }
        });
    } catch (error) {
        console.error('Error creating announcement:', error);
        res.status(500).json({ success: false, message: 'Failed to create announcement' });
    }
});

module.exports = router;
