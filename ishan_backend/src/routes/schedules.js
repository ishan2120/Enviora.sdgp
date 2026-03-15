const express = require('express');
const router = express.Router();
const db = require('../config/database');
const { verifyToken } = require('../middleware/auth');

// GET /schedules — Get upcoming schedules for user's zone
router.get('/', verifyToken, async (req, res) => {
  try {
    const user = await db('users').where({ id: req.user.id }).select('zone_id').first();
    if (!user || !user.zone_id) return res.status(404).json({ error: 'User has no zone assigned.' });

    const { view } = req.query; // 'weekly' or 'monthly'
    const today = new Date();
    let endDate = new Date(today);

    if (view === 'monthly') {
      endDate.setDate(today.getDate() + 30);
    } else {
      endDate.setDate(today.getDate() + 7);
    }

    const fmt = (d) => d.toISOString().split('T')[0];
    const schedules = await db('collection_schedules')
      .where({ zone_id: user.zone_id })
      .whereBetween('scheduled_date', [fmt(today), fmt(endDate)])
      .orderBy('scheduled_date', 'asc');

    res.json({ schedules });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /schedules/wards — Get all municipal wards
router.get('/wards', verifyToken, async (req, res) => {
  try {
    const wards = await db('wards').select('*');
    res.json({ wards });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

// GET /schedules/next — Get the very next upcoming pickup from municipal data
router.get('/next', verifyToken, async (req, res) => {
  try {
    const user = await db('users').where({ id: req.user.id }).select('ward_id').first();
    if (!user || !user.ward_id) {
      return res.status(404).json({ error: 'User has no ward assigned. Please update your profile.' });
    }

    const dayNames = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    const now = new Date();
    const todayName = dayNames[now.getDay()];
    const currentTime = now.toTimeString().split(' ')[0];

    // Find schedules for this ward
    // We'll look for today first, then future days if needed
    let schedule = await findScheduleForDay(user.ward_id, todayName, currentTime);
    
    if (!schedule) {
      // Look ahead up to 7 days
      for (let i = 1; i <= 7; i++) {
        const nextDay = dayNames[(now.getDay() + i) % 7];
        schedule = await findScheduleForDay(user.ward_id, nextDay, '00:00:00');
        if (schedule) break;
      }
    }

    if (!schedule) return res.json({ schedule: null, message: 'No upcoming collections found for your ward.' });

    // Automatically create a notification for the next pickup if it doesn't exist
    await checkAndCreateNotification(req.user.id, schedule);

    // Fetch stops for this schedule
    const stops = await db('route_stops')
      .where({ route_schedule_id: schedule.id })
      .orderBy('stop_order', 'asc');

    res.json({ 
      schedule: {
        ...schedule,
        stops
      }
    });
  } catch (err) { res.status(500).json({ error: err.message }); }
});

async function findScheduleForDay(wardId, dayName, afterTime) {
  // Complex join to find matching schedules
  // Matches exact day name, or 'Daily', or patterns containing the day
  return await db('route_schedules as rs')
    .join('wards as w', 'w.id', 'rs.ward_id')
    .join('collection_types as ct', 'ct.id', 'rs.collection_type_id')
    .join('trucks as t', 't.id', 'rs.truck_id')
    .join('schedule_days as sd', 'sd.id', 'rs.day_id')
    .where('rs.ward_id', wardId)
    .where(function() {
      this.where('sd.day_pattern', dayName)
          .orWhere('sd.day_pattern', 'Daily')
          .orWhere('sd.day_pattern', 'like', `%${dayName}%`);
    })
    .where('rs.time_starting', '>', afterTime)
    .select(
      'rs.id',
      'w.ward_name',
      'ct.type as collection_type',
      't.truck_label',
      'sd.day_pattern',
      'rs.time_starting',
      'rs.time_ending',
      'rs.load_number'
    )
    .orderBy('rs.time_starting', 'asc')
    .first();
}

async function checkAndCreateNotification(userId, schedule) {
  const title = 'Upcoming Waste Collection';
  const message = `A ${schedule.collection_type} pickup is scheduled for your ward today/soon by ${schedule.truck_label} at ${schedule.time_starting}.`;
  
  // Check if a similar notification was sent in the last 24 hours to avoid spam
  const existing = await db('notifications')
    .where({ user_id: userId, title })
    .where('created_at', '>', new Date(Date.now() - 24 * 60 * 60 * 1000))
    .first();

  if (!existing) {
    await db('notifications').insert({
      user_id: userId,
      title,
      message,
      type: 'schedule',
      is_read: false
    });
  }
}

module.exports = router;
