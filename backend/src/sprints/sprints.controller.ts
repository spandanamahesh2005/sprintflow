import { Controller, Get, Post, Body, Param, Put, UseGuards, Query } from '@nestjs/common';
import { SprintsService } from './sprints.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('sprints')
@UseGuards(AuthGuard('jwt'))
export class SprintsController {
    constructor(private readonly sprintsService: SprintsService) { }

    @Post()
    create(@Body() createSprintDto: any) {
        return this.sprintsService.create(createSprintDto);
    }

    @Get()
    findByProject(@Query('projectId') projectId: string) {
        return this.sprintsService.findByProject(projectId);
    }

    @Get('active')
    findActive(@Query('projectId') projectId: string) {
        return this.sprintsService.findActive(projectId);
    }

    @Put(':id')
    update(@Param('id') id: string, @Body() updateSprintDto: any) {
        return this.sprintsService.update(id, updateSprintDto);
    }
}
