const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const app = express();
const PORT = process.env.PORT || 4007;

app.use(cors());
app.use(bodyParser.json());

// Test route
app.get('/', (req, res) => {
  res.json({ message: '🚀 Enviora API is running!' });
});

// Debug route to verify server reachability
app.get('/api/debug-check', (req, res) => {
  res.json({ 
    message: 'SUCCESS: You are hitting the INTEGRATED server',
    database: process.env.DB_NAME,
    timestamp: new Date().toISOString()
  });
});

// Test database
app.get('/api/test', async (req, res) => {
  try {
    const db = require('./config/database');
    const [users] = await db.query('SELECT id, name, email FROM users LIMIT 1');
    res.json({ success: true, user: users[0] });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Import Routes
const profileRoutes = require('./routes/profileRoutes');
const activityRoutes = require('./routes/activityRoutes');
const notificationRoutes = require('./routes/notificationRoutes');
const reportRoutes = require('./routes/reportRoutes');

// New Feature Routes
const vehicleRoutes = require('./routes/vehicleRoutes');
const trackingNotificationRoutes = require('./routes/trackingNotificationRoutes');
const segregationRoutes = require('./routes/segregationRoutes');
const dropoffRoutes = require('./routes/dropoffRoutes');
const scheduleRoutes = require('./routes/scheduleRoutes');

// Dashboard Feature Routes (Consolidated)
const dashboardAuthRoutes = require('./routes/dashboard/auth');
const dashboardScheduleRoutes = require('./routes/dashboard/schedules');
const dashboardTruckRoutes = require('./routes/dashboard/trucks');
const dashboardIssueRoutes = require('./routes/dashboard/issues');
const dashboardActivityRoutes = require('./routes/dashboard/activities');
const dashboardEcoTipsRoutes = require('./routes/dashboard/ecoTips');
const dashboardNotificationRoutes = require('./routes/dashboard/notifications');
const dashboardAnnouncementRoutes = require('./routes/dashboard/announcementRoutes');

// Mount Routes
app.use('/api/profile', profileRoutes);
app.use('/api/activities', activityRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/reports', reportRoutes);

// Mount New Feature Routes
app.use('/api/vehicles', vehicleRoutes);
app.use('/api/notifications', trackingNotificationRoutes); // For /preference
app.use('/api/segregation', segregationRoutes);
app.use('/api/dropoffs', dropoffRoutes);
app.use('/api/schedules', scheduleRoutes);

// Mount Dashboard Routes
app.use('/api/dashboard/auth', dashboardAuthRoutes);
app.use('/api/dashboard/schedules', dashboardScheduleRoutes);
app.use('/api/dashboard/trucks', dashboardTruckRoutes);
app.use('/api/dashboard/issues', dashboardIssueRoutes);
app.use('/api/dashboard/activities', dashboardActivityRoutes);
app.use('/api/dashboard/eco-tips', dashboardEcoTipsRoutes);
app.use('/api/dashboard/notifications', dashboardNotificationRoutes);
app.use('/api/dashboard/announcements', dashboardAnnouncementRoutes);

// 404 Handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: `Route ${req.originalUrl} not found` });
});

// Global Error Handler
app.use((err, req, res, next) => {
  console.error('Unhandled error:', err);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal server error',
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Server running on port ${PORT}`);
});