import Link from 'next/link'
import { ArrowRight, Trophy, Users, BarChart3 } from 'lucide-react'

export default function Home() {
    return (
        <main className="flex min-h-screen flex-col items-center justify-center p-24 bg-[url('/grid-pattern.svg')] bg-fixed">
            <div className="z-10 max-w-5xl w-full items-center justify-between text-sm flex-col lg:flex">

                {/* Hero Section */}
                <div className="text-center mb-24 relative">
                    <div className="absolute -top-20 left-1/2 -translate-x-1/2 w-96 h-96 bg-indigo-500/20 rounded-full blur-3xl -z-10"></div>
                    <h1 className="text-6xl font-black tracking-tight mb-6 bg-gradient-to-r from-indigo-400 to-cyan-400 bg-clip-text text-transparent">
                        Agile Sprint Master
                    </h1>
                    <p className="text-xl text-slate-400 mb-10 max-w-2xl mx-auto">
                        Experience the chaos and triumph of Agile delivery. Simulate sprints, manage backlogs, and earn XP as you master Scrum methodology.
                    </p>

                    <div className="flex gap-6 justify-center">
                        <Link href="/login" className="px-8 py-4 bg-indigo-600 hover:bg-indigo-500 text-white rounded-xl font-bold transition-all shadow-lg shadow-indigo-500/20 flex items-center gap-2">
                            Start Simulation <ArrowRight className="w-5 h-5" />
                        </Link>
                        <Link href="/leaderboard" className="px-8 py-4 bg-slate-800 hover:bg-slate-700 text-white rounded-xl font-bold transition-all border border-slate-700 flex items-center gap-2">
                            View Leaderboard <Trophy className="w-5 h-5 text-amber-400" />
                        </Link>
                    </div>
                </div>

                {/* Features Grid */}
                <div className="grid grid-cols-1 md:grid-cols-3 gap-8 w-full">
                    <div className="glass-card p-8 rounded-2xl hover:-translate-y-2 transition-transform duration-300">
                        <div className="w-12 h-12 bg-indigo-500/20 rounded-lg flex items-center justify-center mb-6">
                            <Users className="w-6 h-6 text-indigo-400" />
                        </div>
                        <h3 className="text-xl font-bold mb-3">Role-Playing</h3>
                        <p className="text-slate-400">Step into the shoes of a Product Owner, Scrum Master, or Developer. Make decisions that impact the entire team.</p>
                    </div>

                    <div className="glass-card p-8 rounded-2xl hover:-translate-y-2 transition-transform duration-300">
                        <div className="w-12 h-12 bg-emerald-500/20 rounded-lg flex items-center justify-center mb-6">
                            <BarChart3 className="w-6 h-6 text-emerald-400" />
                        </div>
                        <h3 className="text-xl font-bold mb-3">Real Analytics</h3>
                        <p className="text-slate-400">Track Velocity, Burndown, and Cumulative Flow. Learn to spot bottlenecks before they crash your sprint.</p>
                    </div>

                    <div className="glass-card p-8 rounded-2xl hover:-translate-y-2 transition-transform duration-300">
                        <div className="w-12 h-12 bg-amber-500/20 rounded-lg flex items-center justify-center mb-6">
                            <Trophy className="w-6 h-6 text-amber-400" />
                        </div>
                        <h3 className="text-xl font-bold mb-3">Gamified Learning</h3>
                        <p className="text-slate-400">Earn XP, unlock achievements, and climb the global leaderboard. Learning Agile has never been this addictive.</p>
                    </div>
                </div>

            </div>
        </main>
    )
}
