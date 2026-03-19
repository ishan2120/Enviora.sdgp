const express = require('express');
const router = express.Router();
const db = require('../config/database');
const auth = require('../middleware/auth');

// ── REPORT AN ISSUE ───────────────────────────────────────────────────────────
// This is triggered by the REPORT ISSUE button on the home screen
router.post('/', auth, async (req, res) => {
  try {
    const { type, title, description } = req.body;

    const [result] = await db.query(
      `INSERT INTO issues (reported_by, type, title, description)
       VALUES (?, ?, ?, ?)`,
      [req.user.id, type, title, description]
    );

    // Also add to activity feed
    await db.query(
      `INSERT INTO activities (user_id, type, title, display_time)
       VALUES (?, 'issue_reported', ?, 'Just now')`,
      [req.user.id, `Issue Reported: ${title}`]
    );

    res.status(201).json({
      success: true,
      message: 'Issue reported successfully.',
      issueId: result.insertId,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── GET MY ISSUES ─────────────────────────────────────────────────────────────
// Shows all issues the logged in user has reported
router.get('/my', auth, async (req, res) => {
  try {
    const [issues] = await db.query(
      `SELECT * FROM issues
       WHERE reported_by = ?
       ORDER BY created_at DESC`,
      [req.user.id]
    );

    res.json({ success: true, issues });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── GET SINGLE ISSUE ──────────────────────────────────────────────────────────
router.get('/:id', auth, async (req, res) => {
  try {
    const [issues] = await db.query(
      'SELECT * FROM issues WHERE id = ? AND reported_by = ?',
      [req.params.id, req.user.id]
    );

    if (issues.length === 0) {
      return res.status(404).json({ success: false, message: 'Issue not found.' });
    }

    res.json({ success: true, issue: issues[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;