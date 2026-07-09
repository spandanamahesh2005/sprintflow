'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import api from '@/lib/api';

export default function RegisterPage() {
    const router = useRouter();
    const [name, setName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    async function handleRegister(e: React.FormEvent) {
        e.preventDefault();
        setLoading(true);
        try {
            const res = await api.post('/auth/register', { name, email, password });
            localStorage.setItem('token', res.data.access_token);
            localStorage.setItem('user', JSON.stringify(res.data.user));
            router.push('/dashboard');
        } catch (err) {
            alert('Registration failed');
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-slate-950 bg-[url('/grid-pattern.svg')]">
            <div className="glass-card p-8 rounded-2xl w-full max-w-md">
                <h2 className="text-2xl font-bold mb-6 text-center bg-gradient-to-r from-emerald-400 to-cyan-400 bg-clip-text text-transparent">Create Account</h2>
                <form onSubmit={handleRegister} className="space-y-4">
                    <Input
                        label="Full Name"
                        value={name}
                        onChange={(e) => setName(e.target.value)}
                        required
                    />
                    <Input
                        label="Email"
                        type="email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                    <Input
                        label="Password"
                        type="password"
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        required
                    />
                    <Button type="submit" variant="secondary" className="w-full mt-4" disabled={loading}>
                        {loading ? 'Creating...' : 'Start Simulation'}
                    </Button>
                </form>
                <p className="mt-6 text-center text-sm text-slate-500">
                    Already have an account? <Link href="/login" className="text-emerald-400 hover:underline">Sign in</Link>
                </p>
            </div>
        </div>
    );
}
