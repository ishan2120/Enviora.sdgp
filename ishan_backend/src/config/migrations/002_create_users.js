// Migration: Create users table
exports.up = function (knex) {
  return knex.schema.createTable('users', (table) => {
    table.increments('id').primary();
    table.string('name', 150).notNullable();
    table.string('email', 255).notNullable().unique();
    table.string('mobile', 20).notNullable();
    table.string('password_hash', 255).notNullable();
    table.enu('role', ['citizen', 'supervisor']).notNullable().defaultTo('citizen');
    table.string('profile_image_url', 500).nullable();
    table.text('address').nullable();
    table.integer('zone_id').unsigned().nullable().references('id').inTable('zones').onDelete('SET NULL');
    table.integer('total_points').unsigned().notNullable().defaultTo(0);
    table.string('preferred_language', 10).notNullable().defaultTo('en');
    table.boolean('notify_when_near').notNullable().defaultTo(true);
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('users');
};
