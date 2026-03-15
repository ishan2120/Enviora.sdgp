const express = require('express');
const router = express.Router();
const db = require('../db/connection');

// Day name to matching patterns in schedule_days table
const DAY_PATTERNS = {
  Monday:    ['Monday',    'Daily', 'Mon. & Thu'],
  Tuesday:   ['Tuesday',  'Daily', 'Tuesday & Friday'],
  Wednesday: ['Wednesday','Daily', 'Wed. & Sat.', 'Wed. & Sat. (Col B)'],
  Thursday:  ['Thursday', 'Daily', 'Mon. & Thu'],
  Friday:    ['Friday',   'Daily', 'Tuesday & Friday'],
  Saturday:  ['Saturday', 'Daily', 'Wed. & Sat.', 'Wed. & Sat. (Col B)'],
  Sunday:    ['Sunday',   'Daily'],
};

// GET /api/schedule/weekly?wardId=1&dayName=Monday
router.get('/weekly', async (req, res) => {
  const { wardId, dayName } = req.query;

  if (!wardId || !dayName) {
    return res.status(400).json({
      success: false,
      error: 'wardId and dayName are required. dayName must be: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, or Sunday',
    });
  }

  const patterns = DAY_PATTERNS[dayName];
  if (!patterns) {
    return res.status(400).json({
      success: false,
      error: 'Invalid dayName. Use: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday',
    });
  }

  try {
    const placeholders = patterns.map(() => '?').join(',');

    const [schedules] = await db.query(
      `SELECT 
          rs.id,
          w.ward_name,
          ct.type        AS collection_type,
          t.truck_label  AS truck,
          sd.day_pattern AS day,
          rs.load_number,
          TIME_FORMAT(rs.time_starting, '%h:%i %p') AS time_starting,
          TIME_FORMAT(rs.time_ending,   '%h:%i %p') AS time_ending
       FROM route_schedules rs
       JOIN wards            w   ON w.id  = rs.ward_id
       JOIN collection_types ct  ON ct.id = rs.collection_type_id
       JOIN trucks           t   ON t.id  = rs.truck_id
       JOIN schedule_days    sd  ON sd.id = rs.day_id
       WHERE rs.ward_id = ?
         AND sd.day_pattern IN (${placeholders})
       ORDER BY ct.type, t.truck_label, rs.load_number`,
      [wardId, ...patterns]
    );

    if (schedules.length === 0) {
      return res.json({
        success: true,
        message: `No collections scheduled for this ward on ${dayName}`,
        data: [],
      });
    }

    const scheduleIds = schedules.map(s => s.id);
    const [stops] = await db.query(
      `SELECT route_schedule_id, stop_order, road_name, from_location, up_to_location, remark
       FROM route_stops
       WHERE route_schedule_id IN (?)
       ORDER BY stop_order`,
      [scheduleIds]
    );

    const result = schedules.map(schedule => ({
      ...schedule,
      stops: stops.filter(s => s.route_schedule_id === schedule.id),
    }));

    res.json({ success: true, day: dayName, count: result.length, data: result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/schedule/by-road?roadName=Galle Road
router.get('/by-road', async (req, res) => {
  const { roadName } = req.query;

  if (!roadName) {
    return res.status(400).json({ success: false, error: 'roadName is required' });
  }

  try {
    const [results] = await db.query(
      `SELECT
          w.ward_name,
          ct.type        AS collection_type,
          t.truck_label  AS truck,
          sd.day_pattern AS day,
          TIME_FORMAT(rs.time_starting, '%h:%i %p') AS time_starting,
          TIME_FORMAT(rs.time_ending,   '%h:%i %p') AS time_ending,
          stop.road_name,
          IFNULL(stop.from_location, '—') AS from_location,
          IFNULL(stop.up_to_location,'—') AS up_to_location,
          IFNULL(stop.remark,        '—') AS remark
       FROM route_stops stop
       JOIN route_schedules rs ON rs.id = stop.route_schedule_id
       JOIN wards            w  ON w.id  = rs.ward_id
       JOIN collection_types ct ON ct.id = rs.collection_type_id
       JOIN trucks           t  ON t.id  = rs.truck_id
       JOIN schedule_days    sd ON sd.id = rs.day_id
       WHERE stop.road_name LIKE ?
       ORDER BY w.ward_name, sd.id`,
      [`%${roadName}%`]
    );

    res.json({ success: true, count: results.length, data: results });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/schedule/full?wardId=1
router.get('/full', async (req, res) => {
  const { wardId } = req.query;

  if (!wardId) {
    return res.status(400).json({ success: false, error: 'wardId is required' });
  }

  try {
    const [schedules] = await db.query(
      `SELECT
          rs.id,
          w.ward_name,
          ct.type        AS collection_type,
          t.truck_label  AS truck,
          sd.day_pattern AS day,
          rs.load_number,
          TIME_FORMAT(rs.time_starting, '%h:%i %p') AS time_starting,
          TIME_FORMAT(rs.time_ending,   '%h:%i %p') AS time_ending
       FROM route_schedules rs
       JOIN wards            w   ON w.id  = rs.ward_id
       JOIN collection_types ct  ON ct.id = rs.collection_type_id
       JOIN trucks           t   ON t.id  = rs.truck_id
       JOIN schedule_days    sd  ON sd.id = rs.day_id
       WHERE rs.ward_id = ?
       ORDER BY sd.id, ct.type, t.truck_label, rs.load_number`,
      [wardId]
    );

    const scheduleIds = schedules.map(s => s.id);
    let stops = [];
    if (scheduleIds.length > 0) {
      [stops] = await db.query(
        `SELECT route_schedule_id, stop_order, road_name, from_location, up_to_location, remark
         FROM route_stops WHERE route_schedule_id IN (?) ORDER BY stop_order`,
        [scheduleIds]
      );
    }

    const result = schedules.map(schedule => ({
      ...schedule,
      stops: stops.filter(s => s.route_schedule_id === schedule.id),
    }));

    res.json({ success: true, count: result.length, data: result });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

// GET /api/schedule/:id
router.get('/:id', async (req, res) => {
  try {
    const [schedules] = await db.query(
      `SELECT
          rs.id,
          w.ward_name,
          ct.type        AS collection_type,
          t.truck_label  AS truck,
          sd.day_pattern AS day,
          rs.load_number,
          TIME_FORMAT(rs.time_starting, '%h:%i %p') AS time_starting,
          TIME_FORMAT(rs.time_ending,   '%h:%i %p') AS time_ending
       FROM route_schedules rs
       JOIN wards            w   ON w.id  = rs.ward_id
       JOIN collection_types ct  ON ct.id = rs.collection_type_id
       JOIN trucks           t   ON t.id  = rs.truck_id
       JOIN schedule_days    sd  ON sd.id = rs.day_id
       WHERE rs.id = ?`,
      [req.params.id]
    );

    if (schedules.length === 0) {
      return res.status(404).json({ success: false, error: 'Schedule not found' });
    }

    const [stops] = await db.query(
      `SELECT stop_order, road_name, from_location, up_to_location, remark
       FROM route_stops WHERE route_schedule_id = ? ORDER BY stop_order`,
      [req.params.id]
    );

    res.json({ success: true, data: { ...schedules[0], stops } });
  } catch (err) {
    res.status(500).json({ success: false, error: err.message });
  }
});

module.exports = router;
