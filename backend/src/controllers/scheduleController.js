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
    let connection;
    try {
      connection = await mysql.createConnection(dbConfig);
      
      const { email, userId } = req.query;
      let queryStr = 'SELECT * FROM users WHERE id = ?';
      let param = [userId || 1];
      if (email) {
        queryStr = 'SELECT * FROM users WHERE email = ?';
        param = [email];
      }
      const [users] = await connection.query(queryStr, param);
      if (users.length === 0) return res.status(404).json({ message: 'User not found' });
      const user = users[0];
      const userAddress = user.address || '';

      // 2. Get all schedules for the user's specific road/street
      const [schedules] = await connection.query(`
        SELECT 
          rs.id,
          w.ward_name,
          ct.type as collection_type,
          sd.day_pattern,
          rs.time_starting,
          rs.time_ending,
          (SELECT GROUP_CONCAT(road_name SEPARATOR ', ') FROM route_stops WHERE route_schedule_id = rs.id) as roads
        FROM route_schedules rs
        JOIN wards w ON rs.ward_id = w.id
        JOIN collection_types ct ON rs.collection_type_id = ct.id
        JOIN schedule_days sd ON rs.day_id = sd.id
        WHERE rs.id IN (
          SELECT route_schedule_id FROM route_stops WHERE road_name LIKE ?
        )
        GROUP BY rs.id
      `, [`%${userAddress}%`]);

      // 3. Generate date-matched instances from March 23 to April 23
      const startDate = '2026-03-23';
      const endDate = '2026-04-23';
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
    const { email, userId } = req.query;
    let connection;
    try {
      connection = await mysql.createConnection(dbConfig);
      let queryStr = 'SELECT ward_id, address FROM users WHERE id = ?';
      let param = [userId || 1];
      if (email) {
        queryStr = 'SELECT ward_id, address FROM users WHERE email = ?';
        param = [email];
      }
      const [users] = await connection.query(queryStr, param);
      const wardId = users[0]?.ward_id || 1;
      const address = users[0]?.address || '';

      if (!address) {
        return res.json([]);
      }

      const today = new Date();
      const tomorrow = new Date();
      tomorrow.setDate(today.getDate() + 1);

      const d1 = today.toISOString().split('T')[0];
      const d2 = tomorrow.toISOString().split('T')[0];
      
      const day1Num = today.getDay();
      const day2Num = tomorrow.getDay();

      // Get schedules matching either today or tomorrow AND the user's address
      const [allSchedules] = await connection.query(`
        SELECT 
          ct.type as title,
          rs.time_starting as time,
          sd.day_pattern
        FROM route_schedules rs
        JOIN collection_types ct ON rs.collection_type_id = ct.id
        JOIN schedule_days sd ON rs.day_id = sd.id
        WHERE rs.id IN (
          SELECT route_schedule_id FROM route_stops WHERE road_name LIKE ?
        )
      `, [`%${address}%`]);

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
