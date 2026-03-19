// Migration: Create notification_preferences table
exports.up = function (knex) {
  return knex.schema.createTable('notification_preferences', (table) => {
    table.integer('user_id').unsigned().primary().references('id').inTable('users').onDelete('CASCADE');
    table.boolean('pickup_reminders').notNullable().defaultTo(true);
    table.boolean('truck_tracking').notNullable().defaultTo(true);
    table.boolean('special_pickups').notNullable().defaultTo(false);
    table.boolean('system_updates').notNullable().defaultTo(true);
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('notification_preferences');
};
