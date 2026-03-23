const db = require('../../config/database');

const DEFAULT_PAGE_SIZE = parseInt(process.env.DEFAULT_PAGE_SIZE) || 10;
const MAX_PAGE_SIZE = parseInt(process.env.MAX_PAGE_SIZE) || 50;

/**
 * Safely parse and clamp pagination params
 */
function getPagination(query) {
  const page = Math.max(1, parseInt(query.page) || 1);
  const limit = Math.min(MAX_PAGE_SIZE, Math.max(1, parseInt(query.limit) || DEFAULT_PAGE_SIZE));
  const offset = (page - 1) * limit;
  return { page, limit, offset };
}

/**
 * GET /api/v1/items?category_id=&page=&limit=
 * Returns paginated list of waste items, optionally filtered by category
 */
const getItems = async (req, res) => {
  const { category_id } = req.query;
  const { page, limit, offset } = getPagination(req.query);

  try {
    const conditions = [];
    const params = [];

    if (category_id) {
      conditions.push('wi.category_id = ?');
      params.push(parseInt(category_id));
    }

    const whereClause = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';

    const countParams = [...params];
    const [[{ total }]] = await db.query(
      `SELECT COUNT(*) AS total FROM waste_items wi ${whereClause}`,
      countParams
    );

    const dataParams = [...params, limit, offset];
    const [rows] = await db.query(
      `SELECT 
        wi.id,
        wi.name,
        wi.image_url,
        wi.short_description,
        wc.id   AS category_id,
        wc.name AS category_name,
        wc.slug AS category_slug,
        wc.color_hex
       FROM waste_items wi
       JOIN waste_categories wc ON wc.id = wi.category_id
       ${whereClause}
       ORDER BY wi.name ASC
       LIMIT ? OFFSET ?`,
      dataParams
    );

    const totalPages = Math.ceil(total / limit);

    return res.json({
      success: true,
      data: rows,
      pagination: {
        page,
        limit,
        total,
        total_pages: totalPages,
        has_next: page < totalPages,
        has_prev: page > 1,
      },
    });
  } catch (err) {
    console.error('getItems error:', err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

/**
 * GET /api/v1/items/:id
 * Returns full details for a single waste item including disposal instructions and video
 */
const getItemById = async (req, res) => {
  const { id } = req.params;

  if (!id || isNaN(id)) {
    return res.status(400).json({ success: false, message: 'Invalid item ID' });
  }

  try {
    const [rows] = await db.query(
      `SELECT 
        wi.id,
        wi.name,
        wi.image_url,
        wi.short_description,
        wi.disposal_instructions,
        wi.youtube_video_url,
        wi.tags,
        wc.id          AS category_id,
        wc.name        AS category_name,
        wc.slug        AS category_slug,
        wc.description AS category_description,
        wc.color_hex
       FROM waste_items wi
       JOIN waste_categories wc ON wc.id = wi.category_id
       WHERE wi.id = ?`,
      [parseInt(id)]
    );

    if (rows.length === 0) {
      return res.status(404).json({ success: false, message: 'Item not found' });
    }

    const item = rows[0];

    // Parse JSON disposal instructions if stored as string
    if (typeof item.disposal_instructions === 'string') {
      try {
        item.disposal_instructions = JSON.parse(item.disposal_instructions);
      } catch {
        item.disposal_instructions = [item.disposal_instructions];
      }
    }

    // Parse tags into array (handles JSON array, JSON string, or CSV string)
    if (Array.isArray(item.tags)) {
      // Already parsed by MySQL driver (JSON column) — use as-is
    } else if (typeof item.tags === 'string') {
      try {
        item.tags = JSON.parse(item.tags);
      } catch {
        item.tags = item.tags.split(',').map(t => t.trim());
      }
    } else {
      item.tags = [];
    }

    return res.json({ success: true, data: item });
  } catch (err) {
    console.error('getItemById error:', err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

/**
 * GET /api/v1/items/search?q=&page=&limit=
 * Full-text + partial search across item names and tags
 */
const searchItems = async (req, res) => {
  const { q } = req.query;
  const { page, limit, offset } = getPagination(req.query);

  if (!q || q.trim().length === 0) {
    return res.status(400).json({ success: false, message: 'Search query "q" is required' });
  }

  const searchTerm = q.trim();
  const likePattern = `%${searchTerm}%`;

  try {
    // Use LIKE for partial matching (works on all MySQL versions)
    // Prioritize name matches over tag matches via CASE in ORDER BY
    const [[{ total }]] = await db.query(
      `SELECT COUNT(*) AS total
       FROM waste_items
       WHERE name LIKE ? OR tags LIKE ?`,
      [likePattern, likePattern]
    );

    const [rows] = await db.query(
      `SELECT 
        wi.id,
        wi.name,
        wi.image_url,
        wi.short_description,
        wc.id   AS category_id,
        wc.name AS category_name,
        wc.slug AS category_slug,
        wc.color_hex
       FROM waste_items wi
       JOIN waste_categories wc ON wc.id = wi.category_id
       WHERE wi.name LIKE ? OR wi.tags LIKE ?
       ORDER BY
         CASE WHEN wi.name LIKE ? THEN 0 ELSE 1 END ASC,
         wi.name ASC
       LIMIT ? OFFSET ?`,
      [likePattern, likePattern, likePattern, limit, offset]
    );

    const totalPages = Math.ceil(total / limit);

    return res.json({
      success: true,
      query: searchTerm,
      data: rows,
      pagination: {
        page,
        limit,
        total,
        total_pages: totalPages,
        has_next: page < totalPages,
        has_prev: page > 1,
      },
    });
  } catch (err) {
    console.error('searchItems error:', err);
    return res.status(500).json({ success: false, message: 'Internal server error' });
  }
};

module.exports = { getItems, getItemById, searchItems };
