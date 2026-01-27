# Agile Sprint Simulation System

A gamified web application for learning and practicing Agile Scrum methodology.

## 🚀 Getting Started

### Prerequisites
- Node.js (v18+)
- Docker (for MongoDB)

### 1. Database Setup

Start the MongoDB instance using Docker:

```bash
docker-compose up -d
```

### 2. Backend Setup (NestJS)

Navigate to the backend directory and install dependencies:

```bash
cd backend
npm install
```

Start the backend server:

```bash
npm run start:dev
```
The API will be available at `http://localhost:3001`.
Swagger docs available at `http://localhost:3001/api`.

### 3. Frontend Setup (Next.js)

Navigate to the frontend directory and install dependencies:

```bash
cd frontend
npm install
```

Start the frontend development server:

```bash
npm run dev
```
The application will be available at `http://localhost:3000`.

## 🎮 How to Play

1. **Register** a new account.
2. **Create a Project** from the Dashboard.
3. **Build your Backlog**: Add User Stories to your project.
4. **Plan a Sprint**: (Coming Soon: Move items to sprint).
5. **Run Simulation**: Go to the Sprint Board and click "Next Day" to advance time and face random agile events!

## 🛠 Tech Stack

- **Frontend**: Next.js 14, Tailwind CSS, Framer Motion, Zustand
- **Backend**: NestJS, Mongoose, Passport JWT
- **Database**: MongoDB
# Agile-Sprint-Simulation
# Agile-Sprint-Simulation
# Agile-Sprint-Simulation
# Agile-Sprint-Simulation
