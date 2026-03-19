// Migration: Create supervisor_updates table
exports.up = function (knex) {
  return knex.schema.createTable('supervisor_updates', (table) => {
    table.increments('id').primary();
    table.string('report_id', 20).notNullable().references('id').inTable('reports').onDelete('CASCADE');
    table.integer('supervisor_id').unsigned().notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.text('message').notNullable();
    table.timestamp('created_at').notNullable().defaultTo(knex.fn.now());
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('supervisor_updates');
};
