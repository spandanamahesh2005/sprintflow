'use client';
import { useState, useEffect } from 'react';
import { Users, UserPlus, Mail, Shield, X } from 'lucide-react';
import { Button } from '@/components/ui/button';
import api from '@/lib/api';

export default function TeamPage() {
    const [team, setTeam] = useState<any[]>([]);
    const [showModal, setShowModal] = useState(false);
    const [loading, setLoading] = useState(false);
    const [errorMessage, setErrorMessage] = useState('');
    const [successMessage, setSuccessMessage] = useState('');
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        password: '',
        role: 'STUDENT',
    });

    useEffect(() => {
        fetchTeam();
    }, []);

    const fetchTeam = async () => {
        try {
            setErrorMessage('');
            setSuccessMessage('');
            const response = await api.get('/users');
            setTeam(Array.isArray(response.data) ? response.data : []);
        } catch (error: any) {
            console.error('Error fetching team:', error);
            const message = Array.isArray(error?.response?.data?.message)
                ? error.response.data.message.join(', ')
                : error?.response?.data?.message || 'Failed to load team members';
            setErrorMessage(message);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setErrorMessage('');
        setSuccessMessage('');

        const token = localStorage.getItem('token');
        if (!token) {
            setErrorMessage('Your session expired. Please sign in again.');
            window.location.href = '/login';
            return;
        }

        setLoading(true);

        try {
            await api.post('/users', {
                ...formData,
                name: formData.name.trim(),
                email: formData.email.trim().toLowerCase(),
            });
            setShowModal(false);
            setFormData({ name: '', email: '', password: '', role: 'STUDENT' });
            setSuccessMessage('Team member added successfully.');
            await fetchTeam();
        } catch (error: any) {
            const message = Array.isArray(error?.response?.data?.message)
                ? error.response.data.message.join(', ')
                : error?.response?.data?.message || 'Failed to add member';
            setErrorMessage(message);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="space-y-6">
            <div className="flex justify-between items-center">
                <div>
                    <h1 className="text-3xl font-bold">Team Management</h1>
                    <p className="text-slate-400">Manage users and roles in your organization.</p>
                </div>
                <Button onClick={() => setShowModal(true)}>
                    <UserPlus className="w-5 h-5" /> Add Member
                </Button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                {team.map((member) => (
                    <div key={member._id} className="glass-card p-6 rounded-2xl flex items-start gap-4 group hover:border-indigo-500/50 transition-all">
                        <div className="w-12 h-12 rounded-full bg-slate-800 flex items-center justify-center text-xl font-bold text-slate-400 group-hover:bg-indigo-600 group-hover:text-white transition-colors">
                            {String(member?.name || 'U').charAt(0).toUpperCase()}
                        </div>
                        <div className="flex-1">
                            <h3 className="font-bold">{member.name || 'Unknown User'}</h3>
                            <p className="text-sm text-slate-500 flex items-center gap-1.5 mb-3">
                                <Mail className="w-3 h-3" /> {member.email}
                            </p>

                            <div className="flex gap-2">
                                <span className="px-2 py-1 bg-indigo-500/10 text-indigo-400 text-xs rounded-md border border-indigo-500/20 flex items-center gap-1">
                                    <Shield className="w-3 h-3" /> {member.role}
                                </span>
                                <span className="px-2 py-1 text-xs rounded-md border bg-emerald-500/10 text-emerald-400 border-emerald-500/20">
                                    Level {member.level}
                                </span>
                            </div>
                        </div>
                    </div>
                ))}
            </div>

            {errorMessage && (
                <div className="rounded-lg border border-red-500/40 bg-red-500/10 px-4 py-3 text-sm text-red-300">
                    {errorMessage}
                </div>
            )}

            {successMessage && (
                <div className="rounded-lg border border-emerald-500/40 bg-emerald-500/10 px-4 py-3 text-sm text-emerald-300">
                    {successMessage}
                </div>
            )}

            {/* Add Member Modal */}
            {showModal && (
                <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
                    <div className="glass-card p-6 rounded-2xl w-full max-w-md">
                        <div className="flex justify-between items-center mb-6">
                            <h2 className="text-2xl font-bold">Add Team Member</h2>
                            <button onClick={() => setShowModal(false)} className="text-slate-400 hover:text-white">
                                <X className="w-6 h-6" />
                            </button>
                        </div>

                        <form onSubmit={handleSubmit} className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium mb-2">Name</label>
                                <input
                                    type="text"
                                    value={formData.name}
                                    onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                    required
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">Email</label>
                                <input
                                    type="email"
                                    value={formData.email}
                                    onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                    required
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">Password</label>
                                <input
                                    type="password"
                                    value={formData.password}
                                    onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                    required
                                    minLength={6}
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">Role</label>
                                <select
                                    value={formData.role}
                                    onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                >
                                    <option value="STUDENT">Student</option>
                                    <option value="COACH">Coach</option>
                                    <option value="ADMIN">Admin</option>
                                </select>
                            </div>

                            <div className="flex gap-3 pt-4">
                                <Button type="button" onClick={() => setShowModal(false)} className="flex-1 bg-slate-700 hover:bg-slate-600">
                                    Cancel
                                </Button>
                                <Button type="submit" disabled={loading} className="flex-1">
                                    {loading ? 'Adding...' : 'Add Member'}
                                </Button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
