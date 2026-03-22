const express  = require('express');
const router   = express.Router();
const { vehicles } = require('../data/store');

function tickEta(vehicle) {
  if (vehicle.status === 'en_route' && vehicle.estimatedMinutes > 0) {
    vehicle.estimatedMinutes = Math.max(0, vehicle.estimatedMinutes - 1);
    vehicle.lastUpdated = new Date().toISOString();
    if (vehicle.estimatedMinutes === 0) {
      vehicle.status = 'arrived';
    }
  }
}

function formatVehicle(v) {
  return {
    vehicleId:        v.vehicleId,
    latitude:         v.latitude,
    longitude:        v.longitude,
    status:           v.status,
    estimatedMinutes: v.estimatedMinutes,
    currentLocation:  v.currentLocation,
    routePath:        v.routePath,
    driver:           v.driver,
    lastUpdated:      v.lastUpdated,
    mapAvailable:     v.mapAvailable,
    mapUnavailableMessage: v.mapAvailable
      ? null
      : 'Live map is currently unavailable. Location updates are still active.',
  };
}

router.get('/', (req, res) => {
  const list = Object.values(vehicles).map(formatVehicle);
  res.json({ vehicles: list });
});

router.get('/:vehicleId', (req, res) => {
  const vehicle = vehicles[req.params.vehicleId];
  if (!vehicle) {
    return res.status(404).json({ error: 'Vehicle not found' });
  }
  tickEta(vehicle);
  res.json({ vehicle: formatVehicle(vehicle) });
});

router.get('/:vehicleId/location', (req, res) => {
  const vehicle = vehicles[req.params.vehicleId];
  if (!vehicle) {
    return res.status(404).json({ error: 'Vehicle not found' });
  }
  tickEta(vehicle);
  res.json({
    vehicleId:        vehicle.vehicleId,
    latitude:         vehicle.latitude,
    longitude:        vehicle.longitude,
    status:           vehicle.status,
    estimatedMinutes: vehicle.estimatedMinutes,
    currentLocation:  vehicle.currentLocation,
    lastUpdated:      vehicle.lastUpdated,
  });
});

router.patch('/:vehicleId/location', (req, res) => {
  const vehicle = vehicles[req.params.vehicleId];
  if (!vehicle) {
    return res.status(404).json({ error: 'Vehicle not found' });
  }

  const { latitude, longitude, currentLocation, estimatedMinutes, status, routePath } = req.body;

  if (latitude          !== undefined) vehicle.latitude          = latitude;
  if (longitude         !== undefined) vehicle.longitude         = longitude;
  if (currentLocation   !== undefined) vehicle.currentLocation   = currentLocation;
  if (estimatedMinutes  !== undefined) vehicle.estimatedMinutes  = estimatedMinutes;
  if (status            !== undefined) vehicle.status            = status;
  if (routePath         !== undefined) vehicle.routePath         = routePath;
  vehicle.lastUpdated = new Date().toISOString();

  res.json({ success: true, vehicle: formatVehicle(vehicle) });
});

module.exports = router;