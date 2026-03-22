const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const dbConfig = {
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'enviora_db'
};

/**
 * Maps a day pattern (e.g., "Monday", "Tuesday & Friday") to JS Day numbers (0-6)
 */
function getDayNumbers(pattern) {
  const dayMap = {
    'sunday': 0, 'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4, 'friday': 5, 'saturday': 6,
    'mon.': 1, 'tue.': 2, 'wed.': 3, 'thu.': 4, 'fri.': 5, 'sat.': 6, 'sun.': 0,
    'mon': 1, 'tue': 2, 'wed': 3, 'thu': 4, 'fri': 5, 'sat': 6, 'sun': 0
  };

  const p = pattern.toLowerCase();
  if (p === 'daily') return [0, 1, 2, 3, 4, 5, 6];

  const days = [];
  Object.keys(dayMap).forEach(key => {
    if (p.includes(key)) {
      if (!days.includes(dayMap[key])) {
        days.push(dayMap[key]);
      }
    }
  });

  return days;
}

/**
 * Returns all actual dates between start and end that match the day numbers
 */
function getMatchingDates(dayNumbers, start, end) {
  const dates = [];
  let current = new Date(start);
  const finish = new Date(end);

  while (current <= finish) {
    if (dayNumbers.includes(current.getDay())) {
      dates.push(new Date(current).toISOString().split('T')[0]);
    }
    current.setDate(current.getDate() + 1);
  }
  return dates;
}

const scheduleController = {
  // Get schedules for a specific user/ward
  getMySchedule: async (req, res) => {
    const userId = req.query.userId || 1; // Default to demo user
    let connection;
    try {
      connection = await mysql.createConnection(dbConfig);
      
      // 1. Get user's ward and address
      const [users] = await connection.query('SELECT * FROM users WHERE id = ?', [userId]);
      if (users.length === 0) return res.status(404).json({ message: 'User not found' });
      const user = users[0];

      // 2. Get all schedules for the ward
      // Note: In a real app, we might filter by road_name matching user.street
      const [schedules] = await connection.query(`
        SELECT 
          rs.id,
          w.ward_name,
          ct.type as collection_type,
          sd.day_pattern,
          rs.time_starting,
          rs.time_ending,
          GROUP_CONCAT(stop.road_name SEPARATOR ', ') as roads
        FROM route_schedules rs
        JOIN wards w ON rs.ward_id = w.id
        JOIN collection_types ct ON rs.collection_type_id = ct.id
        JOIN schedule_days sd ON rs.day_id = sd.id
        JOIN route_stops stop ON stop.route_schedule_id = rs.id
        WHERE rs.ward_id = ?
        GROUP BY rs.id
      `, [user.ward_id || 1]);

      // 3. Generate date-matched instances from March 21 to April 21
      const startDate = '2026-03-21';
      const endDate = '2026-04-21';
      const fullPlan = [];

      schedules.forEach(sched => {
        const dayNumbers = getDayNumbers(sched.day_pattern);
        const dates = getMatchingDates(dayNumbers, startDate, endDate);
        
        dates.forEach(date => {
          fullPlan.push({
            date,
            time: sched.time_starting,
            type: sched.collection_type,
            ward: sched.ward_name,
            roads: sched.roads
          });
        });
      });

      // Sort by date
      fullPlan.sort((a, b) => a.date.localeCompare(b.date));

      res.json(fullPlan);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error', error: error.message });
    } finally {
      if (connection) await connection.end();
    }
  },

  // Get notifications (Today & Tomorrow)
  getNotifications: async (req, res) => {
    const userId = req.query.userId || 1;
    let connection;
    try {
      connection = await mysql.createConnection(dbConfig);
      const [users] = await connection.query('SELECT ward_id FROM users WHERE id = ?', [userId]);
      const wardId = users[0]?.ward_id || 1;

      const today = new Date();
      const tomorrow = new Date();
      tomorrow.setDate(today.getDate() + 1);

      const d1 = today.toISOString().split('T')[0];
      const d2 = tomorrow.toISOString().split('T')[0];
      
      const day1Num = today.getDay();
      const day2Num = tomorrow.getDay();

      // Get schedules matching either today or tomorrow
      // This is a bit complex in SQL, easier to fetch all and filter in JS 
      // or use a smarter query.
      const [allSchedules] = await connection.query(`
        SELECT 
          ct.type as title,
          rs.time_starting as time,
          sd.day_pattern
        FROM route_schedules rs
        JOIN collection_types ct ON rs.collection_type_id = ct.id
        JOIN schedule_days sd ON rs.day_id = sd.id
        WHERE rs.ward_id = ?
      `, [wardId]);

      const notifications = [];
      allSchedules.forEach(s => {
        const nums = getDayNumbers(s.day_pattern);
        if (nums.includes(day1Num)) {
          notifications.push({
            title: s.title,
            time: s.time,
            day: 'Today',
            date: d1
          });
        }
        if (nums.includes(day2Num)) {
          notifications.push({
            title: s.title,
            time: s.time,
            day: 'Tomorrow',
            date: d2
          });
        }
      });

      res.json(notifications);
    } catch (error) {
      console.error(error);
      res.status(500).json({ message: 'Internal server error' });
    } finally {
      if (connection) await connection.end();
    }
  }
};

module.exports = scheduleController;
