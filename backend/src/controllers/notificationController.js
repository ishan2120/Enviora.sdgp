const db = require('../config/database');

// @desc    Get user notifications
const getUserNotifications = async (req, res) => {
    try {
        const userId = 1;

        const [notifications] = await db.query(
            'SELECT id, message, is_read, date FROM notifications WHERE user_id = ? ORDER BY date DESC',
            [userId]
        );

        res.json(notifications);
    } catch (error) {
        console.error('Get notifications error:', error);
        res.status(500).json({ message: 'Server error fetching notifications' });
    }
};

// @desc    Add a notification
const addNotification = async (req, res) => {
    try {
        const userId = 1;
        const { message } = req.body;

        if (!message) {
            return res.status(400).json({ message: 'Missing message' });
        }

        const [result] = await db.query(
            'INSERT INTO notifications (user_id, message) VALUES (?, ?)',
            [userId, message]
        );

        res.status(201).json({
            message: 'Notification added successfully',
            notificationId: result.insertId
        });

    } catch (error) {
        console.error('Add notification error:', error);
        res.status(500).json({ message: 'Server error adding notification' });
    }
};

// @desc    Mark a notification as read
const markAsRead = async (req, res) => {
    try {
        const userId = 1;
        const notificationId = req.params.id;

        const [result] = await db.query(
            'UPDATE notifications SET is_read = TRUE WHERE id = ? AND user_id = ?',
            [notificationId, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'Notification not found or unauthorized' });
        }

        res.json({ message: 'Notification marked as read' });
    } catch (error) {
        console.error('Mark notification error:', error);
        res.status(500).json({ message: 'Server error updating notification' });
    }
};

// @desc    Clear all notifications for a user
const clearAllNotifications = async (req, res) => {
    try {
        const userId = req.user.userId;

        await db.query('DELETE FROM notifications WHERE user_id = ?', [userId]);

        res.json({ message: 'All notifications cleared' });
    } catch (error) {
        console.error('Clear notifications error:', error);
        res.status(500).json({ message: 'Server error clearing notifications' });
    }
};

module.exports = {
    getUserNotifications,
    addNotification,
    markAsRead,
    clearAllNotifications
};
