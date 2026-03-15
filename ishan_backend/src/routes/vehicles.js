const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

// GET /vehicles/active — Get active vehicle for user's zone (with route path)
router.get('/active', verifyToken, async (req, res) => {
  try {
    const user = await db('users').where({ id: req.user.id }).select('zone_id').first();
    if (!user || !user.zone_id) return res.status(404).json({ error: 'User has no zone assigned.' });

    const vehicle = await db('vehicles').where({ zone_id: user.zone_id }).first();
    if (!vehicle) return res.status(404).json({ error: 'No active vehicle in your zone.' });

    const route_path = await db('vehicle_route_path')
      .where({ vehicle_id: vehicle.id })
      .orderBy('sequence', 'asc')
      .select('latitude', 'longitude', 'sequence');

    res.json({ vehicle, route_path });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
