import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';

export type SprintDocument = Sprint & Document;

export enum SprintStatus {
    PLANNING = 'PLANNING',
    ACTIVE = 'ACTIVE',
    COMPLETED = 'COMPLETED',
}

@Schema()
export class EventLog {
    @Prop()
    day: number;

    @Prop()
    description: string;

    @Prop()
    impact: string;
}

@Schema({ timestamps: true })
export class Sprint {
    @Prop({ required: true })
    name: string;

    @Prop()
    goal: string;

    @Prop({ type: Types.ObjectId, ref: 'Project', required: true })
    projectId: Types.ObjectId;

    @Prop({ enum: SprintStatus, default: SprintStatus.PLANNING })
    status: SprintStatus;

    @Prop()
    startDate: Date;

    @Prop()
    endDate: Date;

    @Prop({ default: 10 }) // 10 virtual days default
    durationDays: number;

    @Prop({ default: 0 })
    currentDay: number;

    @Prop([EventLog])
    eventLog: EventLog[];
}

export const SprintSchema = SchemaFactory.createForClass(Sprint);
