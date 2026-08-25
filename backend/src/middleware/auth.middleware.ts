import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { query } from '../config/database';
import { UserRole } from '../types/enums';

export interface AuthRequest extends Request {
  user?: {
    id: string;
    email: string;
    role: UserRole;
    schoolId?: string | null;
  };
}

export function authenticateToken(req: AuthRequest, res: Response, next: NextFunction) {
  const authHeader = req.headers['authorization'];
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ success: false, message: 'Authentication required. No token provided.' });
  }

  const secret = process.env.JWT_SECRET || 'thutotech_secret';

  jwt.verify(token, secret, (err, decoded: any) => {
    if (err) {
      return res.status(403).json({ success: false, message: 'Invalid or expired authentication token.' });
    }
    req.user = decoded;
    next();
  });
}

export function requireRole(allowedRoles: UserRole[]) {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ success: false, message: 'Unauthorized.' });
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({
        success: false,
        message: `Forbidden: Access restricted to roles [${allowedRoles.join(', ')}]. Current role: ${req.user.role}`,
      });
    }

    next();
  };
}

export async function verifyParentChildAccess(req: AuthRequest, res: Response, next: NextFunction) {
  const learnerId = req.params.learnerId || req.body.learnerId;
  const userId = req.user?.id;

  if (!userId || !learnerId) {
    return res.status(400).json({ success: false, message: 'Learner ID and Parent credentials required.' });
  }

  if (req.user?.role === UserRole.ADMIN || req.user?.role === UserRole.PRINCIPAL) {
    return next();
  }

  try {
    const parentRes = await query(`SELECT id FROM "parents" WHERE "userId" = $1 LIMIT 1`, [userId]);
    if (parentRes.rows.length === 0) {
      return res.status(403).json({ success: false, message: 'Parent profile not found.' });
    }

    const parentId = parentRes.rows[0].id;
    const relRes = await query(
      `SELECT * FROM "parent_learner_relationships" WHERE "parentId" = $1 AND "learnerId" = $2 AND "status" = 'ACTIVE'`,
      [parentId, learnerId]
    );

    if (relRes.rows.length === 0) {
      return res.status(403).json({
        success: false,
        message: 'Access Denied: You are not authorized to view academic data for this learner.',
      });
    }

    next();
  } catch (error: any) {
    return res.status(500).json({ success: false, message: error.message });
  }
}
