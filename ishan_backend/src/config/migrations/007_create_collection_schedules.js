// Migration: Create collection_schedules table
exports.up = function (knex) {
  return knex.schema.createTable('collection_schedules', (table) => {
    table.increments('id').primary();
    table.integer('zone_id').unsigned().notNullable().references('id').inTable('zones').onDelete('CASCADE');
    table.enu('waste_type', ['general', 'recycling', 'organic', 'paper', 'glass', 'hazardous']).notNullable();
    table.date('scheduled_date').notNullable();
    table.time('time_window_start').notNullable();
    table.time('time_window_end').notNullable();
    table.enu('status', ['pending', 'collected', 'missed']).notNullable().defaultTo('pending');
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('collection_schedules');
};
