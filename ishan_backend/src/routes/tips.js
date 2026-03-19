const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET /tips/daily — returns one random active tip (public route)
router.get('/daily', async (req, res) => {
  try {
    const tips = await db('eco_tips').where({ is_active: true });
    if (!tips.length) return res.json({ tip: null });
    // Rotate daily by using the day-of-year as index
    const dayOfYear = Math.floor((Date.now() - new Date(new Date().getFullYear(), 0, 0)) / 86400000);
    const tip = tips[dayOfYear % tips.length];
    res.json({ tip });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
