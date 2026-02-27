const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const dist = path.join(root, 'dist');

if (!fs.existsSync(dist)) {
  fs.mkdirSync(dist, { recursive: true });
}

['index.html', 'robots.txt', 'sitemap.xml'].forEach((file) => {
  const from = path.join(root, file);
  const to = path.join(dist, file);
  if (fs.existsSync(from)) {
    fs.copyFileSync(from, to);
  }
});

console.log('Build completed. Files copied to /dist');
