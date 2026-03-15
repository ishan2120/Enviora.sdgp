const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

// GET /notifications
router.get('/', verifyToken, async (req, res) => {
  try {
    const notifications = await db('notifications')
      .where({ user_id: req.user.id })
      .orderBy('created_at', 'desc')
      .limit(50);
    res.json({ notifications });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /notifications/:id/read
router.put('/:id/read', verifyToken, async (req, res) => {
  try {
    const n = await db('notifications').where({ id: req.params.id, user_id: req.user.id }).first();
    if (!n) return res.status(404).json({ error: 'Notification not found.' });
    await db('notifications').where({ id: req.params.id }).update({ is_read: true });
    res.json({ message: 'Marked as read.' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// DELETE /notifications — Clear all notifications for user
router.delete('/', verifyToken, async (req, res) => {
  try {
    await db('notifications').where({ user_id: req.user.id }).del();
    res.json({ message: 'All notifications cleared.' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
