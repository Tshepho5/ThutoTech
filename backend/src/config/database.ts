import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
});

export async function connectDatabase() {
  try {
    await prisma.$connect();
    console.log('✅ Connected successfully to PostgreSQL Database.');
  } catch (error) {
    console.error('❌ Failed to connect to PostgreSQL Database:', error);
  }
}
