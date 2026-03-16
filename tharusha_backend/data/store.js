const { v4: uuidv4 } = require('uuid');

const vehicles = {
  'truck-402': {
    vehicleId:        '#402',
    latitude:         6.8924,
    longitude:        79.8557,
    status:           'en_route',
    estimatedMinutes: 15,
    currentLocation:  "Alfred House Road, Colombo 0",
    routePath: [
       { latitude: 6.8924, longitude: 79.8557 },
      { latitude: 6.8934, longitude: 79.8567 },
      { latitude: 6.8944, longitude: 79.8577 },
    ],
    driver:       'Senath',
    lastUpdated:  new Date().toISOString(),
    mapAvailable: true,
  },
};

const notificationPrefs = {};
const complaints = {};

module.exports = { vehicles, notificationPrefs, complaints, uuidv4 };