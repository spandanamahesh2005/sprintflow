import { Controller, Get, Post, Body, Param, Put, UseGuards, Query } from '@nestjs/common';
import { TasksService } from './tasks.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('tasks')
@UseGuards(AuthGuard('jwt'))
export class TasksController {
    constructor(private readonly tasksService: TasksService) { }

    @Post()
    create(@Body() createTaskDto: any) {
        return this.tasksService.create(createTaskDto);
    }

    @Get()
    findByProject(@Query('projectId') projectId: string) {
        return this.tasksService.findByProject(projectId);
    }

    @Get('backlog')
    findBacklog(@Query('projectId') projectId: string) {
        return this.tasksService.findBacklog(projectId);
    }

    @Get('sprint/:sprintId')
    findBySprint(@Param('sprintId') sprintId: string) {
        return this.tasksService.findBySprint(sprintId);
    }

    @Put(':id')
    update(@Param('id') id: string, @Body() updateTaskDto: any) {
        return this.tasksService.update(id, updateTaskDto);
    }
}
