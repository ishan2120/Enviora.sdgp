const express = require('express');
const router = express.Router();
const db = require('../db/connection');

// GET /api/wards
router.get('/', async (req, res) => {
  try {
    const [wards] = await db.query(
      'SELECT id, ward_name, district FROM wards ORDER BY ward_name'
    );
    res.json({ success: true, count: wards.length, data: wards });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/wards/:id
router.get('/:id', async (req, res) => {
  try {
    const [wards] = await db.query(
      'SELECT id, ward_name, district FROM wards WHERE id = ?',
      [req.params.id]
    );
    if (wards.length === 0) {
      return res.status(404).json({ success: false, error: 'Ward not found' });
    }
    res.json({ success: true, data: wards[0] });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
