const express = require('express');
const router = express.Router();
const db = require('../../config/database');
const auth = require('../../middleware/dashboardAuth');

// ── GET UPCOMING SCHEDULE ─────────────────────────────────────────────────────
// This powers the green card on the home screen
router.get('/upcoming', auth, async (req, res) => {
  try {
    // Get the user's zone
    const [users] = await db.query(
      'SELECT zone_id FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0 || !users[0].zone_id) {
      return res.json({ success: true, schedule: null });
    }

    const zoneId = users[0].zone_id;

    // Get the next upcoming schedule for that zone
    const [schedules] = await db.query(
      `SELECT s.*, t.is_nearby, t.eta_minutes
       FROM schedules s
       LEFT JOIN trucks t ON s.truck_id = t.id
       WHERE s.zone_id = ?
       AND s.status = 'upcoming'
       AND s.scheduled_date >= NOW()
       ORDER BY s.scheduled_date ASC
       LIMIT 1`,
      [zoneId]
    );

    if (schedules.length === 0) {
      return res.json({ success: true, schedule: null });
    }

    const schedule = schedules[0];

    // Calculate days until pickup
    const now = new Date();
    const pickupDate = new Date(schedule.scheduled_date);
    const diffMs = pickupDate - now;
    const daysUntil = Math.ceil(diffMs / (1000 * 60 * 60 * 24));
    const isToday = pickupDate.toDateString() === now.toDateString();
    const isTomorrow = new Date(now.getTime() + 24 * 60 * 60 * 1000).toDateString() === pickupDate.toDateString();

    res.json({
      success: true,
      schedule: {
        ...schedule,
        daysUntil,
        isToday,
        isTomorrow,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── GET ALL SCHEDULES ─────────────────────────────────────────────────────────
// This powers the View Schedule screen
router.get('/', auth, async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT zone_id FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0 || !users[0].zone_id) {
      return res.json({ success: true, schedules: [] });
    }

    const [schedules] = await db.query(
      `SELECT * FROM schedules
       WHERE zone_id = ?
       AND scheduled_date >= NOW()
       ORDER BY scheduled_date ASC`,
      [users[0].zone_id]
    );

    res.json({ success: true, schedules });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;