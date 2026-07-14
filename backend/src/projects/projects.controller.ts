import { Controller, Get, Post, Patch, Body, Param, UseGuards, Request } from '@nestjs/common';
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

    @Patch(':id/end')
    endProject(@Param('id') id: string, @Request() req) {
        return this.projectsService.endProject(id, req.user.userId);
    }

    @Patch(':id/deadline')
    extendDeadline(
        @Param('id') id: string,
        @Body('newDeadline') newDeadline: Date,
        @Request() req,
    ) {
        return this.projectsService.extendDeadline(id, newDeadline, req.user.userId);
    }
}
