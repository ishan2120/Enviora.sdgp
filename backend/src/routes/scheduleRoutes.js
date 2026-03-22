const express = require('express');
const router = express.Router();
const scheduleController = require('../controllers/scheduleController');

// Get personalized schedule for the user


// Get today/tomorrow notifications
router.get('/notifications', scheduleController.getNotifications);

module.exports = router;
