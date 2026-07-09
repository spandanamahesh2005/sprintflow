'use client';
import Link from 'next/link';
import { ArrowLeft, Trophy, Medal, Crown } from 'lucide-react';
import { Button } from '@/components/ui/button';

export default function LeaderboardPage() {
    const leaders = [
        { rank: 1, name: "Agile Master X", xp: 15400, level: 24, badge: "Grandmaster" },
        { rank: 2, name: "ScrumWizard", xp: 14200, level: 22, badge: "Master" },
        { rank: 3, name: "SprointBooster", xp: 12800, level: 19, badge: "Expert" },
        { rank: 4, name: "BacklogHero", xp: 9500, level: 15, badge: "Practitioner" },
        { rank: 5, name: "DailyStandup", xp: 8200, level: 12, badge: "Practitioner" },
    ];

    return (
        <div className="min-h-screen bg-slate-950 text-slate-100 p-8 bg-[url('/grid-pattern.svg')]">
            <div className="max-w-4xl mx-auto">
                <div className="flex items-center gap-4 mb-12">
                    <Link href="/">
                        <Button variant="outline"><ArrowLeft className="w-4 h-4 mr-2" /> Back</Button>
                    </Link>
                    <h1 className="text-4xl font-bold flex items-center gap-3">
                        <Trophy className="w-10 h-10 text-amber-400" /> Global Leaderboard
                    </h1>
                </div>

                <div className="glass-card rounded-2xl overflow-hidden border border-slate-700/50">
                    <div className="grid grid-cols-12 gap-4 p-6 border-b border-slate-700/50 bg-slate-900/50 font-bold text-slate-400 uppercase text-sm">
                        <div className="col-span-2 text-center">Rank</div>
                        <div className="col-span-5">User</div>
                        <div className="col-span-3 text-right">XP</div>
                        <div className="col-span-2 text-right">Level</div>
                    </div>

                    {leaders.map((leader, i) => (
                        <div key={i} className="grid grid-cols-12 gap-4 p-6 border-b border-slate-800 hover:bg-indigo-500/5 transition-colors items-center group">
                            <div className="col-span-2 flex justify-center">
                                {leader.rank === 1 && <Crown className="w-6 h-6 text-amber-400" />}
                                {leader.rank === 2 && <Medal className="w-6 h-6 text-slate-400" />}
                                {leader.rank === 3 && <Medal className="w-6 h-6 text-orange-400" />}
                                {leader.rank > 3 && <span className="font-mono font-bold text-slate-500">#{leader.rank}</span>}
                            </div>
                            <div className="col-span-5 flex items-center gap-3">
                                <div className="w-10 h-10 rounded-full bg-slate-800 flex items-center justify-center font-bold text-indigo-400 border border-slate-700">
                                    {leader.name[0]}
                                </div>
                                <div>
                                    <div className="font-bold group-hover:text-indigo-400 transition-colors">{leader.name}</div>
                                    <div className="text-xs text-slate-500">{leader.badge}</div>
                                </div>
                            </div>
                            <div className="col-span-3 text-right font-mono font-bold text-slate-300">
                                {leader.xp.toLocaleString()}
                            </div>
                            <div className="col-span-2 text-right">
                                <span className="px-3 py-1 bg-slate-800 rounded-full text-xs font-bold text-emerald-400">
                                    Lvl {leader.level}
                                </span>
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}
