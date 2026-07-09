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
        MongooseModule.forRootAsync({
            useFactory: async () => {
                try {
                    const { MongoMemoryServer } = await import('mongodb-memory-server');
                    const mongod = await MongoMemoryServer.create();
                    const uri = mongod.getUri();
                    console.log('Using In-Memory MongoDB at:', uri);
                    return { uri };
                } catch (err) {
                    console.error('Failed to start in-memory-mongo', err);
                    return { uri: 'mongodb://localhost:27017/agile-sim' }; // Fallback
                }
            },
        }),
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
