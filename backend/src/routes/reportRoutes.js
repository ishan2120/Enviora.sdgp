const express = require('express');
const router = express.Router();
const { getUserReports, createReport } = require('../controllers/reportController');

// @route   GET /api/reports
// @desc    Get all reports
router.get('/', getUserReports);

// @route   POST /api/reports
// @desc    Create a new report
router.post('/', createReport);

module.exports = router;
