const express = require('express');
const router = express.Router();

const { getAllCategories, getCategoryBySlug } = require('../controllers/segregation/categoriesController');
const { getItems, getItemById, searchItems } = require('../controllers/segregation/itemsController');
const { getRandomTip, getAllTips } = require('../controllers/segregation/tipsController');

// ── Health check ────────────────────────────────────────────────
router.get('/health', (req, res) => {
  res.json({
    success: true,
    message: 'Enviora API is running',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// ── Waste Categories ─────────────────────────────────────────────
// GET /api/v1/categories          → all categories
// GET /api/v1/categories/:slug    → single category by slug
router.get('/categories', getAllCategories);
router.get('/categories/:slug', getCategoryBySlug);

// ── Waste Items ──────────────────────────────────────────────────
// GET /api/v1/items               → all items (paginated, optional ?category_id=)
// GET /api/v1/items/search        → search items by name/tag (?q=)
// GET /api/v1/items/:id           → single item with full details + video
router.get('/items/search', searchItems);   // must be before /:id
router.get('/items', getItems);
router.get('/items/:id', getItemById);

// ── Recycling Tips ───────────────────────────────────────────────
// GET /api/v1/tips/random         → one random tip (used by "Did You Know?" widget)
// GET /api/v1/tips                → all tips
router.get('/tips/random', getRandomTip);   // must be before (no :id needed)
router.get('/tips', getAllTips);

module.exports = router;
