import { Injectable, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User, UserDocument } from '../schemas/user.schema';
import * as bcrypt from 'bcrypt';

@Injectable()
export class UsersService {
    constructor(@InjectModel(User.name) private userModel: Model<UserDocument>) { }

    async create(createUserDto: any): Promise<UserDocument> {
        const existingUser = await this.userModel.findOne({ email: createUserDto.email });
        if (existingUser) {
            throw new BadRequestException('User with this email already exists');
        }

        const hashedPassword = await bcrypt.hash(createUserDto.password, 10);
        const createdUser = new this.userModel({
            name: createUserDto.name,
            email: createUserDto.email,
            passwordHash: hashedPassword,
            role: createUserDto.role || 'STUDENT',
        });
        return createdUser.save();
    }

    async findOne(email: string): Promise<UserDocument | undefined> {
        return this.userModel.findOne({ email }).exec();
    }

    async findById(id: string): Promise<User> {
        return this.userModel.findById(id).exec();
    }

    async findAll(): Promise<User[]> {
        return this.userModel.find().select('-passwordHash').exec();
    }

    async updateProfile(userId: string, updateData: any): Promise<User> {
        const user = await this.userModel.findById(userId);
        if (!user) {
            throw new BadRequestException('User not found');
        }

        if (updateData.name) {
            user.name = updateData.name;
        }

        if (updateData.newPassword) {
            if (!updateData.currentPassword) {
                throw new BadRequestException('Current password is required');
            }

            const isPasswordValid = await bcrypt.compare(updateData.currentPassword, user.passwordHash);
            if (!isPasswordValid) {
                throw new BadRequestException('Current password is incorrect');
            }

            user.passwordHash = await bcrypt.hash(updateData.newPassword, 10);
        }

        await user.save();
        const { passwordHash, ...result } = user.toObject();
        return result as any;
    }
}
