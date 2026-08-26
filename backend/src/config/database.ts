import { Pool } from 'pg';
import fs from 'fs';
import path from 'path';
import bcrypt from 'bcryptjs';
import dotenv from 'dotenv';

dotenv.config();

// PostgreSQL Connection Pool configuration
const getConnectionString = () => {
  if (process.env.DATABASE_URL) return process.env.DATABASE_URL;
  const user = process.env.DB_USER || 'postgres';
  const pass = encodeURIComponent(process.env.DB_PASSWORD || '');
  const host = process.env.DB_HOST || 'localhost';
  const port = process.env.DB_PORT || '5432';
  const name = process.env.DB_NAME || 'ThutoTech_DB';
  return `postgresql://${user}:${pass}@${host}:${port}/${name}`;
};

const isRemoteDb = () => {
  const dbUrl = process.env.DATABASE_URL || '';
  return dbUrl.length > 0 && !dbUrl.includes('localhost') && !dbUrl.includes('127.0.0.1');
};

export const pool = new Pool({
  connectionString: getConnectionString(),
  ssl: isRemoteDb() || process.env.NODE_ENV === 'production'
    ? { rejectUnauthorized: false }
    : false,
  max: 20,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 10000,
});

export const query = (text: string, params?: any[]) => pool.query(text, params);

export async function connectDatabase() {
  try {
    const client = await pool.connect();
    console.log('✅ Connected successfully to PostgreSQL Database (Native PG Driver).');
    client.release();

    // Execute backend/schema.sql as the single source of truth
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
      console.log(`📄 Initializing PostgreSQL schema from: ${sqlPath}`);
      const sqlContent = fs.readFileSync(sqlPath, 'utf-8');
      
      // Execute the entire schema.sql file
      await pool.query(sqlContent);
      console.log('✅ PostgreSQL Schema synchronized from schema.sql successfully.');
    } else {
      console.warn('⚠️ schema.sql not found in search paths.');
    }

    // Guarantee Super Admin Lebogang Makola seed
    const adminPassHash = await bcrypt.hash('#Admin#$5$', 10);
    await pool.query(`
      INSERT INTO "users" ("id", "email", "passwordHash", "name", "surname", "role", "phone", "status")
      VALUES (
        'usr_admin_lebogang',
        'thutotech.admin@gmail.com',
        $1,
        'Lebogang',
        'Makola',
        'ADMIN',
        '0820605107',
        'ACTIVE'
      )
      ON CONFLICT ("email") DO UPDATE SET
        "passwordHash" = $1,
        "name" = 'Lebogang',
        "surname" = 'Makola',
        "role" = 'ADMIN',
        "status" = 'ACTIVE';
    `, [adminPassHash]);

    console.log('✅ Super Administrator credentials initialized.');
  } catch (error: any) {
    console.error('⚠️ PostgreSQL Connection Notice:', error.message);
    if (!process.env.DATABASE_URL || process.env.DATABASE_URL.includes('localhost') || process.env.DATABASE_URL.includes('127.0.0.1')) {
      console.warn('📌 To connect your Render service to a cloud database, add `DATABASE_URL` in your Render Dashboard > Environment.');
    }
  }
}
