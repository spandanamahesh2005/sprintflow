import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
    title: 'Agile Sprint Sim',
    description: 'Gamified Agile Training Platform',
}

export default function RootLayout({
    children,
}: {
    children: React.ReactNode
}) {
    return (
        <html lang="en">
            <body className={`${inter.className} min-h-screen bg-slate-900 text-slate-100 selection:bg-indigo-500 selection:text-white`}>
                {children}
            </body>
        </html>
    )
}
