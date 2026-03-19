const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

// GET /activity
router.get('/', verifyToken, async (req, res) => {
  try {
    const { type, filter } = req.query;
    let query = db('activity_history').where({ user_id: req.user.id }).orderBy('created_at', 'desc');

    if (type && type !== 'All') query = query.where({ type: type.toLowerCase() });
    if (filter === 'Completed') query = query.whereIn('status', ['completed', 'resolved']);

    const activities = await query;

    // Summary counts
    const all = await db('activity_history').where({ user_id: req.user.id });
    const summary = {
      total: all.length,
      pending: all.filter((a) => a.status === 'pending' || a.status === 'in_progress').length,
      completed: all.filter((a) => a.status === 'completed' || a.status === 'resolved').length,
    };

    res.json({ activities, summary });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// DELETE /activity/:id — Cancel a pending activity
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const item = await db('activity_history').where({ id: req.params.id, user_id: req.user.id }).first();
    if (!item) return res.status(404).json({ error: 'Activity not found.' });
    if (item.status !== 'pending') return res.status(400).json({ error: 'Only pending activities can be cancelled.' });
    await db('activity_history').where({ id: req.params.id }).del();
    res.json({ message: 'Activity cancelled successfully.' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
