'use client';
import { useState, useEffect } from 'react';
import { User, Mail, Shield, Save } from 'lucide-react';
import { Button } from '@/components/ui/button';
import api from '@/lib/api';

export default function SettingsPage() {
    const [profile, setProfile] = useState<any>(null);
    const [formData, setFormData] = useState({
        name: '',
        email: '',
        currentPassword: '',
        newPassword: '',
        confirmPassword: '',
    });
    const [loading, setLoading] = useState(false);
    const [message, setMessage] = useState('');

    useEffect(() => {
        fetchProfile();
    }, []);

    const fetchProfile = async () => {
        try {
            const response = await api.get('/users/profile');
            setProfile(response.data);
            setFormData({
                name: response.data.name || '',
                email: response.data.email || '',
                currentPassword: '',
                newPassword: '',
                confirmPassword: '',
            });
        } catch (error) {
            console.error('Error fetching profile:', error);
        }
    };

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setMessage('');

        if (formData.newPassword && formData.newPassword !== formData.confirmPassword) {
            setMessage('Passwords do not match');
            setLoading(false);
            return;
        }

        try {
            await api.put('/users/profile', {
                name: formData.name,
                currentPassword: formData.currentPassword || undefined,
                newPassword: formData.newPassword || undefined,
            });
            setMessage('Profile updated successfully!');
            setFormData({ ...formData, currentPassword: '', newPassword: '', confirmPassword: '' });
            fetchProfile();
        } catch (error: any) {
            setMessage(error.response?.data?.message || 'Failed to update profile');
        } finally {
            setLoading(false);
        }
    };

    if (!profile) {
        return <div className="text-center py-12">Loading...</div>;
    }

    return (
        <div className="space-y-6 max-w-2xl">
            <div>
                <h1 className="text-3xl font-bold">Settings</h1>
                <p className="text-slate-400">Manage your account settings and preferences.</p>
            </div>

            <div className="glass-card p-6 rounded-2xl">
                <div className="flex items-center gap-4 mb-6">
                    <div className="w-16 h-16 rounded-full bg-indigo-600 flex items-center justify-center text-2xl font-bold">
                        {profile?.name?.[0]?.toUpperCase() || 'U'}
                    </div>
                    <div>
                        <h2 className="text-xl font-bold">{profile?.name || 'User'}</h2>
                        <p className="text-slate-400 flex items-center gap-2">
                            <Shield className="w-4 h-4" /> {profile?.role || 'STUDENT'}
                        </p>
                    </div>
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
                            className="w-full px-4 py-2 bg-slate-800/30 border border-slate-700 rounded-lg cursor-not-allowed"
                            disabled
                        />
                        <p className="text-xs text-slate-500 mt-1">Email cannot be changed</p>
                    </div>

                    <div className="pt-4 border-t border-slate-700">
                        <h3 className="text-lg font-bold mb-4">Change Password</h3>

                        <div className="space-y-4">
                            <div>
                                <label className="block text-sm font-medium mb-2">Current Password</label>
                                <input
                                    type="password"
                                    value={formData.currentPassword}
                                    onChange={(e) => setFormData({ ...formData, currentPassword: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">New Password</label>
                                <input
                                    type="password"
                                    value={formData.newPassword}
                                    onChange={(e) => setFormData({ ...formData, newPassword: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                />
                            </div>

                            <div>
                                <label className="block text-sm font-medium mb-2">Confirm New Password</label>
                                <input
                                    type="password"
                                    value={formData.confirmPassword}
                                    onChange={(e) => setFormData({ ...formData, confirmPassword: e.target.value })}
                                    className="w-full px-4 py-2 bg-slate-800/50 border border-slate-700 rounded-lg focus:outline-none focus:border-indigo-500"
                                />
                            </div>
                        </div>
                    </div>

                    {message && (
                        <div className={`p-3 rounded-lg ${message.includes('success') ? 'bg-emerald-500/10 text-emerald-400' : 'bg-red-500/10 text-red-400'}`}>
                            {message}
                        </div>
                    )}

                    <Button type="submit" disabled={loading} className="w-full">
                        <Save className="w-5 h-5" />
                        {loading ? 'Saving...' : 'Save Changes'}
                    </Button>
                </form>
            </div>
        </div>
    );
}
