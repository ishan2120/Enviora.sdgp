const express = require('express');
const router = express.Router();
const { getUserProfile, updateUserProfile } = require('../controllers/profileController');

// @route   GET /api/profile
// @desc    Get user profile
// @access  Private
router.get('/', getUserProfile);

// @route   PUT /api/profile
// @desc    Update user profile
// @access  Private
router.put('/', updateUserProfile);

module.exports = router;
