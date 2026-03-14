require('dotenv').config();
const express = require('express');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 5000;

app.use(cors());
app.use(express.json());

app.use('/api/auth',          require('./routes/auth'));
app.use('/api/schedules',     require('./routes/schedules'));
app.use('/api/trucks',        require('./routes/trucks'));
app.use('/api/issues',        require('./routes/issues'));
app.use('/api/activities',    require('./routes/activities'));
app.use('/api/eco-tips',      require('./routes/ecoTips'));
app.use('/api/notifications', require('./routes/notifications'));

app.get('/', (req, res) => {
  res.json({ message: '🚀 Enviora API is running!' });
});

app.use((err, req, res, next) => {
  console.error(err.message);
  res.status(500).json({ success: false, message: err.message });
});

app.listen(PORT, () => {
  console.log(`✅ Server running on http://localhost:${PORT}`);
});