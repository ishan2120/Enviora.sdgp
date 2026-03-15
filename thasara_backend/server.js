const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');

const wardRoutes = require('./routes/wards');
const scheduleRoutes = require('./routes/schedule');
const collectionTypeRoutes = require('./routes/collectionTypes');
const truckRoutes = require('./routes/trucks');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(helmet());
app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));
app.use(morgan('dev'));
app.use(express.json());

app.use('/api/wards', wardRoutes);
app.use('/api/schedule', scheduleRoutes);
app.use('/api/collection-types', collectionTypeRoutes);
app.use('/api/trucks', truckRoutes);

app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

app.use((req, res) => {
  res.status(404).json({ error: 'Route not found' });
});

app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: err.message || 'Internal Server Error' });
});

app.listen(PORT, () => {
  console.log(`🚀 CleanTech District 05 API running on http://localhost:${PORT}`);
});

module.exports = app;
