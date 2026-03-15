const bcrypt = require('bcryptjs');

exports.seed = async function (knex) {
  // Clear all tables in reverse FK order
  await knex('activity_history').del();
  await knex('notifications').del();
  await knex('supervisor_updates').del();
  await knex('reports').del();
  await knex('vehicle_route_path').del();
  await knex('vehicles').del();
  await knex('collection_schedules').del();
  await knex('segregation_guide_items').del();
  await knex('eco_tips').del();
  await knex('points_ledger').del();
  await knex('notification_preferences').del();
  await knex('users').del();
  await knex('zones').del();

  // --- Zones ---
  const [zone1Id] = await knex('zones').insert({ name: 'Zone 5', address_description: 'Galle Road, Colombo 03' });
  const [zone2Id] = await knex('zones').insert({ name: 'Zone 2', address_description: 'Nugegoda, Colombo' });

  // --- Users ---
  const hash = (pw) => bcrypt.hashSync(pw, 10);
  const [citizenId] = await knex('users').insert({
    name: 'G.G.K.Ranudaya', email: 'ggkranudaya@gmail.com', mobile: '0771234567',
    password_hash: hash('Citizen@123'), role: 'citizen', zone_id: zone1Id, total_points: 1000,
  });
  const [supervisorId] = await knex('users').insert({
    name: 'Supervisor Thasara', email: 'supervisor@enviora.app', mobile: '0779876543',
    password_hash: hash('Super@123'), role: 'supervisor', zone_id: zone1Id,
  });

  // --- Notification Preferences ---
  await knex('notification_preferences').insert([
    { user_id: citizenId, pickup_reminders: true, truck_tracking: true, special_pickups: false, system_updates: true },
    { user_id: supervisorId, pickup_reminders: false, truck_tracking: true, special_pickups: false, system_updates: true },
  ]);

  // --- Points Ledger ---
  await knex('points_ledger').insert([
    { user_id: citizenId, points: 500, reason: 'Report resolved - EV-7891' },
    { user_id: citizenId, points: 500, reason: 'Regular collection participated' },
  ]);

  // --- Eco Tips ---
  await knex('eco_tips').insert([
    { tip_text: 'Always give your recyclable containers a quick rinse before throwing them in the recycling bin.', is_active: true },
    { tip_text: 'Composting food scraps reduces waste and enriches your garden soil naturally.', is_active: true },
    { tip_text: 'Use reusable bags when shopping to reduce plastic waste in landfills.', is_active: true },
  ]);

  // --- Segregation Guide ---
  await knex('segregation_guide_items').insert([
    { category: 'organic', title: 'Organic', subtitle: 'Food scraps and garden waste', details: '• Fruit and vegetable peels\n• Eggshells\n• Coffee grounds\n• Tea bags\n• Garden waste\n• Plant trimmings' },
    { category: 'recyclable', title: 'Recyclable', subtitle: 'Plastic, metal & glass', details: '• Plastic bottles\n• Aluminum cans\n• Metal containers\n• Clean plastic packaging\n• Beverage cartons' },
    { category: 'paper', title: 'Paper', subtitle: 'Cardboard & newspapers', details: '• Newspapers\n• Magazines\n• Cardboard boxes\n• Office paper\n• Paper bags\n• Notebooks' },
    { category: 'hazardous', title: 'Hazardous', subtitle: 'Batteries & electronics', details: '• Batteries\n• Electronics\n• Light bulbs\n• Paint cans\n• Chemicals\n• Pesticides' },
    { category: 'glass', title: 'Glass', subtitle: 'Bottles & jars', details: '• Glass bottles\n• Glass jars\n• Wine bottles\n• Beer bottles\n• Food containers' },
    { category: 'residual', title: 'Residual', subtitle: 'Non-recyclable trash', details: '• Dirty diapers\n• Cigarette butts\n• Used tissues\n• Ceramic items\n• Broken glass\n• Styrofoam' },
  ]);

  // --- Collection Schedules ---
  const today = new Date(); today.setHours(0,0,0,0);
  const tomorrow = new Date(today); tomorrow.setDate(today.getDate() + 1);
  const nextWeek = new Date(today); nextWeek.setDate(today.getDate() + 3);
  const fmt = (d) => d.toISOString().split('T')[0];
  await knex('collection_schedules').insert([
    { zone_id: zone1Id, waste_type: 'general', scheduled_date: fmt(today), time_window_start: '07:00', time_window_end: '11:00', status: 'collected' },
    { zone_id: zone1Id, waste_type: 'general', scheduled_date: fmt(tomorrow), time_window_start: '07:00', time_window_end: '11:00', status: 'pending' },
    { zone_id: zone1Id, waste_type: 'recycling', scheduled_date: fmt(nextWeek), time_window_start: '07:00', time_window_end: '11:00', status: 'pending' },
    { zone_id: zone2Id, waste_type: 'organic', scheduled_date: fmt(tomorrow), time_window_start: '08:00', time_window_end: '12:00', status: 'pending' },
  ]);

  // --- Vehicles ---
  await knex('vehicles').insert({
    id: '#402', zone_id: zone1Id, latitude: 6.9271, longitude: 79.8612,
    status: 'en_route', estimated_minutes: 15, current_location_name: 'Kinross Avenue & Mary\'s Road',
  });
  await knex('vehicle_route_path').insert([
    { vehicle_id: '#402', latitude: 6.9271, longitude: 79.8612, sequence: 1 },
    { vehicle_id: '#402', latitude: 6.9310, longitude: 79.8650, sequence: 2 },
    { vehicle_id: '#402', latitude: 6.9350, longitude: 79.8700, sequence: 3 },
  ]);

  // --- Reports ---
  await knex('reports').insert([
    { id: 'EV-7712', user_id: citizenId, type: 'illegal_dumping', issue_type: 'Illegal Waste Dumping', description: 'Large pile of garbage bags dumped on the street', status: 'pending', reported_at: new Date('2024-10-12') },
    { id: 'EV-7740', user_id: citizenId, type: 'missed_collection', issue_type: 'Overflowing Bin', description: 'Bins are overflowing and not collected', status: 'in_progress', reported_at: new Date('2024-09-28') },
    { id: 'EV-7891', user_id: citizenId, type: 'illegal_dumping', issue_type: 'Illegal Waste Dumping', description: 'Waste dumped near residential area', status: 'resolved', reported_at: new Date('2024-10-12') },
  ]);

  // --- Supervisor Updates ---
  await knex('supervisor_updates').insert({
    report_id: 'EV-7740', supervisor_id: supervisorId,
    message: 'We have dispatched a collection team to #EV-7740. You should see it cleared within the next 48 hours.',
  });

  // --- Notifications ---
  await knex('notifications').insert([
    { user_id: citizenId, title: 'Garbage Collection Tomorrow', message: 'Your waste will be collected at 8:00 AM', type: 'pickup_reminder', is_read: false },
    { user_id: citizenId, title: 'Truck Nearby', message: 'Collection truck is 5 minutes away', type: 'truck_nearby', is_read: false },
    { user_id: citizenId, title: 'Collection Completed', message: 'Waste collected successfully', type: 'collection_completed', is_read: true },
  ]);

  // --- Activity History ---
  await knex('activity_history').insert([
    { id: 'ENV-2026-001', user_id: citizenId, type: 'report', title: 'Illegal Dumping Reported', subtitle: 'Near Galle Road, Colombo 03', description: 'Reported large pile of construction waste', status: 'pending', location: 'Galle Road, Colombo 03' },
    { id: 'ENV-2026-002', user_id: citizenId, type: 'report', title: 'Illegal Dumping Reported', subtitle: 'Nugegoda Junction, Colombo', description: 'Municipal team cleared the waste', status: 'resolved', location: 'Nugegoda, Colombo' },
    { id: 'ENV-2026-003', user_id: citizenId, type: 'pickup', title: 'Special Pickup Request', subtitle: 'Old sofa and wooden furniture', description: 'Scheduled for pickup', status: 'in_progress', location: 'Home Address' },
    { id: 'ENV-2026-004', user_id: citizenId, type: 'pickup', title: 'Special Pickup Request', subtitle: 'Tree trunks and garden waste', description: 'Items successfully collected', status: 'completed', location: 'Home Address' },
    { id: 'ENV-2026-005', user_id: citizenId, type: 'collection', title: 'Garbage Collection', subtitle: 'Weekly collection - Zone 5', description: 'Organic and recyclable waste collected', status: 'completed', location: 'Zone 5' },
  ]);

  console.log('✅ Seed data inserted successfully!');
};
