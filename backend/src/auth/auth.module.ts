import { Module } from '@nestjs/common';
import { AuthService } from './auth.service';
import { UsersModule } from '../users/users.module';
import { PassportModule } from '@nestjs/passport';
import { LocalStrategy } from './local.strategy'; // We'll need this too
import { JwtModule } from '@nestjs/jwt';
import { JwtStrategy } from './jwt.strategy';
import { AuthController } from './auth.controller';

@Module({
    imports: [
        UsersModule,
        PassportModule,
        JwtModule.register({
            secret: 'secretKey', // TODO: Use ConfigService
            signOptions: { expiresIn: '60m' },
        }),
    ],
    providers: [AuthService, LocalStrategy, JwtStrategy],
    controllers: [AuthController],
})
export class AuthModule { }
