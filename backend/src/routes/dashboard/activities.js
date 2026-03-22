const express = require('express');
const router = express.Router();
const db = require('../../config/database');
const auth = require('../../middleware/dashboardAuth');

// ── GET RECENT ACTIVITIES ─────────────────────────────────────────────────────
// Powers the "Recent Activity" section on the home screen
router.get('/', auth, async (req, res) => {
  try {
    const [activities] = await db.query(
      `SELECT * FROM activities
       WHERE user_id = ?
       ORDER BY created_at DESC
       LIMIT 10`,
      [req.user.id]
    );

    // Count unread activities
    const [unread] = await db.query(
      `SELECT COUNT(*) as count FROM activities
       WHERE user_id = ? AND is_read = FALSE`,
      [req.user.id]
    );

    res.json({
      success: true,
      unreadCount: unread[0].count,
      activities,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── MARK ALL ACTIVITIES AS READ ───────────────────────────────────────────────
router.patch('/read-all', auth, async (req, res) => {
  try {
    await db.query(
      `UPDATE activities SET is_read = TRUE
       WHERE user_id = ?`,
      [req.user.id]
    );

    res.json({ success: true, message: 'All activities marked as read.' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── MARK ONE ACTIVITY AS READ ─────────────────────────────────────────────────
router.patch('/:id/read', auth, async (req, res) => {
  try {
    await db.query(
      `UPDATE activities SET is_read = TRUE
       WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );

    res.json({ success: true, message: 'Activity marked as read.' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;