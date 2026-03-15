// Migration: Create segregation_guide_items table
exports.up = function (knex) {
  return knex.schema.createTable('segregation_guide_items', (table) => {
    table.increments('id').primary();
    table.enu('category', ['organic', 'recyclable', 'paper', 'hazardous', 'glass', 'residual']).notNullable();
    table.string('title', 100).notNullable();
    table.string('subtitle', 255).notNullable();
    table.string('image_url', 500).nullable();
    table.text('details').nullable();  // bullet-point list
    table.timestamps(true, true);
  });
};

exports.down = function (knex) {
  return knex.schema.dropTableIfExists('segregation_guide_items');
};
