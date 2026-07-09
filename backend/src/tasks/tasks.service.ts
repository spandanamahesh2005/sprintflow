import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Task, TaskDocument } from '../schemas/task.schema';

@Injectable()
export class TasksService {
    constructor(@InjectModel(Task.name) private taskModel: Model<TaskDocument>) { }

    async create(createTaskDto: any): Promise<TaskDocument> {
        return new this.taskModel(createTaskDto).save();
    }

    async findByProject(projectId: string): Promise<TaskDocument[]> {
        return this.taskModel.find({ projectId }).exec();
    }

    async findBacklog(projectId: string): Promise<TaskDocument[]> {
        return this.taskModel.find({ projectId, sprintId: null }).exec();
    }

    async findBySprint(sprintId: string): Promise<TaskDocument[]> {
        return this.taskModel.find({ sprintId }).exec();
    }

    async update(id: string, updateTaskDto: any): Promise<TaskDocument> {
        return this.taskModel.findByIdAndUpdate(id, updateTaskDto, { new: true }).exec();
    }
}
