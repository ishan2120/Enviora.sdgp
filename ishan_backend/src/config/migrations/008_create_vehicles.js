// Migration: Create vehicles table
exports.up = function (knex) {
  return knex.schema.createTable('vehicles', (table) => {
    table.string('id', 20).primary();  // e.g. '#402'
    table.integer('zone_id').unsigned().nullable().references('id').inTable('zones').onDelete('SET NULL');
    table.decimal('latitude', 10, 7).notNullable().defaultTo(0);
    table.decimal('longitude', 10, 7).notNullable().defaultTo(0);
    table.enu('status', ['en_route', 'arrived', 'delayed']).notNullable().defaultTo('en_route');
    table.integer('estimated_minutes').unsigned().notNullable().defaultTo(0);
    table.string('current_location_name', 255).nullable();
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('vehicles');
};
