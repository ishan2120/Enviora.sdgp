const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Generate unique report ID like EV-XXXX
const generateReportId = async () => {
  const last = await db('reports').orderBy('reported_at', 'desc').select('id').first();
  if (!last) return 'EV-1000';
  const num = parseInt(last.id.replace('EV-', ''), 10) + 1;
  return `EV-${num}`;
};

// POST /reports — File a complaint
router.post('/', verifyToken, upload.single('image'), async (req, res) => {
  try {
    const { type, issue_type, description, location_lat, location_lng } = req.body;
    if (!type || !issue_type || !description) {
      return res.status(400).json({ error: 'type, issue_type and description are required.' });
    }
    const id = await generateReportId();
    const image_url = req.file ? `/uploads/${req.file.filename}` : null;

    await db('reports').insert({
      id, user_id: req.user.id, type, issue_type, description,
      image_url, location_lat: location_lat || null, location_lng: location_lng || null,
      status: 'pending',
    });

    // Create activity history entry
    await db('activity_history').insert({
      id: `ACT-${Date.now()}`, user_id: req.user.id, type: 'report',
      title: `Report Filed: ${issue_type}`, subtitle: description.substring(0, 80),
      description: description, status: 'pending',
    });

    const report = await db('reports').where({ id }).first();
    res.status(201).json({ report });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /reports — Get all reports for logged-in user
router.get('/', verifyToken, async (req, res) => {
  try {
    const { status, search } = req.query;
    let query = db('reports').where({ user_id: req.user.id }).orderBy('reported_at', 'desc');

    if (status) query = query.where({ status });
    if (search) {
      const s = `%${search}%`;
      query = query.where((q) => q.whereLike('id', s).orWhereLike('issue_type', s).orWhereLike('type', s));
    }
    const reports = await query;
    res.json({ reports });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /reports/:id — Get single report + supervisor updates
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const report = await db('reports').where({ id: req.params.id, user_id: req.user.id }).first();
    if (!report) return res.status(404).json({ error: 'Report not found.' });

    const supervisor_updates = await db('supervisor_updates')
      .where({ report_id: req.params.id })
      .join('users', 'supervisor_updates.supervisor_id', 'users.id')
      .select('supervisor_updates.*', 'users.name as supervisor_name')
      .orderBy('supervisor_updates.created_at', 'desc');

    res.json({ report, supervisor_updates });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// DELETE /reports/:id — Cancel a pending report
router.delete('/:id', verifyToken, async (req, res) => {
  try {
    const report = await db('reports').where({ id: req.params.id, user_id: req.user.id }).first();
    if (!report) return res.status(404).json({ error: 'Report not found.' });
    if (report.status !== 'pending') return res.status(400).json({ error: 'Only pending reports can be cancelled.' });

    await db('reports').where({ id: req.params.id }).del();
    res.json({ message: 'Report cancelled successfully.' });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
