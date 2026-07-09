import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type TaskDocument = Task & Document;

export enum TaskType {
    FEATURE = 'FEATURE',
    BUG = 'BUG',
    CHORE = 'CHORE',
}

export enum TaskStatus {
    TODO = 'TODO',
    IN_PROGRESS = 'IN_PROGRESS',
    REVIEW = 'REVIEW',
    DONE = 'DONE',
}

@Schema({ timestamps: true })
export class Task {
    @Prop({ required: true })
    title: string;

    @Prop()
    description: string;

    @Prop({ enum: TaskType, default: TaskType.FEATURE })
    type: TaskType;

    @Prop({ default: 0 })
    storyPoints: number;

    @Prop({ enum: TaskStatus, default: TaskStatus.TODO })
    status: TaskStatus;

    @Prop({ type: Types.ObjectId, ref: 'Project', required: true })
    projectId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'Sprint' })
    sprintId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'User' })
    assigneeId: Types.ObjectId;
}

export const TaskSchema = SchemaFactory.createForClass(Task);
