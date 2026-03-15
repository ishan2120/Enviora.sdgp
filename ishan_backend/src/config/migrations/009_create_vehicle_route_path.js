// Migration: Create vehicle_route_path table
exports.up = function (knex) {
  return knex.schema.createTable('vehicle_route_path', (table) => {
    table.increments('id').primary();
    table.string('vehicle_id', 20).notNullable().references('id').inTable('vehicles').onDelete('CASCADE');
    table.decimal('latitude', 10, 7).notNullable();
    table.decimal('longitude', 10, 7).notNullable();
    table.integer('sequence').unsigned().notNullable();
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('vehicle_route_path');
};
