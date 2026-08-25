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

// Start Server
async function bootstrap() {
  await connectDatabase();
  app.listen(PORT, () => {
    console.log(`🚀 ThutoTech Backend Server is actively running on port ${PORT}`);
    console.log(`📡 Base API Endpoint: http://localhost:${PORT}/api/v1`);
  });
}

bootstrap();
