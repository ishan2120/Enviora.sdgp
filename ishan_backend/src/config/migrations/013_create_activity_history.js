// Migration: Create activity_history table
exports.up = function (knex) {
  return knex.schema.createTable('activity_history', (table) => {
    table.string('id', 30).primary();  // e.g. 'ENV-2026-001'
    table.integer('user_id').unsigned().notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.enu('type', ['report', 'pickup', 'collection']).notNullable();
    table.string('title', 255).notNullable();
    table.string('subtitle', 255).nullable();
    table.text('description').nullable();
    table.enu('status', ['pending', 'in_progress', 'completed', 'resolved', 'missed']).notNullable().defaultTo('pending');
    table.string('location', 255).nullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('activity_history');
};
