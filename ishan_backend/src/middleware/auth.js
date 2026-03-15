const jwt = require('jsonwebtoken');

/**
 * Verify JWT from Authorization: Bearer <token> header.
 * Attaches decoded user payload to req.user.
 */
const verifyToken = (req, res, next) => {
  const authHeader = req.headers['authorization'];
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Access denied. No token provided.' });
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ error: 'Invalid or expired token.' });
  }
};

/**
 * Role guard factory. Usage: requireRole('supervisor')
 */
const requireRole = (role) => (req, res, next) => {
  if (!req.user) return res.status(401).json({ error: 'Not authenticated.' });
  if (req.user.role !== role) {
    return res.status(403).json({ error: `Access denied. Requires role: ${role}` });
  }
  next();
};

module.exports = { verifyToken, requireRole };
