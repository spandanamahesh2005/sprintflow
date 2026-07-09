import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Sprint, SprintDocument, SprintStatus } from '../schemas/sprint.schema';

@Injectable()
export class SprintsService {
    constructor(@InjectModel(Sprint.name) private sprintModel: Model<SprintDocument>) { }

    async create(createSprintDto: any): Promise<SprintDocument> {
        return new this.sprintModel(createSprintDto).save();
    }

    async findByProject(projectId: string): Promise<SprintDocument[]> {
        return this.sprintModel.find({ projectId }).sort({ number: -1 }).exec();
    }

    async findActive(projectId: string): Promise<SprintDocument | null> {
        return this.sprintModel.findOne({ projectId, status: SprintStatus.ACTIVE }).exec();
    }

    async update(id: string, updateSprintDto: any): Promise<SprintDocument> {
        return this.sprintModel.findByIdAndUpdate(id, updateSprintDto, { new: true }).exec();
    }
}
