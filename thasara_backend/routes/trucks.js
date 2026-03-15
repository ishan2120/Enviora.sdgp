const express = require('express');
const router = express.Router();
const db = require('../db/connection');

// GET /api/trucks
router.get('/', async (req, res) => {
  try {
    const [trucks] = await db.query(
      'SELECT id, truck_label FROM trucks ORDER BY truck_label'
    );
    res.json({ success: true, data: trucks });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
