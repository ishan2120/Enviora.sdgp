const express = require('express');
const router = express.Router();
const db = require('../db'); // This brings in the database connection we just made

// Endpoint: GET /api/dropoffs/search?q=YourSearchTerm
router.get('/search', async (req, res) => {
  try {
    // 1. Get the search term from the URL, default to empty string if missing
    const searchTerm = req.query.q || '';
    
    // 2. Add the % wildcards so it matches the term anywhere in the text
    const searchPattern = `%${searchTerm}%`; 

    // 3. The SQL Query: We join the facilities and categories tables to get all details, including our new map coordinates
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

    // 4. Run the query (we pass the searchPattern 4 times because we have 4 '?' placeholders)
    const [rows] = await db.execute(sqlQuery, [searchPattern, searchPattern, searchPattern, searchPattern]);

    // 5. Send the results back to Flutter
    res.json({ success: true, count: rows.length, data: rows });

  } catch (error) {
    console.error('Search error:', error);
    res.status(500).json({ success: false, message: 'Failed to fetch drop-off locations' });
  }
});

module.exports = router;