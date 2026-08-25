import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';
import { connectDatabase } from './config/database';
import { apiRouter } from './routes/api.routes';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5000;

// Security & Utility Middlewares
app.use(helmet());
app.use(cors({ origin: '*' }));
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

import path from 'path';
import fs from 'fs';

// API Routes
app.use('/api/v1', apiRouter);

// Health Check Endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'HEALTHY',
    service: 'ThutoTech PostgreSQL Backend API',
    version: '1.0.0',
    timestamp: new Date().toISOString(),
  });
});

// Serve Flutter Web if build directory exists
const candidates = [
  path.resolve(__dirname, '../public'),
  path.resolve(__dirname, '../../public'),
  path.resolve(process.cwd(), 'public'),
  path.resolve(process.cwd(), '../public'),
  path.resolve(__dirname, '../../build/web'),
  path.resolve(__dirname, '../build/web'),
  path.resolve(__dirname, '../../../build/web'),
  path.resolve(process.cwd(), 'build/web'),
  path.resolve(process.cwd(), '../build/web'),
];

let webDir: string | null = null;
for (const cand of candidates) {
  if (fs.existsSync(cand)) {
    webDir = cand;
    console.log(`🌐 Found Flutter Web Build directory at: ${webDir}`);
    break;
  }
}

if (webDir) {
  app.use(express.static(webDir, {
    setHeaders: (res, filePath) => {
      if (filePath.endsWith('.html') || filePath.endsWith('.js') || filePath.endsWith('.json')) {
        res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
        res.setHeader('Pragma', 'no-cache');
        res.setHeader('Expires', '0');
      }
    }
  }));
  app.get('*', (req, res, next) => {
    if (req.path.startsWith('/api') || req.path.startsWith('/health')) {
      return next();
    }
    res.setHeader('Cache-Control', 'no-cache, no-store, must-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
    res.sendFile(path.join(webDir!, 'index.html'));
  });
} else {
  // If Flutter web build is compiling or not built yet, render a rich landing page
  app.get('/', (req, res) => {
    res.send(`
      <!DOCTYPE html>
      <html lang="en">
      <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>ThutoTech - Learn • Connect • Empower</title>
        <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@400;600;700&display=swap" rel="stylesheet">
        <style>
          body { margin: 0; background: #0B192C; color: white; font-family: 'Outfit', sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; text-align: center; }
          .card { background: #0F172A; padding: 40px; border-radius: 24px; border: 1px solid rgba(255,255,255,0.1); max-width: 500px; margin: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.5); }
          h1 { color: #16C47F; margin-bottom: 8px; }
          p { color: #94A3B8; font-size: 14px; line-height: 1.6; }
          .btn { display: inline-block; background: #16C47F; color: white; padding: 12px 24px; border-radius: 12px; text-decoration: none; font-weight: bold; margin-top: 20px; }
          .badge { display: inline-block; background: rgba(22, 196, 127, 0.15); color: #16C47F; padding: 6px 12px; border-radius: 8px; font-size: 12px; font-weight: bold; margin-bottom: 12px; }
        </style>
      </head>
      <body>
        <div class="card">
          <div class="badge">🚀 ThutoTech Ecosystem Online</div>
          <h1>ThutoTech</h1>
          <p>The Flutter Web application is ready. Run <code>flutter build web --release</code> to update the static web bundle, or explore the backend API below.</p>
          <a href="/api/v1" class="btn">Explore API Documentation</a>
        </div>
      </body>
      </html>
    `);
  });
}

// Start Server
async function bootstrap() {
  await connectDatabase();
  app.listen(PORT, () => {
    console.log(`🚀 ThutoTech Backend Server is actively running on port ${PORT}`);
    console.log(`📡 Base API Endpoint: http://localhost:${PORT}`);
  });
}

bootstrap();
