require('dotenv').config();

const express = require('express');
const cors    = require('cors');

// Initialise database (runs CREATE TABLE IF NOT EXISTS)
require('./db');

const authRouter = require('./routes/auth');

const app  = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ─────────────────────────────────────────────────────────────────

app.use(cors({
  origin: process.env.ALLOWED_ORIGINS
    ? process.env.ALLOWED_ORIGINS.split(',')
    : '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Routes ─────────────────────────────────────────────────────────────────────

app.get('/health', (_req, res) => {
  res.json({ status: 'ok', app: 'Enviora API', timestamp: new Date().toISOString() });
});

app.use('/api/auth', authRouter);

// 404 handler
app.use((_req, res) => {
  res.status(404).json({ success: false, message: 'Route not found.' });
});

// Global error handler
app.use((err, _req, res, _next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({ success: false, message: 'Internal server error.' });
});

// ── Start ──────────────────────────────────────────────────────────────────────

app.listen(PORT, () => {
  console.log(`🚀  Enviora API running on http://localhost:${PORT}`);
});
