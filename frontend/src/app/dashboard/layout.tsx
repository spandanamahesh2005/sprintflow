'use client';
import { LayoutDashboard, Users, Kanban, Trophy, Settings, LogOut } from 'lucide-react';
import Link from 'next/link';
import { usePathname } from 'next/navigation';

const sidebarItems = [
    { icon: LayoutDashboard, label: 'Overview', href: '/dashboard' },
    { icon: Kanban, label: 'Projects', href: '/dashboard/projects' },
    { icon: Users, label: 'Team', href: '/dashboard/team' },
    { icon: Trophy, label: 'Achievements', href: '/dashboard/achievements' },
    { icon: Settings, label: 'Settings', href: '/dashboard/settings' },
];

export default function DashboardLayout({ children }: { children: React.ReactNode }) {
    const pathname = usePathname();

    return (
        <div className="flex h-screen bg-slate-950 text-slate-100 overflow-hidden">
            {/* Sidebar */}
            <aside className="w-64 glass-panel flex flex-col p-6">
                <div className="flex items-center gap-3 mb-10 px-2">
                    <div className="w-8 h-8 rounded-lg bg-indigo-600 flex items-center justify-center font-bold">A</div>
                    <span className="font-bold text-lg">AgileSim</span>
                </div>

                <nav className="flex-1 space-y-2">
                    {sidebarItems.map((item) => {
                        const isActive = pathname === item.href;
                        return (
                            <Link
                                key={item.href}
                                href={item.href}
                                className={`flex items-center gap-3 px-4 py-3 rounded-xl transition-all ${isActive
                                        ? 'bg-indigo-600 text-white shadow-lg shadow-indigo-500/20'
                                        : 'text-slate-400 hover:bg-slate-800/50 hover:text-white'
                                    }`}
                            >
                                <item.icon className="w-5 h-5" />
                                <span className="font-medium">{item.label}</span>
                            </Link>
                        );
                    })}
                </nav>

                <div className="pt-6 border-t border-slate-800 space-y-2">
                    <button onClick={() => { localStorage.clear(); window.location.href = '/login' }} className="flex items-center gap-3 px-4 py-3 rounded-xl w-full text-red-400 hover:bg-red-500/10 transition-all">
                        <LogOut className="w-5 h-5" />
                        <span className="font-medium">Logout</span>
                    </button>
                </div>
            </aside>

            {/* Main Content */}
            <main className="flex-1 overflow-y-auto p-8 relative">
                <div className="absolute inset-0 bg-[url('/grid-pattern.svg')] opacity-20 pointer-events-none"></div>
                {children}
            </main>
        </div>
    );
}
