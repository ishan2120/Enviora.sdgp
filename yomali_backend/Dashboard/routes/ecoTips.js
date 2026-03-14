const express = require('express');
const router = express.Router();
const db = require('../config/database');
const auth = require('../middleware/auth');

router.get('/daily', auth, async (req, res) => {
  try {
    const [users] = await db.query(
      'SELECT language FROM users WHERE id = ?',
      [req.user.id]
    );

    const language = users[0]?.language || 'en';

    const [randomTips] = await db.query(
      `SELECT * FROM eco_tips
       WHERE is_active = TRUE
       ORDER BY RAND()
       LIMIT 1`
    );

    const tip = randomTips[0];

    if (!tip) {
      return res.json({ success: true, tip: null });
    }

    res.json({
      success: true,
      tip: {
        id: tip.id,
        title: language === 'ta' && tip.title_ta ? tip.title_ta
             : language === 'si' && tip.title_si ? tip.title_si
             : tip.title,
        content: language === 'ta' && tip.content_ta ? tip.content_ta
                : language === 'si' && tip.content_si ? tip.content_si
                : tip.content,
        category: tip.category,
      },
    });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

router.get('/', auth, async (req, res) => {
  try {
    const [tips] = await db.query(
      `SELECT * FROM eco_tips
       WHERE is_active = TRUE
       ORDER BY sort_order ASC`
    );
    res.json({ success: true, tips });
  } catch (err) {
    res.status(500).json({ success: false, message: err.message });
  }
});

module.exports = router;