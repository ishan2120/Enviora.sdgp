require('dotenv').config();
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');

const routes = require('./routes/index');

const app = express();
const PORT = process.env.PORT || 3000;
const API_PREFIX = process.env.API_PREFIX || '/api/v1';

// ── Security & Middleware ────────────────────────────────────────
app.use(helmet());
app.use(cors({
  origin: '*', // Restrict to your Flutter app domain in production
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// ── Rate Limiting ────────────────────────────────────────────────
const limiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 min
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  standardHeaders: true,
  legacyHeaders: false,
  message: { success: false, message: 'Too many requests, please try again later.' },
});
app.use(limiter);

// ── Routes ───────────────────────────────────────────────────────
app.use(API_PREFIX, routes);

// Root redirect
app.get('/', (req, res) => {
  res.json({
    app: 'Enviora API',
    version: '1.0.0',
    docs: `${API_PREFIX}/health`,
    endpoints: {
      categories: `${API_PREFIX}/categories`,
      items: `${API_PREFIX}/items`,
      search: `${API_PREFIX}/items/search?q=plastic`,
      itemDetail: `${API_PREFIX}/items/:id`,
      randomTip: `${API_PREFIX}/tips/random`,
      allTips: `${API_PREFIX}/tips`,
    },
  });
});

// ── 404 Handler ──────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// ── Global Error Handler ─────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: process.env.NODE_ENV === 'production' ? 'Internal server error' : err.message,
  });
});

// ── Start ────────────────────────────────────────────────────────
app.listen(PORT, () => {
  console.log(`🌿 Enviora API running on http://localhost:${PORT}`);
  console.log(`📡 API prefix: ${API_PREFIX}`);
  console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
});

module.exports = app;
