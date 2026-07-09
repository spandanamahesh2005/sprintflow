import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document } from 'mongoose';

export type UserDocument = User & Document;

export enum UserRole {
    GUEST = 'GUEST',
    STUDENT = 'STUDENT',
    COACH = 'COACH',
    ADMIN = 'ADMIN',
}

@Schema({ timestamps: true })
export class User {
    @Prop({ required: true, unique: true })
    email: string;

    @Prop({ required: true })
    passwordHash: string;

    @Prop({ required: true })
    name: string;

    @Prop({ enum: UserRole, default: UserRole.STUDENT })
    role: UserRole;

    @Prop({ default: 0 })
    xp: number;

    @Prop({ default: 1 })
    level: number;

    @Prop({ type: [String], default: [] })
    badges: string[];
}

export const UserSchema = SchemaFactory.createForClass(User);
