const db = require('../config/database');

/**
 * GET /api/v1/tips/random
 * Returns a single random recycling tip
 */
const getRandomTip = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, tip, source FROM recycling_tips ORDER BY RAND() LIMIT 1`
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'No tips available' });
    }

    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('getRandomTip error:', err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

/**
 * GET /api/v1/tips
 * Returns all recycling tips (paginated)
 */
const getAllTips = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT id, tip, source FROM recycling_tips ORDER BY id ASC`
    );

    return res.json({ success: true, data: rows, total: rows.length });
  } catch (err) {
    console.error('getAllTips error:', err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

module.exports = { getRandomTip, getAllTips };
