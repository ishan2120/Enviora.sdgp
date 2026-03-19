const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');
const upload = require('../middleware/upload');

// GET /users/me
router.get('/me', verifyToken, async (req, res) => {
  try {
    const user = await db('users')
      .where({ 'users.id': req.user.id })
      .leftJoin('zones', 'users.zone_id', 'zones.id')
      .select('users.id','users.name','users.email','users.mobile','users.role',
              'users.profile_image_url','users.address','users.total_points',
              'users.preferred_language','users.notify_when_near',
              'zones.name as zone_name')
      .first();
    if (!user) return res.status(404).json({ error: 'User not found.' });
    res.json({ user });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /users/me
router.put('/me', verifyToken, async (req, res) => {
  try {
    const { name, mobile, email, address, preferred_language } = req.body;
    await db('users').where({ id: req.user.id }).update({ name, mobile, email, address, preferred_language });
    const user = await db('users').where({ id: req.user.id }).select('id','name','email','mobile','role','address','preferred_language','total_points').first();
    res.json({ user });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /users/me/password
router.put('/me/password', verifyToken, async (req, res) => {
  try {
    const { current_password, new_password } = req.body;
    if (!current_password || !new_password) return res.status(400).json({ error: 'Both current and new password required.' });
    const user = await db('users').where({ id: req.user.id }).first();
    const valid = await bcrypt.compare(current_password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Current password is incorrect.' });
    const password_hash = await bcrypt.hash(new_password, 10);
    await db('users').where({ id: req.user.id }).update({ password_hash });
    res.json({ message: 'Password updated successfully.' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /users/me/avatar
router.put('/me/avatar', verifyToken, upload.single('image'), async (req, res) => {
  try {
    if (!req.file) return res.status(400).json({ error: 'No image file provided.' });
    const profile_image_url = `/uploads/${req.file.filename}`;
    await db('users').where({ id: req.user.id }).update({ profile_image_url });
    res.json({ profile_image_url });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /users/me/points
router.get('/me/points', verifyToken, async (req, res) => {
  try {
    const user = await db('users').where({ id: req.user.id }).select('total_points').first();
    const history = await db('points_ledger').where({ user_id: req.user.id }).orderBy('created_at', 'desc');
    res.json({ total_points: user.total_points, history });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /users/me/notification-preferences
router.get('/me/notification-preferences', verifyToken, async (req, res) => {
  try {
    const prefs = await db('notification_preferences').where({ user_id: req.user.id }).first();
    res.json({ preferences: prefs });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /users/me/notification-preferences
router.put('/me/notification-preferences', verifyToken, async (req, res) => {
  try {
    const { pickup_reminders, truck_tracking, special_pickups, system_updates } = req.body;
    await db('notification_preferences').where({ user_id: req.user.id })
      .update({ pickup_reminders, truck_tracking, special_pickups, system_updates });
    const prefs = await db('notification_preferences').where({ user_id: req.user.id }).first();
    res.json({ preferences: prefs });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /users/me/notify-when-near
router.put('/me/notify-when-near', verifyToken, async (req, res) => {
  try {
    const { enabled } = req.body;
    await db('users').where({ id: req.user.id }).update({ notify_when_near: enabled });
    res.json({ message: 'Preference updated.', notify_when_near: enabled });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
