'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { Plus, FolderGit2, ArrowRight } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import api from '@/lib/api';

interface Project {
    _id: string;
    name: string;
    description: string;
    currentSprintNumber: number;
}

export default function ProjectsPage() {
    const [projects, setProjects] = useState<Project[]>([]);
    const [showCreate, setShowCreate] = useState(false);
    const [newProjectName, setNewProjectName] = useState('');
    const [newProjectDesc, setNewProjectDesc] = useState('');

    useEffect(() => {
        fetchProjects();
    }, []);

    async function fetchProjects() {
        try {
            const res = await api.get('/projects');
            setProjects(res.data);
        } catch (err) {
            console.error(err);
        }
    }

    async function createProject(e: React.FormEvent) {
        e.preventDefault();
        try {
            await api.post('/projects', { name: newProjectName, description: newProjectDesc });
            setShowCreate(false);
            setNewProjectName('');
            setNewProjectDesc('');
            fetchProjects();
        } catch (err) {
            alert('Failed to create project');
        }
    }

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-3xl font-bold">Your Projects</h1>
                <Button onClick={() => setShowCreate(!showCreate)}>
                    <Plus className="w-5 h-5" /> New Project
                </Button>
            </div>

            {showCreate && (
                <div className="glass-card p-6 rounded-2xl animate-in slide-in-from-top-4">
                    <form onSubmit={createProject} className="flex gap-4 items-end">
                        <div className="flex-1">
                            <Input
                                placeholder="Project Name"
                                value={newProjectName}
                                onChange={(e) => setNewProjectName(e.target.value)}
                                required
                            />
                        </div>
                        <div className="flex-1">
                            <Input
                                placeholder="Description"
                                value={newProjectDesc}
                                onChange={(e) => setNewProjectDesc(e.target.value)}
                            />
                        </div>
                        <Button type="submit">Create</Button>
                    </form>
                </div>
            )}

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {projects.map((project) => (
                    <div key={project._id} className="glass-card p-6 rounded-2xl group hover:border-indigo-500/50 transition-all">
                        <div className="flex justify-between items-start mb-4">
                            <div className="w-12 h-12 bg-slate-800 rounded-lg flex items-center justify-center">
                                <FolderGit2 className="w-6 h-6 text-indigo-400" />
                            </div>
                            <span className="px-3 py-1 bg-slate-800 rounded-full text-xs font-medium text-slate-400">
                                Sprint {project.currentSprintNumber}
                            </span>
                        </div>
                        <h3 className="text-xl font-bold mb-2">{project.name}</h3>
                        <p className="text-slate-400 text-sm mb-6 line-clamp-2">{project.description || 'No description'}</p>

                        <Link href={`/dashboard/projects/${project._id}`}>
                            <Button variant="outline" className="w-full group-hover:bg-indigo-600 group-hover:border-indigo-600 group-hover:text-white">
                                Open Board <ArrowRight className="w-4 h-4" />
                            </Button>
                        </Link>
                    </div>
                ))}
                {projects.length === 0 && !showCreate && (
                    <div className="col-span-full text-center py-20 text-slate-500">
                        No projects found. Create one to get started!
                    </div>
                )}
            </div>
        </div>
    );
}
