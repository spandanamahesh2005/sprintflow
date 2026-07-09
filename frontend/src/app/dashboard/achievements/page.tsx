'use client';
import { Trophy, Star, Target, Zap, Lock } from 'lucide-react';

export default function AchievementsPage() {
    const achievements = [
        { id: 1, title: "Sprinting Start", description: "Complete your first sprint", icon: Zap, unlocked: true },
        { id: 2, title: "Backlog Master", description: "Create 10 user stories", icon: Star, unlocked: true },
        { id: 3, title: "Velocity King", description: "Increase velocity by 20%", icon: Target, unlocked: false },
        { id: 4, title: "Grandmaster", description: "Reach Level 20", icon: Trophy, unlocked: false },
    ];

    return (
        <div className="space-y-8">
            <div>
                <h1 className="text-3xl font-bold">Achievements</h1>
                <p className="text-slate-400">Track your progress and earn badges.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                {achievements.map((achievement) => (
                    <div key={achievement.id} className={`glass-card p-6 rounded-2xl border ${achievement.unlocked ? 'border-amber-500/20 bg-amber-500/5' : 'border-slate-800 bg-slate-900/50 grayscale opacity-70'}`}>
                        <div className={`w-12 h-12 rounded-xl mb-4 flex items-center justify-center ${achievement.unlocked ? 'bg-amber-500/20 text-amber-500' : 'bg-slate-800 text-slate-600'}`}>
                            {achievement.unlocked ? <achievement.icon className="w-6 h-6" /> : <Lock className="w-6 h-6" />}
                        </div>
                        <h3 className="font-bold mb-1">{achievement.title}</h3>
                        <p className="text-sm text-slate-500">{achievement.description}</p>
                    </div>
                ))}
            </div>
        </div>
    );
}
