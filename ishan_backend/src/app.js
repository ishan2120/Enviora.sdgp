require('dotenv').config();
const express = require('express');
const cors = require('cors');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// ── Middleware ───────────────────────────────────────────────────────────────
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Serve uploaded files statically
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// ── Routes ───────────────────────────────────────────────────────────────────
app.use('/auth',          require('./routes/auth'));
app.use('/users',         require('./routes/users'));
app.use('/reports',       require('./routes/reports'));
app.use('/schedules',     require('./routes/schedules'));
app.use('/vehicles',      require('./routes/vehicles'));
app.use('/notifications', require('./routes/notifications'));
app.use('/activity',      require('./routes/activity'));
app.use('/guide',         require('./routes/guide'));
app.use('/tips',          require('./routes/tips'));
app.use('/supervisor',    require('./routes/supervisor'));

// ── Health Check ─────────────────────────────────────────────────────────────
app.get('/', (req, res) => {
  res.json({
    message: '🚀 Enviora API is running!',
    version: '1.0.0',
    routes: [
      'POST   /auth/register',
      'POST   /auth/login',
      'POST   /auth/forgot-password',
      'POST   /auth/verify-otp',
      'POST   /auth/reset-password',
      'GET    /users/me',
      'PUT    /users/me',
      'PUT    /users/me/password',
      'PUT    /users/me/avatar',
      'GET    /users/me/points',
      'GET    /users/me/notification-preferences',
      'PUT    /users/me/notification-preferences',
      'PUT    /users/me/notify-when-near',
      'POST   /reports',
      'GET    /reports',
      'GET    /reports/:id',
      'DELETE /reports/:id',
      'GET    /schedules',
      'GET    /schedules/next',
      'GET    /vehicles/active',
      'GET    /notifications',
      'PUT    /notifications/:id/read',
      'DELETE /notifications',
      'GET    /activity',
      'DELETE /activity/:id',
      'GET    /guide/categories',
      'GET    /tips/daily',
      'GET    /supervisor/reports',
      'PUT    /supervisor/reports/:id/status',
      'POST   /supervisor/reports/:id/updates',
      'PUT    /supervisor/vehicles/:id/location',
      'PUT    /supervisor/schedules/:id/status',
    ],
  });
});

// ── 404 Handler ───────────────────────────────────────────────────────────────
app.use((req, res) => {
  res.status(404).json({ error: `Route not found: ${req.method} ${req.path}` });
});

// ── Global Error Handler ──────────────────────────────────────────────────────
app.use((err, req, res, next) => {
  console.error('❌ Unhandled error:', err);
  res.status(500).json({ error: err.message || 'Internal server error' });
});

// ── Start Server ──────────────────────────────────────────────────────────────
const http = require('http');
const server = http.createServer(app);
const { Server } = require('socket.io');
const io = new Server(server, {
  cors: { origin: "*", methods: ["GET", "POST"] }
});

io.on('connection', (socket) => {
  console.log('🔌 New client connected:', socket.id);
  
  socket.on('join-zone', (zoneId) => {
    socket.join(`zone-${zoneId}`);
    console.log(`📍 Socket ${socket.id} joined zone-${zoneId}`);
  });

  socket.on('disconnect', () => {
    console.log('🔌 Client disconnected:', socket.id);
  });
});

// Simulation: Move vehicles slightly every 5 seconds
const vehicles = [
  { id: 1, latitude: 6.9271, longitude: 79.8612, zoneId: 1 },
];

setInterval(() => {
  vehicles.forEach(v => {
    v.latitude += (Math.random() - 0.5) * 0.001;
    v.longitude += (Math.random() - 0.5) * 0.001;
    io.emit('vehicle-update', { id: v.id, latitude: v.latitude, longitude: v.longitude });
  });
}, 5000);

// App level access to io
app.set('io', io);

server.listen(PORT, () => {
  console.log(`✅ Enviora API with Socket.io running on http://localhost:${PORT}`);
});

module.exports = { app, server, io };
