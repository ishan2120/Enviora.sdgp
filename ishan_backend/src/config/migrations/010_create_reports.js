// Migration: Create reports table
exports.up = function (knex) {
  return knex.schema.createTable('reports', (table) => {
    table.string('id', 20).primary();  // e.g. 'EV-7712'
    table.integer('user_id').unsigned().notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.enu('type', ['missed_collection', 'illegal_dumping']).notNullable();
    table.string('issue_type', 100).notNullable();
    table.text('description').notNullable();
    table.string('image_url', 500).nullable();
    table.enu('status', ['pending', 'in_progress', 'resolved']).notNullable().defaultTo('pending');
    table.decimal('location_lat', 10, 7).nullable();
    table.decimal('location_lng', 10, 7).nullable();
    table.timestamp('reported_at').notNullable().defaultTo(knex.fn.now());
    table.timestamp('updated_at').notNullable().defaultTo(knex.fn.now());
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('reports');
};
