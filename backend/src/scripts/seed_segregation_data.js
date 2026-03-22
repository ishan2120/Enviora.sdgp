/**
 * seed_segregation_data.js
 * Populates waste_categories, waste_items, and recycling_tips tables
 * with comprehensive data for the Segregation Guide feature.
 *
 * Run: node backend/src/scripts/seed_segregation_data.js
 */

const mysql = require('mysql2/promise');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

// ─────────────────────────────────────────────────────────
// CATEGORIES
// ─────────────────────────────────────────────────────────
const CATEGORIES = [
  {
    id: 1,
    name: 'Organic',
    slug: 'organic',
    description: 'Food scraps and garden waste that can be composted',
    image_url: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600',
    color_hex: '#8BC34A',
  },
  {
    id: 2,
    name: 'Recyclable',
    slug: 'recyclable',
    description: 'Metal cans, plastic, glass and paper that can be reprocessed',
    image_url: 'https://images.unsplash.com/photo-1532996122724-e3c354a0b15b?w=600',
    color_hex: '#2196F3',
  },
  {
    id: 3,
    name: 'Paper & Cardboard',
    slug: 'paper',
    description: 'Newspapers, office paper, cardboard packaging',
    image_url: 'https://images.unsplash.com/photo-1595079676339-1534801ad6cf?w=600',
    color_hex: '#FF9800',
  },
  {
    id: 4,
    name: 'Plastic',
    slug: 'plastic',
    description: 'Plastic bottles, containers and packaging materials',
    image_url: 'https://images.unsplash.com/photo-1526951521990-620dc14c214b?w=600',
    color_hex: '#E91E63',
  },
  {
    id: 5,
    name: 'Glass',
    slug: 'glass',
    description: 'Glass bottles, jars and containers',
    image_url: 'https://images.unsplash.com/photo-1618544250420-237362db855c?w=600',
    color_hex: '#00BCD4',
  },
  {
    id: 6,
    name: 'E-Waste',
    slug: 'e-waste',
    description: 'Electronic devices, batteries and electrical equipment',
    image_url: 'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=600',
    color_hex: '#607D8B',
  },
];

