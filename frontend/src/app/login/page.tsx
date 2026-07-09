'use client';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import api from '@/lib/api';

export default function LoginPage() {
    const router = useRouter();
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [loading, setLoading] = useState(false);

    async function handleLogin(e: React.FormEvent) {
        e.preventDefault();
        setLoading(true);
        try {
            const res = await api.post('/auth/login', { email, password });
            localStorage.setItem('token', res.data.access_token);
            localStorage.setItem('user', JSON.stringify(res.data.user));
            router.push('/dashboard');
        } catch (err: any) {
            console.error(err);
            const message = err.response?.data?.message || 'Login failed. Please check your credentials or if the backend is running.';
            alert(message);
        } finally {
            setLoading(false);
        }
    }

    return (
        <div className="min-h-screen flex items-center justify-center bg-slate-950 bg-[url('/grid-pattern.svg')]">
            <div className="glass-card p-8 rounded-2xl w-full max-w-md">
                <h2 className="text-2xl font-bold mb-6 text-center bg-gradient-to-r from-indigo-400 to-cyan-400 bg-clip-text text-transparent">Welcome Back</h2>
                <form onSubmit={handleLogin} className="space-y-4">
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
                    <Button type="submit" className="w-full mt-4" disabled={loading}>
                        {loading ? 'Logging in...' : 'Sign In'}
                    </Button>
                </form>
                <p className="mt-6 text-center text-sm text-slate-500">
                    Don&apos;t have an account? <Link href="/register" className="text-indigo-400 hover:underline">Sign up</Link>
                </p>
            </div>
        </div>
    );
}
