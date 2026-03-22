const express = require('express');
const router = express.Router();
const db = require('../../config/database');
const auth = require('../../middleware/dashboardAuth');

// ── GET ALL NOTIFICATIONS ─────────────────────────────────────────────────────
// Powers the notification bell on the home screen
router.get('/', auth, async (req, res) => {
  try {
    const [notifications] = await db.query(
      `SELECT * FROM notifications
       WHERE user_id = ?
       ORDER BY created_at DESC`,
      [req.user.id]
    );

    // Count unread notifications (for the red dot on the bell)
    const [unread] = await db.query(
      `SELECT COUNT(*) as count FROM notifications
       WHERE user_id = ? AND is_read = FALSE`,
      [req.user.id]
    );

    res.json({
      success: true,
      unreadCount: unread[0].count,
      notifications,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── MARK ONE NOTIFICATION AS READ ────────────────────────────────────────────
router.patch('/:id/read', auth, async (req, res) => {
  try {
    await db.query(
      `UPDATE notifications SET is_read = TRUE
       WHERE id = ? AND user_id = ?`,
      [req.params.id, req.user.id]
    );

    res.json({ success: true, message: 'Notification marked as read.' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── MARK ALL NOTIFICATIONS AS READ ───────────────────────────────────────────
// Called when user taps the bell icon
router.patch('/read-all', auth, async (req, res) => {
  try {
    await db.query(
      `UPDATE notifications SET is_read = TRUE
       WHERE user_id = ?`,
      [req.user.id]
    );

    res.json({ success: true, message: 'All notifications marked as read.' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── CREATE A NOTIFICATION ─────────────────────────────────────────────────────
// Used internally by the server to send notifications to users
router.post('/', auth, async (req, res) => {
  try {
    const { title, body } = req.body;

    const [result] = await db.query(
      `INSERT INTO notifications (user_id, title, body)
       VALUES (?, ?, ?)`,
      [req.user.id, title, body]
    );

    res.status(201).json({
      success: true,
      message: 'Notification created.',
      notificationId: result.insertId,
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;