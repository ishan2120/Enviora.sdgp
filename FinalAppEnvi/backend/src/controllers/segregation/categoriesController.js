const db = require('../../config/database');

/**
 * GET /api/v1/categories
 * Returns all waste categories
 */
const getAllCategories = async (req, res) => {
  try {
    const [rows] = await db.query(
      `SELECT 
        id,
        name,
        slug,
        description,
        image_url,
        color_hex,
        (SELECT COUNT(*) FROM waste_items WHERE category_id = waste_categories.id) AS item_count
       FROM waste_categories
       ORDER BY name ASC`
    );

    return res.json({
      success: true,
      data: rows,
    });
  } catch (err) {
    console.error('getAllCategories error:', err);
    // Return the actual error for debugging
    return res.status(500).json({ success: false, message: err.message || 'Internal server error' });
  }
};

/**
 * GET /api/v1/categories/:slug
 * Returns a single category by slug
 */
const getCategoryBySlug = async (req, res) => {
  const { slug } = req.params;
  try {
    const [rows] = await db.query(
      `SELECT 
        id, name, slug, description, image_url, color_hex,
        (SELECT COUNT(*) FROM waste_items WHERE category_id = waste_categories.id) AS item_count
       FROM waste_categories
       WHERE slug = ?`,
      [slug]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Category not found' });
    }

    return res.json({ success: true, data: rows[0] });
  } catch (err) {
    console.error('getCategoryBySlug error:', err);
    // Return the actual error for debugging
    return res.status(500).json({ success: false, message: err.message || 'Internal server error' });
  }
};

module.exports = { getAllCategories, getCategoryBySlug };
