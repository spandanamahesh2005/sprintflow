import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Project, ProjectDocument, ProjectRole } from '../schemas/project.schema';

@Injectable()
export class ProjectsService {
    constructor(@InjectModel(Project.name) private projectModel: Model<ProjectDocument>) { }

    async create(createProjectDto: any, userId: string): Promise<ProjectDocument> {
        const newProject = new this.projectModel({
            ...createProjectDto,
            ownerId: userId,
            members: [{ userId, role: ProjectRole.PO }], // Creator is PO by default
        });
        return newProject.save();
    }

    async findAll(userId: string): Promise<ProjectDocument[]> {
        // efficient query for projects where user is owner OR member
        return this.projectModel.find({
            $or: [{ ownerId: userId }, { 'members.userId': userId }],
        }).exec();
    }

    async findOne(id: string): Promise<ProjectDocument> {
        return this.projectModel.findById(id).populate('members.userId', 'name email').exec();
    }
}
