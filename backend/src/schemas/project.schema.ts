import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { User } from './user.schema';

export type ProjectDocument = Project & Document;

export enum ProjectRole {
    PO = 'PO',
    SM = 'SM',
    DEV = 'DEV',
}

@Schema()
export class ProjectMember {
    @Prop({ type: Types.ObjectId, ref: 'User' })
    userId: Types.ObjectId;

    @Prop({ enum: ProjectRole })
    role: ProjectRole;
}

@Schema({ timestamps: true })
export class Project {
    @Prop({ required: true })
    name: string;

    @Prop()
    description: string;

    @Prop({ type: Types.ObjectId, ref: 'User', required: true })
    ownerId: Types.ObjectId;

    @Prop({ type: Types.ObjectId, ref: 'User', required: true })
    createdBy: Types.ObjectId;

    @Prop({ type: String, default: 'ACTIVE' })
    status: string;

    @Prop({ type: Date, required: true })
    deadline: Date;

    @Prop([ProjectMember])
    members: ProjectMember[];

    @Prop({ default: 0 })
    currentSprintNumber: number;
}

export const ProjectSchema = SchemaFactory.createForClass(Project);
