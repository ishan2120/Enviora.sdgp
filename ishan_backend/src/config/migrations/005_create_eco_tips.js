// Migration: Create eco_tips table
exports.up = function (knex) {
  return knex.schema.createTable('eco_tips', (table) => {
    table.increments('id').primary();
    table.text('tip_text').notNullable();
    table.boolean('is_active').notNullable().defaultTo(true);
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('eco_tips');
};
