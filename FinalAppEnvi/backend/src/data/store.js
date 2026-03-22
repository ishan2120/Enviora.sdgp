// In-memory data store for features that don't use MySQL yet
const vehicles = {
  'truck-402': {
    vehicleId: 'truck-402',
    latitude: 6.9271,
    longitude: 79.8612,
    status: 'en_route',
    estimatedMinutes: 15,
    currentLocation: 'Colombo 07',
    routePath: [
      { latitude: 6.9271, longitude: 79.8612 },
      { latitude: 6.9371, longitude: 79.8712 },
    ],
    driver: 'Senath',
    lastUpdated: new Date().toISOString(),
    mapAvailable: true,
  }
};

const notificationPrefs = {};

module.exports = {
  vehicles,
  notificationPrefs,
};
