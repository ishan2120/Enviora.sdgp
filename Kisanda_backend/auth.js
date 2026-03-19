const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const nodemailer = require('nodemailer');
const { body, validationResult } = require('express-validator');

const db = require('../db');
const { authenticate } = require('../middleware/auth');

const router = express.Router();

// ── Helpers ────────────────────────────────────────────────────────────────────

function generateAccessToken(user) {
  return jwt.sign(
    { id: user.id, email: user.email, role: user.role },
    process.env.JWT_SECRET,
    { expiresIn: process.env.JWT_EXPIRES_IN || '15m' }
  );
}

function generateRefreshToken(user) {
  return jwt.sign(
    { id: user.id },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d' }
  );
}

function safeUser(user) {
  const { password, ...safe } = user;
  return safe;
}

function validationErrors(req, res) {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    res.status(422).json({ success: false, errors: errors.array() });
    return true;
  }
  return false;
}

// ── POST /api/auth/register ────────────────────────────────────────────────────
router.post(
  '/register',
  [
    body('full_name').trim().isLength({ min: 2 }).withMessage('Full name must be at least 2 characters.'),
    body('email').isEmail().normalizeEmail().withMessage('Invalid email address.'),
    body('mobile')
      .optional()
      .matches(/^\+?[\d\s\-]{8,15}$/)
      .withMessage('Invalid mobile number.'),
    body('password')
      .isLength({ min: 8 }).withMessage('Password must be at least 8 characters.')
      .matches(/\d/).withMessage('Password must contain at least one number.'),
    body('role')
      .optional()
      .isIn(['citizen', 'supervisor'])
      .withMessage('Role must be citizen or supervisor.'),
  ],
  async (req, res) => {
    if (validationErrors(req, res)) return;

    const { full_name, email, mobile, password, role = 'citizen' } = req.body;

    try {
      // Check if email already exists
      const existing = db.prepare('SELECT id FROM users WHERE email = ?').get(email);
      if (existing) {
        return res.status(409).json({ success: false, message: 'Email already registered.' });
      }

      const hashed = await bcrypt.hash(password, 12);

      const result = db
        .prepare(
          'INSERT INTO users (full_name, email, mobile, password, role) VALUES (?, ?, ?, ?, ?)'
        )
        .run(full_name, email, mobile || null, hashed, role);

      const newUser = db.prepare('SELECT * FROM users WHERE id = ?').get(result.lastInsertRowid);

      const accessToken  = generateAccessToken(newUser);
      const refreshToken = generateRefreshToken(newUser);

      // Store refresh token
      const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
      db.prepare(
        'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)'
      ).run(newUser.id, refreshToken, expiresAt);

      return res.status(201).json({
        success: true,
        message: 'Account created successfully.',
        data: {
          user: safeUser(newUser),
          access_token: accessToken,
          refresh_token: refreshToken,
        },
      });
    } catch (err) {
      console.error('Register error:', err);
      return res.status(500).json({ success: false, message: 'Server error. Please try again.' });
    }
  }
);

// ── POST /api/auth/login ───────────────────────────────────────────────────────
router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail().withMessage('Invalid email address.'),
    body('password').notEmpty().withMessage('Password is required.'),
    body('role')
      .optional()
      .isIn(['citizen', 'supervisor'])
      .withMessage('Role must be citizen or supervisor.'),
  ],
  async (req, res) => {
    if (validationErrors(req, res)) return;

    const { email, password, role } = req.body;

    try {
      const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);

      if (!user) {
        return res.status(401).json({ success: false, message: 'Invalid email or password.' });
      }

      // Check role matches if provided
      if (role && user.role !== role) {
        return res.status(401).json({
          success: false,
          message: `No ${role} account found with this email.`,
        });
      }

      if (!user.is_active) {
        return res.status(403).json({ success: false, message: 'Account is deactivated.' });
      }

      const passwordMatch = await bcrypt.compare(password, user.password);
      if (!passwordMatch) {
        return res.status(401).json({ success: false, message: 'Invalid email or password.' });
      }

      const accessToken  = generateAccessToken(user);
      const refreshToken = generateRefreshToken(user);

      // Store refresh token (clean up old ones for this user)
      db.prepare('DELETE FROM refresh_tokens WHERE user_id = ?').run(user.id);
      const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
      db.prepare(
        'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)'
      ).run(user.id, refreshToken, expiresAt);

      return res.json({
        success: true,
        message: 'Login successful.',
        data: {
          user: safeUser(user),
          access_token: accessToken,
          refresh_token: refreshToken,
        },
      });
    } catch (err) {
      console.error('Login error:', err);
      return res.status(500).json({ success: false, message: 'Server error. Please try again.' });
    }
  }
);

