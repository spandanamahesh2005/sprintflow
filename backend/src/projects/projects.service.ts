import { Injectable, ForbiddenException, NotFoundException, BadRequestException } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Project, ProjectDocument, ProjectRole } from '../schemas/project.schema';

@Injectable()
export class ProjectsService {
    constructor(@InjectModel(Project.name) private projectModel: Model<ProjectDocument>) { }

    async create(createProjectDto: any, userId: string): Promise<ProjectDocument> {
        if (!createProjectDto.deadline) {
            throw new BadRequestException('Deadline is required');
        }
        const parsedDeadline = new Date(createProjectDto.deadline);
        if (isNaN(parsedDeadline.getTime())) {
            throw new BadRequestException('Invalid deadline date format');
        }

        const newProject = new this.projectModel({
            ...createProjectDto,
            ownerId: userId,
            createdBy: userId,
            deadline: parsedDeadline,
            members: [{ userId, role: ProjectRole.PO }], // Creator is PO by default
        });
        return newProject.save();
    }

    async findAll(userId: string): Promise<ProjectDocument[]> {
        // efficient query for projects where user is owner OR member
        return this.projectModel.find({
            $or: [{ ownerId: userId }, { 'members.userId': userId }],
        })
        .populate('createdBy', 'name email')
        .exec();
    }

    async findOne(id: string): Promise<ProjectDocument> {
        return this.projectModel.findById(id)
            .populate('members.userId', 'name email')
            .populate('createdBy', 'name email')
            .exec();
    }

    async endProject(id: string, userId: string): Promise<ProjectDocument> {
        const project = await this.projectModel.findById(id).exec();
        if (!project) {
            throw new NotFoundException('Project not found');
        }
        if (!project.createdBy || project.createdBy.toString() !== userId) {
            throw new ForbiddenException('Only the project host can end this project.');
        }

        const now = new Date();
        if (project.deadline && now > new Date(project.deadline)) {
            project.status = 'ENDED_LATE';
        } else {
            project.status = 'ENDED';
        }

        return project.save();
    }

    async extendDeadline(id: string, newDeadline: Date, userId: string): Promise<ProjectDocument> {
        if (!newDeadline) {
            throw new BadRequestException('newDeadline is required');
        }
        const parsedDeadline = new Date(newDeadline);
        if (isNaN(parsedDeadline.getTime())) {
            throw new BadRequestException('Invalid newDeadline date format');
        }
        if (parsedDeadline <= new Date()) {
            throw new BadRequestException('New deadline must be in the future.');
        }

        const project = await this.projectModel.findById(id).exec();
        if (!project) {
            throw new NotFoundException('Project not found');
        }
        if (!project.createdBy || project.createdBy.toString() !== userId) {
            throw new ForbiddenException('Only the project host can extend the deadline.');
        }
        if (project.status !== 'ACTIVE') {
            throw new BadRequestException(`Cannot extend the deadline of a project that is already ${project.status}.`);
        }

        project.deadline = parsedDeadline;
        return project.save();
    }
}
