const express = require('express');
const router  = express.Router();
const { notificationPrefs } = require('../data/store');

router.get('/preference', (req, res) => {
  const { userId, vehicleId } = req.query;

  if (!userId || !vehicleId) {
    return res.status(400).json({ error: 'userId and vehicleId are required' });
  }

  const key  = `${userId}:${vehicleId}`;
  const pref = notificationPrefs[key];

  res.json({
    userId,
    vehicleId,
    notifyWhenNear: pref ? pref.notifyWhenNear : true,
    updatedAt: pref ? pref.updatedAt : null,
  });
});

router.post('/preference', (req, res) => {
  const { userId, vehicleId, notifyWhenNear } = req.body;

  if (!userId || !vehicleId || notifyWhenNear === undefined) {
    return res.status(400).json({
      error: 'userId, vehicleId, and notifyWhenNear are required',
    });
  }

  const key = `${userId}:${vehicleId}`;
  notificationPrefs[key] = {
    userId,
    vehicleId,
    notifyWhenNear: Boolean(notifyWhenNear),
    updatedAt: new Date().toISOString(),
  };

  res.json({
    success: true,
    message: notifyWhenNear
      ? "You'll be notified when the truck is near."
      : 'Notifications turned off.',
    preference: notificationPrefs[key],
  });
});

module.exports = router;