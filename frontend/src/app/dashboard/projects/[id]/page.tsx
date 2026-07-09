'use client';
import { useCallback, useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { Plus, Play, Circle } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import api from '@/lib/api';

export default function ProjectDetailPage() {
    const params = useParams();
    const [tasks, setTasks] = useState<any[]>([]);
    const [project, setProject] = useState<any>(null);
    const [newTaskTitle, setNewTaskTitle] = useState('');

    const fetchProject = useCallback(async () => {
        if (!params.id) return;

        const res = await api.get(`/projects/${params.id}`);
        setProject(res.data);
    }, [params.id]);

    const fetchBacklog = useCallback(async () => {
        if (!params.id) return;

        const res = await api.get(`/tasks/backlog?projectId=${params.id}`);
        setTasks(res.data);
    }, [params.id]);

    useEffect(() => {
        if (params.id) {
            fetchProject();
            fetchBacklog();
        }
    }, [params.id, fetchProject, fetchBacklog]);

    async function addTask(e: React.FormEvent) {
        e.preventDefault();
        if (!newTaskTitle) return;
        await api.post('/tasks', {
            title: newTaskTitle,
            projectId: params.id,
            storyPoints: 0,
            type: 'FEATURE'
        });
        setNewTaskTitle('');
        fetchBacklog();
    }

    return (
        <div className="space-y-6 h-[calc(100vh-8rem)] flex flex-col">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold">{project?.name}</h1>
                    <p className="text-slate-400">Product Backlog</p>
                </div>
                <Button variant="secondary">
                    <Play className="w-4 h-4" /> Plan Sprint
                </Button>
            </div>

            {/* Backlog Area */}
            <div className="glass-card flex-1 rounded-2xl p-6 flex flex-col">
                <form onSubmit={addTask} className="flex gap-4 mb-6">
                    <Input
                        className="flex-1"
                        placeholder="Add a new user story..."
                        value={newTaskTitle}
                        onChange={(e) => setNewTaskTitle(e.target.value)}
                    />
                    <Button type="submit" variant="outline"><Plus className="w-5 h-5" /></Button>
                </form>

                <div className="space-y-3 overflow-y-auto pr-2">
                    {tasks.map((task) => (
                        <div key={task._id} className="p-4 bg-slate-800/50 border border-slate-700/50 rounded-xl hover:border-indigo-500/50 transition-all cursor-move flex items-center justify-between group">
                            <div className="flex items-center gap-4">
                                <Circle className={`w-4 h-4 ${task.type === 'BUG' ? 'text-red-400' : 'text-emerald-400'}`} />
                                <span className="font-medium">{task.title}</span>
                            </div>
                            <div className="flex items-center gap-4 opacity-50 group-hover:opacity-100 transition-opacity">
                                <span className="text-sm px-2 py-1 bg-slate-700 rounded text-slate-300">
                                    {task.storyPoints || '-'} pts
                                </span>
                                <span className="text-xs font-mono uppercase text-slate-500">{task._id.slice(-4)}</span>
                            </div>
                        </div>
                    ))}
                    {tasks.length === 0 && (
                        <div className="text-center py-12 text-slate-600 border-2 border-dashed border-slate-800 rounded-xl">
                            Backlog is empty. Add some stories!
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
