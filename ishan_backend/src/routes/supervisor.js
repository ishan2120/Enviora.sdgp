const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken, requireRole } = require('../middleware/auth');

const isSupervisor = [verifyToken, requireRole('supervisor')];

// GET /supervisor/reports — all reports in supervisor's zone
router.get('/reports', ...isSupervisor, async (req, res) => {
  try {
    const supervisor = await db('users').where({ id: req.user.id }).select('zone_id').first();
    const { status } = req.query;

    // Get all users in the same zone
    let query = db('reports')
      .join('users', 'reports.user_id', 'users.id')
      .where('users.zone_id', supervisor.zone_id)
      .select('reports.*', 'users.name as citizen_name', 'users.email as citizen_email')
      .orderBy('reports.reported_at', 'desc');

    if (status) query = query.where('reports.status', status);
    const reports = await query;
    res.json({ reports });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /supervisor/reports/:id/status — update report status
router.put('/reports/:id/status', ...isSupervisor, async (req, res) => {
  try {
    const { status } = req.body;
    const allowed = ['pending', 'in_progress', 'resolved'];
    if (!allowed.includes(status)) return res.status(400).json({ error: `Status must be one of: ${allowed.join(', ')}` });

    await db('reports').where({ id: req.params.id }).update({ status, updated_at: new Date() });

    // Update corresponding activity history
    await db('activity_history')
      .where({ user_id: db('reports').where({ id: req.params.id }).select('user_id') })
      .where('title', 'like', `%${req.params.id}%`)
      .update({ status: status === 'in_progress' ? 'in_progress' : status });

    // Notify the citizen
    const report = await db('reports').where({ id: req.params.id }).first();
    if (report) {
      await db('notifications').insert({
        user_id: report.user_id,
        title: `Report ${req.params.id} Updated`,
        message: `Your report status has been changed to: ${status.replace('_', ' ').toUpperCase()}`,
        type: 'report_update',
      });
    }
    const updated = await db('reports').where({ id: req.params.id }).first();
    res.json({ report: updated });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// POST /supervisor/reports/:id/updates — post a supervisor update message
router.post('/reports/:id/updates', ...isSupervisor, async (req, res) => {
  try {
    const { message } = req.body;
    if (!message) return res.status(400).json({ error: 'Message is required.' });

    const report = await db('reports').where({ id: req.params.id }).first();
    if (!report) return res.status(404).json({ error: 'Report not found.' });

    const [id] = await db('supervisor_updates').insert({ report_id: req.params.id, supervisor_id: req.user.id, message });

    // Notify the citizen
    await db('notifications').insert({
      user_id: report.user_id,
      title: `Update on Report ${req.params.id}`,
      message: message.substring(0, 120),
      type: 'report_update',
    });

    const update = await db('supervisor_updates').where({ id }).first();
    res.status(201).json({ supervisor_update: update });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /supervisor/vehicles/:id/location — update live GPS location of a vehicle
router.put('/vehicles/:id/location', ...isSupervisor, async (req, res) => {
  try {
    const { latitude, longitude, status, estimated_minutes, current_location_name } = req.body;
    await db('vehicles').where({ id: req.params.id }).update({
      latitude, longitude, status, estimated_minutes, current_location_name, updated_at: new Date(),
    });
    const vehicle = await db('vehicles').where({ id: req.params.id }).first();

    // Notify users in this zone if truck is nearby
    if (estimated_minutes <= 10) {
      const users = await db('users').where({ zone_id: vehicle.zone_id, notify_when_near: true }).select('id');
      const notifications = users.map((u) => ({
        user_id: u.id,
        title: 'Truck Nearby!',
        message: `Collection truck is approximately ${estimated_minutes} minutes away.`,
        type: 'truck_nearby',
      }));
      if (notifications.length) await db('notifications').insert(notifications);
    }
    res.json({ vehicle });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// PUT /supervisor/schedules/:id/status — mark collection as completed or missed
router.put('/schedules/:id/status', ...isSupervisor, async (req, res) => {
  try {
    const { status } = req.body;
    if (!['collected', 'missed', 'pending'].includes(status)) return res.status(400).json({ error: 'Invalid status.' });

    await db('collection_schedules').where({ id: req.params.id }).update({ status });

    // Notify all users in that zone
    const schedule = await db('collection_schedules').where({ id: req.params.id }).first();
    const users = await db('users').where({ zone_id: schedule.zone_id }).select('id');
    const msg = status === 'collected'
      ? 'Your waste collection has been completed!'
      : 'Unfortunately, today\'s collection was missed. We\'ll reschedule soon.';

    const notifications = users.map((u) => ({
      user_id: u.id,
      title: status === 'collected' ? 'Collection Completed ✓' : 'Collection Missed',
      message: msg,
      type: 'collection_completed',
    }));
    if (notifications.length) await db('notifications').insert(notifications);

    const updated = await db('collection_schedules').where({ id: req.params.id }).first();
    res.json({ schedule: updated });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

module.exports = router;
