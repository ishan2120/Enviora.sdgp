const db = require('../config/database');

// @desc    Get user activity history
const getUserActivities = async (req, res) => {
    try {
        const userId = 1;

        const [activities] = await db.query(
            'SELECT id, action_type, points_earned, date FROM activities WHERE user_id = ? ORDER BY date DESC',
            [userId]
        );

        res.json(activities);
    } catch (error) {
        console.error('Get activities error:', error);
        res.status(500).json({ message: 'Server error fetching activities' });
    }
};

// @desc    Add a new activity
const addActivity = async (req, res) => {
    try {
        const userId = req.user.userId;
        const { action_type, points_earned } = req.body;

        if (!action_type || points_earned === undefined) {
            return res.status(400).json({ message: 'Missing action_type or points_earned' });
        }

        // Insert activity
        const [result] = await db.query(
            'INSERT INTO activities (user_id, action_type, points_earned) VALUES (?, ?, ?)',
            [userId, action_type, points_earned]
        );

        // Update user points
        await db.query(
            'UPDATE users SET points = points + ? WHERE id = ?',
            [points_earned, userId]
        );

        res.status(201).json({
            message: 'Activity added successfully',
            activityId: result.insertId,
            pointsAdded: points_earned
        });

    } catch (error) {
        console.error('Add activity error:', error);
        res.status(500).json({ message: 'Server error adding activity' });
    }
};

module.exports = {
    getUserActivities,
    addActivity
};
