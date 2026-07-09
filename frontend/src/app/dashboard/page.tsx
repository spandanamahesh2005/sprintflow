'use client';
import { useEffect, useState } from 'react';
import Link from 'next/link';
import { ArrowRight, FolderGit2 } from 'lucide-react';
import api from '@/lib/api';

export default function DashboardPage() {
    const [projects, setProjects] = useState<any[]>([]);
    const [profile, setProfile] = useState<any>(null);

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            const [projectsRes, profileRes] = await Promise.all([
                api.get('/projects'),
                api.get('/users/profile')
            ]);
            setProjects(projectsRes.data);
            setProfile(profileRes.data);
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    };

    return (
        <div className="space-y-8">
            <div>
                <h1 className="text-3xl font-bold mb-2">Dashboard</h1>
                <p className="text-slate-400">Welcome back, {profile?.name || 'Recruit'}. Ready for your next sprint?</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
                <div className="glass-card p-6 rounded-2xl">
                    <h3 className="text-slate-400 text-sm font-medium mb-2">Current Level</h3>
                    <div className="flex items-end gap-3">
                        <span className="text-4xl font-bold">{profile?.level || 1}</span>
                        <span className="text-emerald-400 text-sm mb-1">
                            {profile?.level >= 10 ? 'Expert' : profile?.level >= 5 ? 'Apprentice' : 'Beginner'}
                        </span>
                    </div>
                    <div className="mt-4 h-2 bg-slate-800 rounded-full overflow-hidden">
                        <div className="h-full bg-indigo-500 rounded-full" style={{ width: `${((profile?.xp || 0) % 100)}%` }}></div>
                    </div>
                    <p className="text-xs text-right mt-1 text-slate-500">{profile?.xp || 0} XP</p>
                </div>

                <div className="glass-card p-6 rounded-2xl">
                    <h3 className="text-slate-400 text-sm font-medium mb-2">Active Projects</h3>
                    <div className="text-4xl font-bold">{projects.length}</div>
                    <p className="text-xs text-slate-500 mt-2">Total projects</p>
                </div>

                <div className="glass-card p-6 rounded-2xl">
                    <h3 className="text-slate-400 text-sm font-medium mb-2">Achievements</h3>
                    <div className="text-4xl font-bold">{profile?.badges?.length || 0}</div>
                    <p className="text-xs text-emerald-400 mt-2">Badges earned</p>
                </div>
            </div>

            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <div className="glass-card p-6 rounded-2xl">
                    <div className="flex justify-between items-center mb-4">
                        <h3 className="font-bold">Active Projects</h3>
                        <Link href="/dashboard/projects" className="text-sm text-indigo-400 hover:text-indigo-300">
                            View All
                        </Link>
                    </div>
                    <div className="space-y-4">
                        {projects.length === 0 ? (
                            <div className="text-center py-8 text-slate-500">
                                <FolderGit2 className="w-12 h-12 mx-auto mb-3 opacity-50" />
                                <p>No projects yet</p>
                                <Link href="/dashboard/projects" className="text-indigo-400 hover:text-indigo-300 text-sm mt-2 inline-block">
                                    Create your first project
                                </Link>
                            </div>
                        ) : (
                            projects.slice(0, 3).map((project) => (
                                <Link key={project._id} href={`/dashboard/projects/${project._id}`}>
                                    <div className="p-4 bg-slate-800/50 rounded-xl border border-slate-700/50 flex justify-between items-center group hover:border-indigo-500/50 transition-all cursor-pointer">
                                        <div>
                                            <h4 className="font-semibold group-hover:text-indigo-400 transition-colors">{project.name}</h4>
                                            <p className="text-sm text-slate-400">Sprint {project.currentSprintNumber} • {project.description || 'No description'}</p>
                                        </div>
                                        <div className="w-10 h-10 rounded-full bg-slate-700 flex items-center justify-center group-hover:bg-indigo-600 transition-colors">
                                            <ArrowRight className="w-5 h-5" />
                                        </div>
                                    </div>
                                </Link>
                            ))
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}
