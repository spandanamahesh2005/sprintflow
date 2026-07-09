import { Controller, Get, Post, Put, Body, UseGuards, Request } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { UsersService } from './users.service';

@Controller('users')
export class UsersController {
    constructor(private readonly usersService: UsersService) { }

    @UseGuards(AuthGuard('jwt'))
    @Get('profile')
    getProfile(@Request() req) {
        return req.user;
    }

    @UseGuards(AuthGuard('jwt'))
    @Put('profile')
    async updateProfile(@Request() req, @Body() updateData: any) {
        return this.usersService.updateProfile(req.user.userId, updateData);
    }

    @UseGuards(AuthGuard('jwt'))
    @Get()
    async getAllUsers() {
        return this.usersService.findAll();
    }

    @UseGuards(AuthGuard('jwt'))
    @Post()
    async createUser(@Body() createUserDto: any) {
        return this.usersService.create(createUserDto);
    }
}
