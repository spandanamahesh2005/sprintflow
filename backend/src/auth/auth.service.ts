import { Injectable, UnauthorizedException } from '@nestjs/common';
import { UsersService } from '../users/users.service';
import { JwtService } from '@nestjs/jwt';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
    constructor(
        private usersService: UsersService,
        private jwtService: JwtService,
    ) { }

    async validateUser(email: string, pass: string): Promise<any> {
        const user = await this.usersService.findOne(email);
        if (!user) {
            console.log(`Auth Failed: User not found for email ${email}`);
            return null;
        }
        const isMatch = await bcrypt.compare(pass, user.passwordHash);
        if (isMatch) {
            const { passwordHash, ...result } = user.toObject();
            return result;
        }
        console.log(`Auth Failed: Password mismatch for user ${email}`);
        return null;
    }

    async login(user: any) {
        const payload = { email: user.email, sub: user._id, role: user.role };
        return {
            access_token: this.jwtService.sign(payload),
            user: {
                id: user._id,
                name: user.name,
                email: user.email,
                role: user.role
            }
        };
    }

    async register(registrationData: any) {
        try {
            console.log('Registering user:', registrationData.email);
            const user = await this.usersService.create(registrationData);
            return this.login(user);
        } catch (error) {
            console.error('Registration error:', error);
            throw error;
        }
    }
}
