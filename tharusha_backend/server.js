const express = require('express');
const cors    = require('cors');
const helmet  = require('helmet');
const morgan  = require('morgan');

const vehicleRoutes       = require('./routes/vehicles');
const notificationRoutes  = require('./routes/notifications');
const complaintRoutes     = require('./routes/complaints');

const app  = express();
const PORT = process.env.PORT || 3000;

app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

app.use('/api/vehicles',      vehicleRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/complaints',    complaintRoutes);

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

app.use((err, req, res, next) => {
  console.error('Server error:', err.message);
  res.status(500).json({ error: 'Something went wrong on the server.' });
});

app.listen(PORT, () => {
  console.log('');
  console.log('🟢  Envioraa backend is running!');
  console.log(`🌐  URL  → http://localhost:${PORT}`);
  console.log(`📡  API  → http://localhost:${PORT}/api/health`);
  console.log('');
});

module.exports = app;