# 🌿 Enviora Backend API

Node.js + MySQL REST API powering the **Enviora** waste segregation Flutter app.

---

## 📁 Project Structure

```
enviora-backend/
├── src/
│   ├── server.js                    # Express app entry point
│   ├── config/
│   │   └── database.js              # MySQL connection pool
│   ├── controllers/
│   │   ├── categoriesController.js  # Waste category logic
│   │   ├── itemsController.js       # Waste items + search + pagination
│   │   └── tipsController.js        # Did You Know tips
│   └── routes/
│       └── index.js                 # All route definitions
├── database/
│   ├── schema.sql                   # Schema + full seed data
│   └── setup.js                    # One-time DB setup script
├── flutter_client/
│   └── enviora_api_service.dart     # Flutter API service (drop into your project)
├── .env.example                     # Environment variable template
├── package.json
└── README.md
```

---

## 🚀 Quick Start

### 1. Install dependencies

```bash
cd enviora-backend
npm install
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env` with your MySQL credentials:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=3306
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=enviora_db
```

### 3. Set up the database

Make sure MySQL is running, then:

```bash
npm run setup-db
```

This creates the `enviora_db` database, all tables, and seeds:
- ✅ 6 waste categories
- ✅ 37 waste items across all categories
- ✅ 20 "Did You Know?" recycling tips

### 4. Start the server

```bash
# Development (auto-reload)
npm run dev

# Production
npm start
```

Server runs at: **http://localhost:3000**

---

## 📡 API Reference

All endpoints are prefixed with `/api/v1`.

### Health Check

```
GET /api/v1/health
```

---

### Waste Categories

#### Get all categories
```
GET /api/v1/categories
```
**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Organic",
      "slug": "organic",
      "description": "Food scraps and garden waste",
      "image_url": "https://...",
      "color_hex": "#8BC34A",
      "item_count": 8
    }
  ]
}
```

#### Get single category
```
GET /api/v1/categories/:slug
```
Example: `GET /api/v1/categories/organic`

---

### Waste Items

#### Get all items (paginated)
```
GET /api/v1/items?page=1&limit=10
```

#### Get items by category
```
GET /api/v1/items?category_id=1&page=1&limit=10
```

**Query Parameters:**
| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `category_id` | int | — | Filter by category |
| `page` | int | 1 | Page number |
| `limit` | int | 10 | Items per page (max 50) |

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Banana Peel",
      "image_url": "https://...",
      "short_description": "Fruit peel, great for composting",
      "category_id": 1,
      "category_name": "Organic",
      "category_slug": "organic",
      "color_hex": "#8BC34A"
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 8,
    "total_pages": 1,
    "has_next": false,
    "has_prev": false
  }
}
```

#### Search items
```
GET /api/v1/items/search?q=plastic&page=1&limit=10
```

**Query Parameters:**
| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `q` | string | ✅ | Search term (partial match on name + tags) |
| `page` | int | — | Page number |
| `limit` | int | — | Items per page |

Search examples that work:
- `?q=plastic` → finds Plastic Bottle, Plastic Bag
- `?q=battery` → finds AA Battery
- `?q=banana` → finds Banana Peel
- `?q=glass` → finds Glass category items
- `?q=news` → finds Newspaper

#### Get item details
```
GET /api/v1/items/:id
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 9,
    "name": "Plastic Bottle",
    "image_url": "https://...",
    "short_description": "PET plastic water and soda bottles",
    "disposal_instructions": [
      "Remove cap and rinse thoroughly",
      "Check bottom for recycling number (1 or 2)",
      "Crush to save space in recycling bin",
      "Remove any labels if possible",
      "Place in blue recycling bin"
    ],
    "youtube_video_url": "https://www.youtube.com/watch?v=Wjj_l3NWSmE",
    "tags": ["plastic", "bottle", "PET", "recycle", "water"],
    "category_id": 2,
    "category_name": "Recyclable",
    "category_slug": "recyclable",
    "category_description": "Plastic, metal & glass",
    "color_hex": "#2196F3"
  }
}
```

---

### Recycling Tips

#### Get random tip (for "Did You Know?" widget)
```
GET /api/v1/tips/random
```
**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "tip": "Rinsing your plastic containers before recycling increases the quality of the recycled material significantly!",
    "source": "EPA"
  }
}
```

#### Get all tips
```
GET /api/v1/tips
```

---

## 📱 Flutter Integration

Copy `flutter_client/enviora_api_service.dart` into your Flutter project at `lib/services/`.

Add the `http` package to `pubspec.yaml`:
```yaml
dependencies:
  http: ^1.2.0
```

### Usage examples

```dart
final api = EnvioraApiService();

// Load categories for the grid
final categories = await api.getCategories();

// Load items for a category with pagination
final result = await api.getItems(categoryId: 1, page: 1);
final items = result.items;
final hasMore = result.hasNext;

// Load more (infinite scroll)
if (result.hasNext) {
  final nextPage = await api.getItems(categoryId: 1, page: 2);
}

// Search as user types
final searchResult = await api.searchItems('plastic bottle');

// Show item detail page
final detail = await api.getItemById(9);
print(detail.disposalInstructions); // List<String>
print(detail.youtubeVideoUrl);      // YouTube link

// Did You Know widget
final tip = await api.getRandomTip();
print(tip.tip);
```

### Android emulator note
The `baseUrl` in `enviora_api_service.dart` uses `10.0.2.2` which maps to your host machine's localhost from within the Android emulator. For iOS Simulator use `localhost`. For physical devices, use your machine's local IP (e.g., `192.168.1.x`).

---

## 🗄️ Database Schema

```
waste_categories        waste_items
──────────────         ──────────────────────
id (PK)                id (PK)
name                   category_id (FK)
slug (UNIQUE)          name
description            image_url
image_url              short_description
color_hex              disposal_instructions (JSON)
created_at             youtube_video_url
                       tags
                       created_at

recycling_tips
──────────────
id (PK)
tip
source
created_at
```

---

## ⚙️ Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `3000` | Server port |
| `NODE_ENV` | `development` | Environment |
| `DB_HOST` | `localhost` | MySQL host |
| `DB_PORT` | `3306` | MySQL port |
| `DB_USER` | `root` | MySQL user |
| `DB_PASSWORD` | `` | MySQL password |
| `DB_NAME` | `enviora_db` | Database name |
| `DEFAULT_PAGE_SIZE` | `10` | Items per page default |
| `MAX_PAGE_SIZE` | `50` | Maximum items per page |

---

## 🔒 Security Features

- **Helmet** — HTTP security headers
- **CORS** — Configurable origin whitelist
- **Rate limiting** — 100 requests / 15 min per IP
- **Input validation** — Parameterised queries (SQL injection safe)
- **Error masking** — Stack traces hidden in production

---

## 📈 Adding More Items

Insert more waste items directly into MySQL:

```sql
USE enviora_db;

INSERT INTO waste_items (category_id, name, image_url, short_description, disposal_instructions, youtube_video_url, tags)
VALUES (
  2,                                    -- category_id (2 = Recyclable)
  'Plastic Straw',
  'https://images.unsplash.com/...',
  'Single-use plastic drinking straws',
  '["Avoid single-use straws where possible","If used, place in recycling bin","Metal or bamboo straws are reusable alternatives"]',
  'https://www.youtube.com/watch?v=...',
  'plastic, straw, single-use, recycle'
);
```
