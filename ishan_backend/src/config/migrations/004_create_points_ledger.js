// Migration: Create points_ledger table
exports.up = function (knex) {
  return knex.schema.createTable('points_ledger', (table) => {
    table.increments('id').primary();
    table.integer('user_id').unsigned().notNullable().references('id').inTable('users').onDelete('CASCADE');
    table.integer('points').notNullable();  // positive = earned, negative = redeemed
    table.string('reason', 255).notNullable();
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('points_ledger');
};
