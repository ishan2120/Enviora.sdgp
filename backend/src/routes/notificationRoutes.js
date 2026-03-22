const express = require('express');
const router = express.Router();
const {
    getUserNotifications,
    addNotification,
    markAsRead,
    clearAllNotifications
} = require('../controllers/notificationController');

// @route   GET /api/notifications
// @desc    Get all notifications for a user
// @access  Private
router.get('/', getUserNotifications);

// @route   POST /api/notifications
// @desc    Add a notification
// @access  Private
router.post('/', addNotification);

// @route   PUT /api/notifications/:id/read
// @desc    Mark a notification as read
// @access  Private
router.put('/:id/read', markAsRead);

// @route   DELETE /api/notifications
// @desc    Clear all notifications
// @access  Private
router.delete('/', clearAllNotifications);

module.exports = router;
