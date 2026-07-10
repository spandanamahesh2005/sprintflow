import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';

async function bootstrap() {
    const app = await NestFactory.create(AppModule);

    app.enableCors({
        origin: 'http://localhost:3000',
        credentials: true,
    });
    app.useGlobalPipes(new ValidationPipe());

    const config = new DocumentBuilder()
        .setTitle('Agile Sprint Simulation API')
        .setDescription('The Agile Sprint Simulation System API description')
        .setVersion('1.0')
        .addBearerAuth()
        .build();
    const document = SwaggerModule.createDocument(app, config);
    SwaggerModule.setup('api', app, document);

    const PORT = 3001;
    let server: any;

    try {
        // Get the underlying HTTP server and enable SO_REUSEADDR
        const httpServer = app.getHttpServer();
        httpServer.setMaxListeners(Infinity);
        
        // Enable address reuse to allow quick port rebinding
        if (httpServer.listening === false) {
            httpServer.once('listening', () => {
                httpServer.on('clientError', (err: any, socket: any) => {
                    if (err.code === 'EADDRINUSE') {
                        socket.end('HTTP/1.1 503 Service Unavailable\r\n\r\n');
                    }
                });
            });
        }

        server = await app.listen(PORT, '0.0.0.0');
        console.log(`✅ Application is running on: http://localhost:${PORT}`);
    } catch (error: any) {
        if (error.code === 'EADDRINUSE') {
            console.error(
                `\n❌ ERROR: Port ${PORT} is already in use.\n` +
                `To fix this:\n` +
                `  On Windows: netstat -ano | findstr :${PORT}, then taskkill /PID <pid> /F\n` +
                `  On Mac/Linux: lsof -i :${PORT}, then kill -9 <pid>\n`
            );
        } else {
            console.error('❌ Failed to start application:', error.message);
        }
        process.exit(1);
    }

    // Graceful shutdown handlers
    const gracefulShutdown = async (signal: string) => {
        console.log(`\n📍 Received ${signal} signal. Starting graceful shutdown...`);
        try {
            if (server) {
                server.close(() => {
                    console.log('✅ Server closed gracefully');
                    process.exit(0);
                });
                // Force exit after 10 seconds if not graceful
                setTimeout(() => {
                    console.log('⏱️  Timeout: forcing exit');
                    process.exit(1);
                }, 10000);
            }
        } catch (err) {
            console.error('Error during shutdown:', err);
            process.exit(1);
        }
    };

    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));
}

bootstrap();
