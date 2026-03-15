const express = require('express');
const router = express.Router();
const db = require('../db/connection');

// GET /api/collection-types
router.get('/', async (req, res) => {
  try {
    const [types] = await db.query(
      'SELECT id, type FROM collection_types ORDER BY type'
    );
    res.json({ success: true, data: types });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
