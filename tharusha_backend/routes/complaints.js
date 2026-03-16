const express = require('express');
const router  = express.Router();
const { complaints, uuidv4 } = require('../data/store');

router.get('/', (req, res) => {
  let list = Object.values(complaints);
  if (req.query.userId) {
    list = list.filter(c => c.userId === req.query.userId);
  }
  list.sort((a, b) => new Date(b.createdAt) - new Date(a.createdAt));
  res.json({ complaints: list, total: list.length });
});

router.get('/:complaintId', (req, res) => {
  const complaint = complaints[req.params.complaintId];
  if (!complaint) {
    return res.status(404).json({ error: 'Complaint not found' });
  }
  res.json({ complaint });
});

router.post('/', (req, res) => {
  const { userId, vehicleId, type, description, date } = req.body;

  if (!userId || !type || !description) {
    return res.status(400).json({
      error: 'userId, type, and description are required.',
    });
  }

  const validTypes = [
    'missed_collection',
    'wrong_location',
    'damaged_items',
    'truck_not_arrived',
    'rude_driver',
    'other',
  ];

  if (!validTypes.includes(type)) {
    return res.status(400).json({
      error: `Invalid type. Must be one of: ${validTypes.join(', ')}`,
    });
  }

  const id = `complaint-${uuidv4().slice(0, 8)}`;
  const complaint = {
    id,
    userId,
    vehicleId:    vehicleId || null,
    type,
    description,
    incidentDate: date || null,
    status:       'open',
    createdAt:    new Date().toISOString(),
    resolvedAt:   null,
  };

  complaints[id] = complaint;

  res.status(201).json({
    success: true,
    message: 'Your complaint has been submitted. Our team will follow up shortly.',
    complaint,
  });
});

router.patch('/:complaintId/status', (req, res) => {
  const complaint = complaints[req.params.complaintId];
  if (!complaint) {
    return res.status(404).json({ error: 'Complaint not found' });
  }

  const { status } = req.body;
  const validStatuses = ['open', 'in_review', 'resolved'];
  if (!validStatuses.includes(status)) {
    return res.status(400).json({
      error: `Status must be one of: ${validStatuses.join(', ')}`,
    });
  }

  complaint.status = status;
  if (status === 'resolved') {
    complaint.resolvedAt = new Date().toISOString();
  }

  res.json({ success: true, complaint });
});

module.exports = router;
