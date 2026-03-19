const express = require('express');
const router = express.Router();
const db = require('../config/database');
const auth = require('../middleware/auth');

// ── GET TRUCK FOR USER'S ZONE ─────────────────────────────────────────────────
// This powers the "TRUCK IS NEARBY" banner on the home screen
router.get('/zone', auth, async (req, res) => {
  try {
    // Get the user's zone
    const [users] = await db.query(
      'SELECT zone_id FROM users WHERE id = ?',
      [req.user.id]
    );

    if (users.length === 0 || !users[0].zone_id) {
      return res.json({ success: true, truck: null });
    }

    // Get the truck in that zone
    const [trucks] = await db.query(
      `SELECT t.*, u.name as driver_name, u.phone as driver_phone
       FROM trucks t
       LEFT JOIN users u ON t.driver_id = u.id
       WHERE t.zone_id = ?
       LIMIT 1`,
      [users[0].zone_id]
    );

    if (trucks.length === 0) {
      return res.json({ success: true, truck: null });
    }

    res.json({ success: true, truck: trucks[0] });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

// ── UPDATE TRUCK LOCATION ─────────────────────────────────────────────────────
// Driver calls this to update GPS position
router.patch('/:id/location', auth, async (req, res) => {
  try {
    const { lat, lng, eta_minutes, is_nearby } = req.body;

    await db.query(
      `UPDATE trucks
       SET current_lat = ?, current_lng = ?, eta_minutes = ?, is_nearby = ?
       WHERE id = ?`,
      [lat, lng, eta_minutes, is_nearby, req.params.id]
    );

    res.json({ success: true, message: 'Location updated.' });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;