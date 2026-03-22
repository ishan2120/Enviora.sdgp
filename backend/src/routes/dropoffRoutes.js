const express = require('express');
const router = express.Router();
const db = require('../db'); 

// 1. Your existing Search Route
router.get('/search', async (req, res) => {
  try {
    const searchTerm = req.query.q || '';
    const searchPattern = `%${searchTerm}%`; 

    const sqlQuery = `
      SELECT 
        f.id,
        f.facility_name, 
        wc.category_name, 
        IFNULL(f.operational_address, f.office_address) AS address, 
        f.city, 
        f.latitude, 
        f.longitude
      FROM facilities f
      JOIN waste_categories wc ON f.category_id = wc.id
      WHERE f.facility_name LIKE ? 
         OR wc.category_name LIKE ? 
         OR f.city LIKE ? 
         OR IFNULL(f.operational_address, f.office_address) LIKE ?
    `;

    const [rows] = await db.execute(sqlQuery, [searchPattern, searchPattern, searchPattern, searchPattern]);
    res.json({ success: true, count: rows.length, data: rows });

  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch drop-off locations' });
  }
});

// 2. The MISSING Category Route (This is what Flutter is waiting for!)
router.get('/:category', async (req, res) => {
  try {
    const categoryName = req.params.category;

    // Queries the pre-built view from your srilanka_waste_dropoff.sql database
    const [rows] = await db.query(
      'SELECT * FROM v_dropoff_directory WHERE Category = ?', 
      [categoryName]
    );

    res.json(rows);
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({ error: 'Failed to fetch drop-off locations' });
  }
});

module.exports = router;