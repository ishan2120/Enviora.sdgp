const express = require('express');
const router = express.Router();
const db = require('../config/database');

// GET /guide/categories — public route
router.get('/categories', async (req, res) => {
  try {
    const { search } = req.query;
    let query = db('segregation_guide_items').orderBy('id', 'asc');
    if (search) {
      const s = `%${search}%`;
      query = query.where((q) => q.whereLike('title', s).orWhereLike('subtitle', s).orWhereLike('details', s));
    }
    const categories = await query;
    res.json({ categories });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