// ── POST /api/auth/refresh ─────────────────────────────────────────────────────
router.post('/refresh', (req, res) => {
  const { refresh_token } = req.body;
  if (!refresh_token) {
    return res.status(400).json({ success: false, message: 'Refresh token required.' });
  }

  try {
    const payload = jwt.verify(refresh_token, process.env.JWT_REFRESH_SECRET);

    const stored = db
      .prepare('SELECT * FROM refresh_tokens WHERE token = ? AND user_id = ?')
      .get(refresh_token, payload.id);

    if (!stored || new Date(stored.expires_at) < new Date()) {
      return res.status(401).json({ success: false, message: 'Invalid or expired refresh token.' });
    }

    const user = db.prepare('SELECT * FROM users WHERE id = ?').get(payload.id);
    if (!user || !user.is_active) {
      return res.status(401).json({ success: false, message: 'User not found or deactivated.' });
    }

    const newAccessToken  = generateAccessToken(user);
    const newRefreshToken = generateRefreshToken(user);

    // Rotate refresh token
    db.prepare('DELETE FROM refresh_tokens WHERE token = ?').run(refresh_token);
    const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString();
    db.prepare(
      'INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES (?, ?, ?)'
    ).run(user.id, newRefreshToken, expiresAt);

    return res.json({
      success: true,
      data: { access_token: newAccessToken, refresh_token: newRefreshToken },
    });
  } catch (err) {
    return res.status(401).json({ success: false, message: 'Invalid refresh token.' });
  }
});

// ── GET /api/auth/me ───────────────────────────────────────────────────────────
router.get('/me', authenticate, (req, res) => {
  const user = db.prepare('SELECT * FROM users WHERE id = ?').get(req.user.id);
  if (!user) {
    return res.status(404).json({ success: false, message: 'User not found.' });
  }
  return res.json({ success: true, data: { user: safeUser(user) } });
});

// ── POST /api/auth/forgot-password ────────────────────────────────────────────
router.post(
  '/forgot-password',
  [body('email').isEmail().normalizeEmail().withMessage('Invalid email address.')],
  async (req, res) => {
    if (validationErrors(req, res)) return;

    const { email } = req.body;

    // Always return 200 to prevent email enumeration
    const successResponse = () =>
      res.json({
        success: true,
        message: 'If that email is registered, a reset link has been sent.',
      });

    try {
      const user = db.prepare('SELECT * FROM users WHERE email = ?').get(email);
      if (!user) return successResponse();

      // Invalidate old tokens
      db.prepare('DELETE FROM password_reset_tokens WHERE user_id = ?').run(user.id);

      const token     = crypto.randomBytes(32).toString('hex');
      const expiresAt = new Date(Date.now() + 60 * 60 * 1000).toISOString(); // 1 hour

      db.prepare(
        'INSERT INTO password_reset_tokens (user_id, token, expires_at) VALUES (?, ?, ?)'
      ).run(user.id, token, expiresAt);

      // Send email (configure SMTP in .env)
      if (process.env.SMTP_HOST) {
        const transporter = nodemailer.createTransport({
          host:   process.env.SMTP_HOST,
          port:   Number(process.env.SMTP_PORT) || 587,
          secure: process.env.SMTP_SECURE === 'true',
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
          },
        });

        const resetUrl = `${process.env.APP_URL}/reset-password?token=${token}`;

        await transporter.sendMail({
          from:    `"Enviora" <${process.env.SMTP_FROM || process.env.SMTP_USER}>`,
          to:      user.email,
          subject: 'Reset your Enviora password',
          html: `
            <h2>Password Reset</h2>
            <p>Hi ${user.full_name},</p>
            <p>Click the link below to reset your password. This link expires in 1 hour.</p>
            <a href="${resetUrl}" style="background:#48702E;color:#fff;padding:12px 24px;border-radius:8px;text-decoration:none;">Reset Password</a>
            <p>If you didn't request this, please ignore this email.</p>
          `,
        });
      } else {
        // Dev mode — print token to console
        console.log(`\n🔑  Password reset token for ${email}: ${token}\n`);
      }

      return successResponse();
    } catch (err) {
      console.error('Forgot password error:', err);
      return res.status(500).json({ success: false, message: 'Server error. Please try again.' });
    }
  }
);

// ── POST /api/auth/reset-password ─────────────────────────────────────────────
router.post(
  '/reset-password',
  [
    body('token').notEmpty().withMessage('Reset token is required.'),
    body('password')
      .isLength({ min: 8 }).withMessage('Password must be at least 8 characters.')
      .matches(/\d/).withMessage('Password must contain at least one number.'),
  ],
  async (req, res) => {
    if (validationErrors(req, res)) return;

    const { token, password } = req.body;

    try {
      const record = db
        .prepare('SELECT * FROM password_reset_tokens WHERE token = ? AND used = 0')
        .get(token);

      if (!record || new Date(record.expires_at) < new Date()) {
        return res.status(400).json({ success: false, message: 'Invalid or expired reset token.' });
      }

      const hashed = await bcrypt.hash(password, 12);

      db.prepare('UPDATE users SET password = ?, updated_at = datetime(\'now\') WHERE id = ?').run(
        hashed,
        record.user_id
      );

      // Mark token as used
      db.prepare('UPDATE password_reset_tokens SET used = 1 WHERE id = ?').run(record.id);

      return res.json({ success: true, message: 'Password reset successfully. Please log in.' });
    } catch (err) {
      console.error('Reset password error:', err);
      return res.status(500).json({ success: false, message: 'Server error. Please try again.' });
    }
  }
);

// ── POST /api/auth/logout ──────────────────────────────────────────────────────
router.post('/logout', authenticate, (req, res) => {
  const { refresh_token } = req.body;
  if (refresh_token) {
    db.prepare('DELETE FROM refresh_tokens WHERE token = ? AND user_id = ?').run(
      refresh_token,
      req.user.id
    );
  }
  return res.json({ success: true, message: 'Logged out successfully.' });
});

module.exports = router;
