import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { DatabaseService } from '../../database/database.service';
import { PinLoginDto } from './pin-login.dto';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private readonly db: DatabaseService,
    private readonly jwtService: JwtService,
  ) {}

  private hashPin(pin: string): string {
    return crypto.createHash('sha256').update(pin).digest('hex');
  }

  async validatePin(dto: PinLoginDto) {
    const hashed = this.hashPin(dto.pin);
    const result = await this.db.query(
      `SELECT id, branch_id, username, full_name, role, is_active 
       FROM users 
       WHERE username = $1 AND pin_hash = $2`,
      [dto.username, hashed],
    );

    if (result.rows.length === 0) {
      throw new UnauthorizedException('Invalid username or PIN');
    }

    const user = result.rows[0];
    if (!user.is_active) {
      throw new UnauthorizedException('User account is deactivated');
    }

    const payload = {
      sub: user.id,
      username: user.username,
      role: user.role,
      branchId: user.branch_id,
      fullName: user.full_name,
    };

    return {
      accessToken: this.jwtService.sign(payload),
      user: {
        id: user.id,
        branchId: user.branch_id,
        username: user.username,
        fullName: user.full_name,
        role: user.role,
      },
    };
  }

  async getStaffForBranch(branchId: string) {
    const result = await this.db.query(
      `SELECT id, branch_id, username, pin_hash, full_name, role, is_active 
       FROM users 
       WHERE (branch_id = $1 OR role = 'GLOBAL_ADMIN') AND is_active = true`,
      [branchId],
    );
    return result.rows;
  }
}
