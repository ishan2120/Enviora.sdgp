const db = require('../config/database');

// @desc    Get all reports for the user
const getUserReports = async (req, res) => {
    try {
        const userId = 1; // Default user for simplified app
        const [reports] = await db.query(
            'SELECT * FROM reports WHERE user_id = ? ORDER BY date DESC',
            [userId]
        );
        res.json(reports);
    } catch (error) {
        console.error('Get reports error:', error);
        res.status(500).json({ message: 'Server error fetching reports' });
    }
};

// @desc    Create a new report (complaint)
const createReport = async (req, res) => {
    try {
        const userId = 1;
        const { report_type, issue_type, details, location, image_path } = req.body;

        if (!report_type || !issue_type) {
            return res.status(400).json({ message: 'Missing report_type or issue_type' });
        }

        const [result] = await db.query(
            'INSERT INTO reports (user_id, report_type, issue_type, details, location, image_path) VALUES (?, ?, ?, ?, ?, ?)',
            [userId, report_type, issue_type, details, location, image_path]
        );

        res.status(201).json({
            message: 'Report submitted successfully',
            reportId: result.insertId
        });
    } catch (error) {
        console.error('Create report error:', error);
        res.status(500).json({ message: 'Server error creating report' });
    }
};

module.exports = {
    getUserReports,
    createReport
};