// ─────────────────────────────────────────────────────────
// WASTE ITEMS
// ─────────────────────────────────────────────────────────
const ITEMS = [
  // ── ORGANIC (category_id = 1) ──────────────────────────
  {
    category_id: 1,
    name: 'Banana Peel',
    image_url: 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
    short_description: 'Fruit peels rich in potassium — great for composting.',
    disposal_instructions: JSON.stringify([
      'Remove any stickers or adhesive labels from the peel.',
      'Place in the organic / green waste bin.',
      'Alternatively, add it to your home compost bin.',
      'Do NOT place in recycling or general waste bins.',
      'Can also be used as a natural fertiliser for potted plants.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=kUzn6DqD5OI',
    tags: JSON.stringify(['organic', 'fruit', 'compost', 'banana']),
  },
  {
    category_id: 1,
    name: 'Vegetable Scraps',
    image_url: 'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=400',
    short_description: 'Onion skins, carrot tops and other vegetable trimmings.',
    disposal_instructions: JSON.stringify([
      'Collect all vegetable peels, tops and stalks.',
      'Do not include cooked or oily vegetables in compost.',
      'Place raw scraps in the organic waste bin or compost pile.',
      'Avoid adding diseased plants to the compost.',
      'Turn your compost regularly to speed up decomposition.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=egyNJ7xPyoQ',
    tags: JSON.stringify(['organic', 'vegetable', 'compost', 'kitchen-waste']),
  },
  {
    category_id: 1,
    name: 'Coffee Grounds',
    image_url: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?w=400',
    short_description: 'Used coffee grounds are a rich nitrogen source for compost.',
    disposal_instructions: JSON.stringify([
      'Let coffee grounds cool completely before disposal.',
      'Add directly to compost — they are nitrogen-rich "greens".',
      'Can be sprinkled around acid-loving plants as a slow fertiliser.',
      'Paper coffee filters can also go in the compost.',
      'Do not mix with non-organic waste.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=yVvWP1EgG1Y',
    tags: JSON.stringify(['organic', 'coffee', 'compost', 'nitrogen']),
  },
  {
    category_id: 1,
    name: 'Eggshells',
    image_url: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400',
    short_description: 'Eggshells add calcium to compost and deter garden pests.',
    disposal_instructions: JSON.stringify([
      'Rinse the eggshells slightly to remove egg residue.',
      'Crush them to speed up decomposition.',
      'Add to your compost or bury directly in garden soil.',
      'Scatter crushed shells around plants to deter slugs and snails.',
      'Do not throw in recycling — shells are not recyclable.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=Ur5_LWZUlaI',
    tags: JSON.stringify(['organic', 'eggshells', 'compost', 'calcium']),
  },
  {
    category_id: 1,
    name: 'Garden Leaves',
    image_url: 'https://images.unsplash.com/photo-1508193638397-1c4234db14d8?w=400',
    short_description: 'Fallen leaves and garden trimmings for brown compost material.',
    disposal_instructions: JSON.stringify([
      'Rake dry leaves into a pile or compost bin.',
      'Shred leaves if possible to speed up breakdown.',
      'Use as a "brown" carbon material layered with kitchen scraps.',
      'Avoid adding thick layers that compact and block air.',
      'Leaf mould from decomposed leaves makes an excellent mulch.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=TFzFPXiuqBs',
    tags: JSON.stringify(['organic', 'garden', 'leaves', 'compost', 'brown-material']),
  },

  // ── RECYCLABLE (category_id = 2) ─────────────────────
  {
    category_id: 2,
    name: 'Aluminium Can',
    image_url: 'https://images.unsplash.com/photo-1601924638867-3a6de6b7a500?w=400',
    short_description: 'Beverage cans — infinitely recyclable without quality loss.',
    disposal_instructions: JSON.stringify([
      'Rinse the can with water to remove any drink residue.',
      'Crush the can to save space in the recycle bin.',
      'Place in the designated metal / recyclable bin.',
      'Do not put plastic lids inside the can before recycling.',
      'Aluminium can be recycled indefinitely — always recycle it!',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=wqI6NXSI5to',
    tags: JSON.stringify(['recyclable', 'metal', 'aluminium', 'can', 'beverage']),
  },
  {
    category_id: 2,
    name: 'Steel Tin Can',
    image_url: 'https://images.unsplash.com/photo-1585386959984-a4155224a1ad?w=400',
    short_description: 'Food-grade steel cans from tinned goods.',
    disposal_instructions: JSON.stringify([
      'Remove the lid and food residue — rinse thoroughly.',
      'The lid can also be recycled; place it inside the can.',
      'Do not crush steel cans as sorting machines need to identify them.',
      'Place in the metal / recyclable bin.',
      'Remove any paper labels if your local facility requires it.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=wqI6NXSI5to',
    tags: JSON.stringify(['recyclable', 'metal', 'steel', 'tin', 'food-can']),
  },
  {
    category_id: 2,
    name: 'Milk Carton',
    image_url: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400',
    short_description: 'Tetra Pak and carton packaging from milk and juices.',
    disposal_instructions: JSON.stringify([
      'Rinse out all milk or juice from the carton.',
      'Flatten the carton to save space.',
      'Check for the recycling symbol — most cartons are recyclable.',
      'Place in the paper/cardboard or mixed recycling bin.',
      'Remove the plastic cap and recycle it separately if possible.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=I2RNepC1fNE',
    tags: JSON.stringify(['recyclable', 'carton', 'milk', 'tetra-pak', 'beverage']),
  },

  // ── PAPER & CARDBOARD (category_id = 3) ─────────────
  {
    category_id: 3,
    name: 'Cardboard Box',
    image_url: 'https://images.unsplash.com/photo-1606787503321-455e01b76f13?w=400',
    short_description: 'Corrugated cardboard boxes from packaging and deliveries.',
    disposal_instructions: JSON.stringify([
      'Remove all tape, staples and plastic inserts.',
      'Flatten the box completely to maximise bin space.',
      'If the cardboard is wet or greasy (e.g. pizza box), place in organic waste.',
      'Keep dry cardboard separate from wet waste.',
      'Tie large bundles together before putting out for collection.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=O_X5qDZlCEM',
    tags: JSON.stringify(['paper', 'cardboard', 'packaging', 'box']),
  },
  {
    category_id: 3,
    name: 'Newspaper',
    image_url: 'https://images.unsplash.com/photo-1504711434969-e33886168f5c?w=400',
    short_description: 'Old newspapers and magazines ready for recycling.',
    disposal_instructions: JSON.stringify([
      'Bundle newspapers together with string or a rubber band.',
      'Keep them dry — wet paper degrades quickly and loses value.',
      'Remove any plastic wrappers before recycling.',
      'Do not shred newspaper before recycling it.',
      'Place in the paper recycling bin or dedicated paper collection.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=O_X5qDZlCEM',
    tags: JSON.stringify(['paper', 'newspaper', 'magazine', 'print']),
  },
  {
    category_id: 3,
    name: 'Office Paper',
    image_url: 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=400',
    short_description: 'Printed or blank A4 paper and envelopes.',
    disposal_instructions: JSON.stringify([
      'Remove all staples and paperclips before recycling.',
      'Shred sensitive documents before placing in the paper bin.',
      'Envelopes with plastic windows — remove the window if possible.',
      'Do not recycle carbon paper, wax-coated paper or laminated sheets.',
      'Collect paper in a separate bag or box and drop at a paper bin.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=O_X5qDZlCEM',
    tags: JSON.stringify(['paper', 'office', 'A4', 'document', 'envelope']),
  },

  // ── PLASTIC (category_id = 4) ────────────────────────
  {
    category_id: 4,
    name: 'PET Plastic Bottle',
    image_url: 'https://images.unsplash.com/photo-1583623025817-d180a2221d0a?w=400',
    short_description: 'Plastic #1 (PET) water and soft drink bottles.',
    disposal_instructions: JSON.stringify([
      'Rinse the bottle thoroughly to remove liquid or residue.',
      'Remove the cap — caps may be a different plastic type.',
      'Crush the bottle to reduce volume in the bin.',
      'Check the recycling symbol #1 (PET) on the bottom.',
      'Place in the plastic recycling bin or collection point.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=D0SL85PxnAM',
    tags: JSON.stringify(['plastic', 'PET', 'bottle', 'recyclable', 'beverage']),
  },
  {
    category_id: 4,
    name: 'Plastic Shopping Bag',
    image_url: 'https://images.unsplash.com/photo-1584267385494-9fdd9a71ad75?w=400',
    short_description: 'Single-use plastic carrier bags — requires special drop-off.',
    disposal_instructions: JSON.stringify([
      'Do NOT put plastic bags in the kerbside recycling bin — they jam machinery.',
      'Return clean, dry bags to supermarket soft-plastic drop-off points.',
      'Reuse bags as many times as possible before disposal.',
      'Collect multiple bags in one bag for the drop-off point.',
      'Consider switching to reusable cloth bags to reduce waste.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=D0SL85PxnAM',
    tags: JSON.stringify(['plastic', 'bag', 'single-use', 'soft-plastic']),
  },
  {
    category_id: 4,
    name: 'Yogurt Container',
    image_url: 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
    short_description: 'Plastic tubs and containers used for dairy products.',
    disposal_instructions: JSON.stringify([
      'Rinse out all food residue with warm water.',
      'Check the recycling number — #2 (HDPE) and #5 (PP) are widely accepted.',
      'Foil lids can be recycled separately if clean.',
      'Remove any spoons or non-plastic inserts.',
      'Place clean containers in the plastic recycling bin.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=D0SL85PxnAM',
    tags: JSON.stringify(['plastic', 'container', 'yogurt', 'dairy', 'tub']),
  },
  {
    category_id: 4,
    name: 'Bubble Wrap',
    image_url: 'https://images.unsplash.com/photo-1607082348824-0a96f2a4b9da?w=400',
    short_description: 'Soft plastic packing material — needs special drop-off.',
    disposal_instructions: JSON.stringify([
      'Do NOT place bubble wrap in kerbside recycling — it clogs machines.',
      'Deflate by popping or rolling to reduce volume.',
      'Reuse for future packing or give away via community groups.',
      'Clean, dry bubble wrap can go to soft-plastic collection points.',
      'Check your local supermarket for soft-plastic drop-off facilities.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=D0SL85PxnAM',
    tags: JSON.stringify(['plastic', 'bubble-wrap', 'soft-plastic', 'packaging']),
  },

  // ── GLASS (category_id = 5) ──────────────────────────
  {
    category_id: 5,
    name: 'Wine Bottle',
    image_url: 'https://images.unsplash.com/photo-1510812431401-41d2bd2722f3?w=400',
    short_description: 'Glass wine and spirit bottles — 100% recyclable.',
    disposal_instructions: JSON.stringify([
      'Rinse out any remaining liquid from the bottle.',
      'Remove corks (they are a separate material) — compost cork.',
      'Remove metal or plastic caps and recycle them separately.',
      'Do not wrap in paper or put in plastic bags.',
      'Place in the glass recycling bin. Do NOT break the glass.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=pBE7qjuM5c0',
    tags: JSON.stringify(['glass', 'bottle', 'wine', 'spirit', 'beverage']),
  },
  {
    category_id: 5,
    name: 'Glass Jar',
    image_url: 'https://images.unsplash.com/photo-1547556397-da5b2c0a8ec3?w=400',
    short_description: 'Food jars from jam, sauces, pickles and spreads.',
    disposal_instructions: JSON.stringify([
      'Wash the jar with warm soapy water to remove food residue.',
      'Remove the metal lid and recycle it in the metals bin.',
      'Lids do not need to be attached — sort them separately.',
      'Place the clean jar in the glass recycling bin.',
      'Never break glass in the bin — it creates safety hazards.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=pBE7qjuM5c0',
    tags: JSON.stringify(['glass', 'jar', 'food', 'condiment', 'container']),
  },
  {
    category_id: 5,
    name: 'Broken Glass',
    image_url: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
    short_description: 'Crockery, mirrors and broken window glass — NOT recyclable.',
    disposal_instructions: JSON.stringify([
      'Wrap broken pieces carefully in thick newspaper to prevent injury.',
      'Tape the wrapped bundle securely.',
      'Label it "BROKEN GLASS — DANGER" before disposing.',
      'Place in the general waste bin — NOT the glass recycling bin.',
      'Crockery, Pyrex and mirrors are not accepted in glass recycling.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=pBE7qjuM5c0',
    tags: JSON.stringify(['glass', 'broken', 'hazardous', 'mirror', 'crockery']),
  },

  // ── E-WASTE (category_id = 6) ────────────────────────
  {
    category_id: 6,
    name: 'Mobile Phone',
    image_url: 'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400',
    short_description: 'Old and broken smartphones containing precious metals.',
    disposal_instructions: JSON.stringify([
      'Back up your data and perform a factory reset to erase personal info.',
      'Remove the SIM card and memory card.',
      'Remove the battery if possible and recycle it separately.',
      'Take to an authorised e-waste collection centre or retailer take-back scheme.',
      'Never throw phones in general or recycling bins — toxic materials inside.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=RIuYOf4pTwE',
    tags: JSON.stringify(['e-waste', 'phone', 'smartphone', 'electronics', 'battery']),
  },
  {
    category_id: 6,
    name: 'Laptop & Computer',
    image_url: 'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=400',
    short_description: 'Old laptops and desktop computers with hazardous components.',
    disposal_instructions: JSON.stringify([
      'Back up all data then wipe the hard drive or destroy it securely.',
      'Remove the battery — lithium batteries must be recycled separately.',
      'Check if the manufacturer offers a free take-back programme.',
      'Donate working laptops to schools, charities or community centres.',
      'Drop at a certified e-waste recycling facility — never landfill a laptop.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=RIuYOf4pTwE',
    tags: JSON.stringify(['e-waste', 'laptop', 'computer', 'electronics', 'hard-drive']),
  },
  {
    category_id: 6,
    name: 'AA / AAA Batteries',
    image_url: 'https://images.unsplash.com/photo-1582719471384-894fbb16e074?w=400',
    short_description: 'Single-use household batteries containing heavy metals.',
    disposal_instructions: JSON.stringify([
      'Do NOT put batteries in general waste or recycling bins.',
      'Collect used batteries in a container at home.',
      'Take to a battery drop-off box at supermarkets, DIY stores or libraries.',
      'Tape the terminals of lithium batteries with electrical tape before disposal.',
      'Consider switching to rechargeable batteries to reduce waste.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=RIuYOf4pTwE',
    tags: JSON.stringify(['e-waste', 'battery', 'AA', 'AAA', 'heavy-metal', 'toxic']),
  },
  {
    category_id: 6,
    name: 'Light Bulb (LED / CFL)',
    image_url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    short_description: 'Energy-saving bulbs contain mercury and must be recycled.',
    disposal_instructions: JSON.stringify([
      'Do NOT throw CFL bulbs in regular bins — they contain mercury.',
      'Handle broken CFLs carefully: ventilate the room and clean fragments into a bag.',
      'Take bulbs to a designated light-bulb recycling point or hardware store.',
      'LED bulbs are safer but should still be recycled at an e-waste facility.',
      'Keep bulbs in their original packaging for transport to prevent breakage.',
    ]),
    youtube_video_url: 'https://www.youtube.com/watch?v=RIuYOf4pTwE',
    tags: JSON.stringify(['e-waste', 'light-bulb', 'CFL', 'LED', 'mercury', 'toxic']),
  },
];

// ─────────────────────────────────────────────────────────
// RECYCLING TIPS (for "Did You Know?" section)
// ─────────────────────────────────────────────────────────
const TIPS = [
  {
    tip: 'Rinsing plastic containers before recycling dramatically improves the quality of the recycled material and prevents contamination of entire batches.',
    source: 'RecycleNow',
  },
  {
    tip: 'Aluminium cans can be recycled and back on a supermarket shelf in as little as 60 days — recycling aluminium uses 95% less energy than making it from scratch.',
    source: 'Aluminium Association',
  },
  {
    tip: 'One tonne of recycled paper saves 17 trees, 7,000 gallons of water and 380 gallons of oil, as well as 3.3 cubic yards of landfill space.',
    source: 'EPA',
  },
  {
    tip: 'Glass can be recycled endlessly without any loss in quality or purity. A glass bottle recycled today could be a new bottle within 30 days.',
    source: 'Glass Packaging Institute',
  },
  {
    tip: 'The average household throws away about £700 worth of food every year. Composting food waste returns nutrients to the soil instead of releasing methane in landfill.',
    source: 'WRAP',
  },
  {
    tip: 'Plastic bags should NEVER go in your kerbside recycling bin — they jam the sorting machinery. Return them to soft-plastic drop-off points at supermarkets.',
    source: 'Planet Ark',
  },
  {
    tip: 'E-waste is the fastest growing waste stream in the world. Recycling one million mobile phones recovers around 35,000 lbs of copper, 772 lbs of silver, and 75 lbs of gold.',
    source: 'EPA',
  },
  {
    tip: 'Composting at home can divert up to 30% of household waste from landfill. Compost enriches soil, reducing the need for chemical fertilisers.',
    source: 'EPA',
  },
  {
    tip: 'Coffee grounds are rich in nitrogen and make an excellent addition to compost. You can also use them directly in the garden as a slow-release fertiliser.',
    source: 'RHS',
  },
  {
    tip: 'Cardboard contaminated with grease (like pizza boxes) cannot be recycled — the oil ruins the paper fibres. Tear off and recycle clean parts only.',
    source: 'RecycleNow',
  },
  {
    tip: 'Recycling one glass bottle saves enough energy to power a computer for 25 minutes, a television for 20 minutes or a washing machine for 10 minutes.',
    source: 'British Glass',
  },
  {
    tip: 'CFL and fluorescent bulbs contain mercury vapour and must never go in regular bins. Take them to a hardware store or municipal hazardous waste facility.',
    source: 'Energy Star',
  },
  {
    tip: 'Leaving lids on plastic bottles actually helps — the lid keeps the bottle shape so it is easier for recycling machines to sort. Many facilities can now separate them.',
    source: 'RECOUP',
  },
  {
    tip: 'Eggshells are fully compostable. Crushed eggshells also deter slugs and snails in the garden and add calcium to the soil.',
    source: 'Garden Organic',
  },
  {
    tip: 'Banana peels decompose in about 2 years in landfill while releasing methane — a greenhouse gas 25× more potent than CO₂. Composting them avoids this.',
    source: 'WRAP',
  },
];

// ─────────────────────────────────────────────────────────
// MAIN
// ─────────────────────────────────────────────────────────
async function seedSegregationData() {
  let connection;
  try {
    console.log('🌱 Connecting to database...');
    connection = await mysql.createConnection({
      host: process.env.DB_HOST || 'localhost',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
      database: process.env.DB_NAME || 'enviora_db',
    });

    // ── Ensure tables exist ─────────────────────────────
    console.log('📋 Ensuring tables exist...');
    await connection.query(`
      CREATE TABLE IF NOT EXISTS waste_categories (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        slug VARCHAR(255) NOT NULL UNIQUE,
        description TEXT,
        image_url TEXT,
        color_hex VARCHAR(10) DEFAULT '#4CAF50',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS waste_items (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        category_id INT UNSIGNED NOT NULL,
        name VARCHAR(255) NOT NULL,
        image_url TEXT,
        short_description TEXT,
        disposal_instructions JSON,
        youtube_video_url TEXT,
        tags JSON,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (category_id) REFERENCES waste_categories(id) ON DELETE CASCADE
      )
    `);

    await connection.query(`
      CREATE TABLE IF NOT EXISTS recycling_tips (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        tip TEXT NOT NULL,
        source VARCHAR(255),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    // ── Clear old data ──────────────────────────────────
    console.log('🗑️  Clearing old segregation data...');
    await connection.query('SET FOREIGN_KEY_CHECKS = 0');
    await connection.query('TRUNCATE TABLE waste_items');
    await connection.query('TRUNCATE TABLE waste_categories');
    await connection.query('TRUNCATE TABLE recycling_tips');
    await connection.query('SET FOREIGN_KEY_CHECKS = 1');

    // ── Seed categories ─────────────────────────────────
    console.log('📦 Seeding categories...');
    for (const cat of CATEGORIES) {
      await connection.query(
        `INSERT INTO waste_categories (id, name, slug, description, image_url, color_hex)
         VALUES (?, ?, ?, ?, ?, ?)`,
        [cat.id, cat.name, cat.slug, cat.description, cat.image_url, cat.color_hex]
      );
    }
    console.log(`   ✅ ${CATEGORIES.length} categories inserted.`);

    // ── Seed items ──────────────────────────────────────
    console.log('🗂️  Seeding waste items...');
    for (const item of ITEMS) {
      await connection.query(
        `INSERT INTO waste_items
           (category_id, name, image_url, short_description, disposal_instructions, youtube_video_url, tags)
         VALUES (?, ?, ?, ?, ?, ?, ?)`,
        [
          item.category_id,
          item.name,
          item.image_url,
          item.short_description,
          item.disposal_instructions,
          item.youtube_video_url,
          item.tags,
        ]
      );
    }
    console.log(`   ✅ ${ITEMS.length} waste items inserted.`);

    // ── Seed tips ───────────────────────────────────────
    console.log('💡 Seeding recycling tips...');
    for (const t of TIPS) {
      await connection.query(
        `INSERT INTO recycling_tips (tip, source) VALUES (?, ?)`,
        [t.tip, t.source]
      );
    }
    console.log(`   ✅ ${TIPS.length} recycling tips inserted.`);

    // ── Summary ─────────────────────────────────────────
    const [[{ cats }]] = await connection.query('SELECT COUNT(*) AS cats FROM waste_categories');
    const [[{ items }]] = await connection.query('SELECT COUNT(*) AS items FROM waste_items');
    const [[{ tips }]] = await connection.query('SELECT COUNT(*) AS tips FROM recycling_tips');

    console.log('\n🎉 Seeding complete!');
    console.log(`   waste_categories : ${cats} rows`);
    console.log(`   waste_items      : ${items} rows`);
    console.log(`   recycling_tips   : ${tips} rows`);
  } catch (err) {
    console.error('❌ Seeding failed:', err.message);
    process.exit(1);
  } finally {
    if (connection) await connection.end();
  }
}

seedSegregationData();
