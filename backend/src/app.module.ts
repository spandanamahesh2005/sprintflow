import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { ConfigModule } from '@nestjs/config';
import { UsersModule } from './users/users.module';
import { ProjectsModule } from './projects/projects.module';
import { SprintsModule } from './sprints/sprints.module';
import { TasksModule } from './tasks/tasks.module';
import { AuthModule } from './auth/auth.module';

@Module({
    imports: [
        ConfigModule.forRoot({ isGlobal: true }),
     MongooseModule.forRoot(
    'mongodb://localhost:27017/agile-sim'
         ),
        UsersModule,
        ProjectsModule,
        SprintsModule,
        TasksModule,
        AuthModule,
    ],
    controllers: [],
    providers: [],
})
export class AppModule { }