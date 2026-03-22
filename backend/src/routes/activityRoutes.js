const express = require('express');
const router = express.Router();
const { getUserActivities, addActivity } = require('../controllers/activityController');


// @desc    Get all activities for a user
// @access  Private
router.get('/', getUserActivities);

// @route   POST /api/activities
// @desc    Add a new activity
// @access  Private
router.post('/', addActivity);

module.exports = router;
