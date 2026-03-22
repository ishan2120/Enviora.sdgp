const jwt = require('jsonwebtoken');
require('dotenv').config();

module.exports = (req, res, next) => {
  // Get token from request header
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'Not logged in.' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Verify the token is real and not expired
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = decoded; // saves user info for the next step
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid .' });
  }
};