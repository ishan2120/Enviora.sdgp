// Migration: Create zones table
exports.up = function (knex) {
  return knex.schema.createTable('zones', (table) => {
    table.increments('id').primary();
    table.string('name', 100).notNullable();
    table.text('address_description').nullable();
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('zones');
};
