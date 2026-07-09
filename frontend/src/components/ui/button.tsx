import { ButtonHTMLAttributes, forwardRef } from 'react';
import { clsx, type ClassValue } from 'clsx';
import { twMerge } from 'tailwind-merge';

function cn(...inputs: ClassValue[]) {
    return twMerge(clsx(inputs));
}

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
    variant?: 'primary' | 'secondary' | 'outline' | 'ghost';
    size?: 'sm' | 'md' | 'lg';
}

const Button = forwardRef<HTMLButtonElement, ButtonProps>(
    ({ className, variant = 'primary', size = 'md', ...props }, ref) => {
        const variants = {
            primary: 'bg-indigo-600 text-white hover:bg-indigo-500 shadow-lg shadow-indigo-500/20',
            secondary: 'bg-emerald-600 text-white hover:bg-emerald-500 shadow-lg shadow-emerald-500/20',
            outline: 'border-2 border-slate-600 hover:bg-slate-800 text-slate-200',
            ghost: 'hover:bg-slate-800 text-slate-300 hover:text-white',
        };

        const sizes = {
            sm: 'px-3 py-1.5 text-sm',
            md: 'px-6 py-2.5',
            lg: 'px-8 py-3.5 text-lg',
        };

        return (
            <button
                ref={ref}
                className={cn(
                    'rounded-xl font-semibold transition-all duration-200 active:scale-95 disabled:opacity-50 disabled:pointer-events-none flex items-center justify-center gap-2',
                    variants[variant],
                    sizes[size],
                    className
                )}
                {...props}
            />
        );
    }
);
Button.displayName = 'Button';

export { Button };
