'use client';
import { useCallback, useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { Play, FastForward, CheckCircle2, AlertTriangle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import api from '@/lib/api';

export default function SprintBoardPage() {
    const params = useParams();
    const [sprint, setSprint] = useState<any>(null);
    const [tasks, setTasks] = useState<any[]>([]);
    const [currentEvent, setCurrentEvent] = useState<any>(null);

    const fetchSprintData = useCallback(async () => {
        if (!params.id) return;

        // In a real app we'd fetch the sprint details and its tasks
        // For now we assume we can fetch by sprint ID
        // const sprintRes = await api.get(`/sprints/${params.id}`);
        // setSprint(sprintRes.data);
        const tasksRes = await api.get(`/tasks/sprint/${params.id}`);
        setTasks(tasksRes.data);
    }, [params.id]);

    useEffect(() => {
        fetchSprintData();
    }, [fetchSprintData]);

    async function advanceDay() {
        // Simulate advancing day
        // const res = await api.post('/simulation/advance', { sprintId: params.id });
        // setSprint(res.data.sprint);
        // if(res.data.event) setCurrentEvent(res.data.event);
        alert('Simulating day advance... (Backend logic to be connected)');
    }

    const columns = {
        TODO: tasks.filter(t => t.status === 'TODO'),
        IN_PROGRESS: tasks.filter(t => t.status === 'IN_PROGRESS'),
        REVIEW: tasks.filter(t => t.status === 'REVIEW'),
        DONE: tasks.filter(t => t.status === 'DONE'),
    };

    return (
        <div className="h-[calc(100vh-8rem)] flex flex-col space-y-6">
            <div className="flex justify-between items-center bg-slate-900/50 p-4 rounded-2xl border border-slate-800">
                <div>
                    <h1 className="text-2xl font-bold flex items-center gap-3">
                        Sprint {sprint?.number || 1}
                        <span className="text-sm px-2 py-1 bg-emerald-500/20 text-emerald-400 rounded-lg">Active</span>
                    </h1>
                    <p className="text-slate-400 text-sm">Validating core user flows</p>
                </div>

                <div className="flex items-center gap-6">
                    <div className="text-center">
                        <div className="text-xs text-slate-500 uppercase font-bold">Day</div>
                        <div className="text-2xl font-bold font-mono">3<span className="text-slate-600">/10</span></div>
                    </div>
                    <div className="h-10 w-px bg-slate-800"></div>
                    <Button onClick={advanceDay} className="bg-indigo-600 hover:bg-indigo-500">
                        <FastForward className="w-5 h-5" /> Next Day
                    </Button>
                </div>
            </div>

            {/* Board */}
            <div className="flex-1 grid grid-cols-4 gap-6 overflow-hidden">
                {(Object.entries(columns) as [string, any[]][]).map(([status, items]) => (
                    <div key={status} className="flex flex-col bg-slate-900/30 rounded-2xl border border-slate-800/50">
                        <div className="p-4 border-b border-slate-800/50 flex justify-between items-center">
                            <h3 className="font-bold text-slate-300">{status.replace('_', ' ')}</h3>
                            <span className="text-xs bg-slate-800 px-2 py-1 rounded-full text-slate-400">{items.length}</span>
                        </div>
                        <div className="flex-1 p-3 space-y-3 overflow-y-auto">
                            {items.map((task) => (
                                <div key={task._id} className="p-4 bg-slate-800 rounded-xl shadow-lg border border-slate-700/50 hover:border-indigo-500/50 transition-all cursor-pointer group">
                                    <p className="text-sm font-medium mb-3">{task.title}</p>
                                    <div className="flex justify-between items-center">
                                        <span className="text-xs px-1.5 py-0.5 bg-slate-700 rounded text-slate-400">{task.storyPoints} pts</span>
                                        <div className="w-6 h-6 rounded-full bg-indigo-500 text-xs flex items-center justify-center text-white">
                                            JD
                                        </div>
                                    </div>
                                </div>
                            ))}
                            {items.length === 0 && (
                                <div className="h-full flex items-center justify-center text-slate-700 text-sm italic">
                                    No tasks
                                </div>
                            )}
                        </div>
                    </div>
                ))}
            </div>

            {/* Event Modal Overlay (Demo) */}
            {currentEvent && (
                <div className="fixed inset-0 bg-black/80 backdrop-blur-sm z-50 flex items-center justify-center p-4">
                    <div className="bg-slate-900 border border-slate-700 w-full max-w-lg rounded-2xl p-8 shadow-2xl relative overflow-hidden">
                        <div className="absolute top-0 left-0 w-full h-1 bg-amber-500"></div>
                        <div className="w-16 h-16 bg-amber-500/20 rounded-2xl flex items-center justify-center mb-6 text-amber-500">
                            <AlertTriangle className="w-8 h-8" />
                        </div>
                        <h2 className="text-2xl font-bold mb-2">Unexpected Server Outage</h2>
                        <p className="text-slate-400 mb-8">
                            The main production database is experiencing high latency. The team is blocked.
                        </p>
                        <div className="grid grid-cols-1 gap-3">
                            <Button variant="outline" className="justify-start h-auto py-4 px-6 border-slate-700 hover:bg-slate-800 hover:border-amber-500/50">
                                <div className="text-left">
                                    <div className="font-bold text-slate-200">Investigate Immediately</div>
                                    <div className="text-xs text-slate-500 mt-1">-5 Team Velocity, +10 XP (DevOps)</div>
                                </div>
                            </Button>
                            <Button variant="outline" className="justify-start h-auto py-4 px-6 border-slate-700 hover:bg-slate-800 hover:border-amber-500/50">
                                <div className="text-left">
                                    <div className="font-bold text-slate-200">Wait it out</div>
                                    <div className="text-xs text-slate-500 mt-1">-1 Day, No XP</div>
                                </div>
                            </Button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
}
