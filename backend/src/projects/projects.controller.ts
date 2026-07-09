import { Controller, Get, Post, Body, Param, UseGuards, Request } from '@nestjs/common';
import { ProjectsService } from './projects.service';
import { AuthGuard } from '@nestjs/passport';

@Controller('projects')
@UseGuards(AuthGuard('jwt'))
export class ProjectsController {
    constructor(private readonly projectsService: ProjectsService) { }

    @Post()
    create(@Body() createProjectDto: any, @Request() req) {
        return this.projectsService.create(createProjectDto, req.user.userId);
    }

    @Get()
    findAll(@Request() req) {
        return this.projectsService.findAll(req.user.userId);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.projectsService.findOne(id);
    }
}
