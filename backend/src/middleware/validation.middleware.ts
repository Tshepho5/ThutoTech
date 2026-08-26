import { Request, Response, NextFunction } from 'express';

export interface ValidationError {
  field: string;
  message: string;
}

export class StrictValidator {
  static isOnlyLetters(value: string): boolean {
    if (!value) return false;
    // Strictly disallows numeric digits
    if (/[0-9]/.test(value)) return false;
    return /^[a-zA-Z\s\-']+$/.test(value.trim());
  }

  static isOnlyNumbers(value: string): boolean {
    if (!value) return false;
    // Strictly disallows letters
    if (/[a-zA-Z]/.test(value)) return false;
    return /^[0-9]+(\.[0-9]+)?$/.test(value.trim());
  }

  static isNationalID(value: string): boolean {
    if (!value) return false;
    if (/[a-zA-Z]/.test(value)) return false;
    return /^[0-9]{13}$/.test(value.trim());
  }

  static isPhoneNumber(value: string): boolean {
    if (!value) return false;
    if (/[a-zA-Z]/.test(value)) return false;
    return /^[0-9]{10}$/.test(value.trim().replace(/\s+/g, ''));
  }

  static isEmail(value: string): boolean {
    if (!value) return false;
    return /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(value.trim());
  }
}

export function validateAdmissionApplication(req: Request, res: Response, next: NextFunction) {
  const errors: ValidationError[] = [];
  const {
    primaryParentName,
    primaryParentSurname,
    primaryParentPhone,
    primaryParentEmail,
    primaryParentIdNumber,
    hasSecondaryParent,
    secondaryParentName,
    secondaryParentSurname,
    secondaryParentPhone,
    secondaryParentEmail,
    learners,
    learnerName,
    learnerSurname,
    learnerIdNumber,
    gradeApplyingFor,
  } = req.body;

  // 1. Primary Parent Validations
  if (!primaryParentName || primaryParentName.trim().length < 2) {
    errors.push({
      field: 'primaryParentName',
      message: 'Primary Parent First Name is required.',
    });
  }

  if (!primaryParentSurname || primaryParentSurname.trim().length < 2) {
    errors.push({
      field: 'primaryParentSurname',
      message: 'Primary Parent Surname is required.',
    });
  }

  if (!primaryParentPhone || !StrictValidator.isPhoneNumber(primaryParentPhone)) {
    errors.push({
      field: 'primaryParentPhone',
      message: 'Primary Parent Phone must contain 10 digits (e.g., 0821234567).',
    });
  }

  if (!primaryParentIdNumber || primaryParentIdNumber.trim().length < 6) {
    errors.push({
      field: 'primaryParentIdNumber',
      message: 'Primary Parent National ID or Passport Number is required.',
    });
  }

  if (!primaryParentEmail || !StrictValidator.isEmail(primaryParentEmail)) {
    errors.push({
      field: 'primaryParentEmail',
      message: 'Please provide a valid email address for admission correspondence.',
    });
  }

  // 2. Optional Secondary Parent Validations
  if (hasSecondaryParent) {
    if (secondaryParentName && secondaryParentName.trim().length < 2) {
      errors.push({
        field: 'secondaryParentName',
        message: 'Secondary Parent Name must contain at least 2 characters.',
      });
    }
    if (secondaryParentPhone && !StrictValidator.isPhoneNumber(secondaryParentPhone)) {
      errors.push({
        field: 'secondaryParentPhone',
        message: 'Secondary Parent Phone must be a valid 10-digit number.',
      });
    }
    if (secondaryParentEmail && !StrictValidator.isEmail(secondaryParentEmail)) {
      errors.push({
        field: 'secondaryParentEmail',
        message: 'Secondary Parent Email must be a valid email format.',
      });
    }
  }

  // 3. Multi-Child / Learner Validations
  const rawLearners: any[] = Array.isArray(learners) && learners.length > 0
    ? learners
    : (learnerName ? [{ learnerName, learnerSurname, learnerIdNumber, gradeApplyingFor }] : []);

  if (rawLearners.length === 0) {
    errors.push({
      field: 'learners',
      message: 'At least one child enrolment record is required.',
    });
  } else {
    rawLearners.forEach((l: any, idx: number) => {
      if (!l.learnerName || l.learnerName.trim().length < 2) {
        errors.push({
          field: `learners[${idx}].learnerName`,
          message: `Learner #${idx + 1} first name is required.`,
        });
      }
      if (!l.learnerSurname || l.learnerSurname.trim().length < 2) {
        errors.push({
          field: `learners[${idx}].learnerSurname`,
          message: `Learner #${idx + 1} surname is required.`,
        });
      }
      if (!l.gradeApplyingFor) {
        errors.push({
          field: `learners[${idx}].gradeApplyingFor`,
          message: `Grade applying for is required for Learner #${idx + 1}.`,
        });
      }
    });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: errors[0].message || 'Validation failed on input placeholders.',
      errors,
    });
  }

  next();
}

export function validateRegistration(req: Request, res: Response, next: NextFunction) {
  const errors: ValidationError[] = [];
  const {
    registrationToken,
    parentName,
    parentSurname,
    parentEmail,
    parentPassword,
    learnerName,
    learnerSurname,
    learnerIdNumber,
  } = req.body;

  if (!registrationToken) {
    errors.push({ field: 'registrationToken', message: 'Admission Registration Token is required.' });
  }

  if (!parentName || !StrictValidator.isOnlyLetters(parentName)) {
    errors.push({ field: 'parentName', message: 'Parent Name must contain only letters.' });
  }

  if (!parentSurname || !StrictValidator.isOnlyLetters(parentSurname)) {
    errors.push({ field: 'parentSurname', message: 'Parent Surname must contain only letters.' });
  }

  if (!parentEmail || !StrictValidator.isEmail(parentEmail)) {
    errors.push({ field: 'parentEmail', message: 'Valid email address is required.' });
  }

  if (!parentPassword || parentPassword.length < 6) {
    errors.push({ field: 'parentPassword', message: 'Password must be at least 6 characters.' });
  }

  if (!learnerIdNumber || !StrictValidator.isNationalID(learnerIdNumber)) {
    errors.push({ field: 'learnerIdNumber', message: 'Learner ID must be 13 digits (numbers only).' });
  }

  if (!learnerName || !StrictValidator.isOnlyLetters(learnerName)) {
    errors.push({ field: 'learnerName', message: 'Learner Name must contain only letters.' });
  }

  if (!learnerSurname || !StrictValidator.isOnlyLetters(learnerSurname)) {
    errors.push({ field: 'learnerSurname', message: 'Learner Surname must contain only letters.' });
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: 'Registration validation failed.',
      errors,
    });
  }

  next();
}
