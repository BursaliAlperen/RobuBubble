const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(express.json());
app.use(express.static(__dirname));

app.get('/api/health', (_req, res) => {
  res.json({ ok: true, service: 'RobuBubble API', timestamp: new Date().toISOString() });
});

app.get('/api/tasks', (_req, res) => {
  res.json([
    { id: 1, type: 'Visit Site - Premium Campaign', reward: 8 },
    { id: 2, type: 'Visit Site - Gaming Portal', reward: 6 },
    { id: 3, type: 'Visit Site - Fast Offer', reward: 12 }
  ]);
});

app.get('*', (_req, res) => {
  res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
  console.log(`RobuBubble running at http://localhost:${PORT}`);
});
