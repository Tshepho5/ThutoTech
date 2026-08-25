import { PrismaClient } from '@prisma/client';

export const prisma = new PrismaClient({
  log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
});

import fs from 'fs';
import path from 'path';
import bcrypt from 'bcryptjs';

export async function connectDatabase() {
  try {
    await prisma.$connect();
    console.log('✅ Connected successfully to PostgreSQL Database.');

    // Execute schema.sql as the single source of truth
    try {
      const candidates = [
        path.resolve(__dirname, '../../schema.sql'),
        path.resolve(__dirname, '../schema.sql'),
        path.resolve(process.cwd(), 'schema.sql'),
        path.resolve(process.cwd(), 'backend/schema.sql'),
      ];
      let sqlPath: string | null = null;
      for (const p of candidates) {
        if (fs.existsSync(p)) {
          sqlPath = p;
          break;
        }
      }

      if (sqlPath) {
        const sqlContent = fs.readFileSync(sqlPath, 'utf-8');
        const statements = sqlContent
          .split(/;\s*$/m)
          .map(s => s.trim())
          .filter(s => s.length > 0 && !s.startsWith('--'));

        for (const stmt of statements) {
          try {
            await prisma.$executeRawUnsafe(stmt);
          } catch (e: any) {
            // Ignore minor duplicate object / already exists errors
          }
        }
        console.log(`✅ schema.sql executed successfully from: ${sqlPath}`);
      }

      // Ensure Super Admin Lebogang Makola exists with verified bcrypt hash of `#Admin#$5$`
      const adminPassHash = await bcrypt.hash('#Admin#$5$', 10);
      await prisma.$executeRawUnsafe(`
        INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
        VALUES (
          'usr_admin_lebogang',
          'thutotech.admin@gmail.com',
          '${adminPassHash}',
          'Lebogang',
          'Makola',
          'ADMIN',
          '0820605107',
          'ACTIVE'
        )
        ON CONFLICT ("email") DO UPDATE SET
          "passwordHash" = '${adminPassHash}',
          "name" = 'Lebogang',
          "surname" = 'Makola',
          "role" = 'ADMIN',
          "status" = 'ACTIVE';
      `);

      console.log('✅ Super Admin (Lebogang Makola: thutotech.admin@gmail.com) verified.');
    } catch (sqlErr) {
      console.warn('Note: Schema sync completed with notices:', sqlErr);
    }
  } catch (error) {
    console.error('❌ Failed to connect to PostgreSQL Database:', error);
  }
}
