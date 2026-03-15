const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../config/database');

// Simple in-memory OTP store (use Redis in production)
const otpStore = {};

const generateOTP = () => Math.floor(1000 + Math.random() * 9000).toString();
const signToken = (user) =>
  jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '7d' }
  );

// POST /auth/register
router.post('/register', async (req, res) => {
  try {
    const { name, email, mobile, password, role } = req.body;
    if (!name || !email || !mobile || !password) {
      return res.status(400).json({ error: 'All fields are required.' });
    }
    const existing = await db('users').where({ email }).first();
    if (existing) return res.status(409).json({ error: 'Email already registered.' });

    const password_hash = await bcrypt.hash(password, 10);
    const [id] = await db('users').insert({ name, email, mobile, password_hash, role: role || 'citizen' });

    // Create default notification preferences
    await db('notification_preferences').insert({ user_id: id });

    const user = await db('users').where({ id }).select('id','name','email','mobile','role','total_points').first();
    const token = signToken(user);
    res.status(201).json({ user, token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /auth/login
router.post('/login', async (req, res) => {
  try {
    const { email, password, role } = req.body;
    if (!email || !password) return res.status(400).json({ error: 'Email and password required.' });

    const user = await db('users').where({ email }).first();
    if (!user) return res.status(401).json({ error: 'Invalid credentials.' });
    if (role && user.role !== role) return res.status(401).json({ error: `Account is not registered as ${role}.` });

    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) return res.status(401).json({ error: 'Invalid credentials.' });

    const token = signToken(user);
    const { password_hash, ...safeUser } = user;
    res.json({ user: safeUser, token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /auth/forgot-password  (sends OTP — logged to console in dev)
router.post('/forgot-password', async (req, res) => {
  try {
    const { mobile } = req.body;
    if (!mobile) return res.status(400).json({ error: 'Mobile number required.' });
    const user = await db('users').where({ mobile }).first();
    if (!user) return res.status(404).json({ error: 'No account found with this mobile number.' });

    const otp = generateOTP();
    otpStore[mobile] = { otp, userId: user.id, expiresAt: Date.now() + 5 * 60 * 1000 };
    console.log(`📱 OTP for ${mobile}: ${otp}`); // Replace with Twilio/SMS in production
    res.json({ message: 'OTP sent to your mobile number.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /auth/verify-otp
router.post('/verify-otp', async (req, res) => {
  try {
    const { mobile, otp } = req.body;
    const record = otpStore[mobile];
    if (!record) return res.status(400).json({ error: 'OTP not requested or expired.' });
    if (Date.now() > record.expiresAt) { delete otpStore[mobile]; return res.status(400).json({ error: 'OTP expired.' }); }
    if (record.otp !== otp) return res.status(400).json({ error: 'Invalid OTP.' });

    const reset_token = jwt.sign({ userId: record.userId, purpose: 'reset' }, process.env.JWT_SECRET, { expiresIn: '15m' });
    delete otpStore[mobile];
    res.json({ reset_token });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /auth/reset-password
router.post('/reset-password', async (req, res) => {
  try {
    const { reset_token, new_password } = req.body;
    if (!reset_token || !new_password) return res.status(400).json({ error: 'Token and new password required.' });

    let payload;
    try { payload = jwt.verify(reset_token, process.env.JWT_SECRET); } 
    catch { return res.status(400).json({ error: 'Invalid or expired reset token.' }); }
    if (payload.purpose !== 'reset') return res.status(400).json({ error: 'Invalid token purpose.' });

    const password_hash = await bcrypt.hash(new_password, 10);
    await db('users').where({ id: payload.userId }).update({ password_hash });
    res.json({ message: 'Password reset successfully.' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /auth/logout  (client-side only — JWT is stateless)
router.post('/logout', (req, res) => {
  res.json({ message: 'Logged out successfully. Please discard your token on the client.' });
});

module.exports = router;
