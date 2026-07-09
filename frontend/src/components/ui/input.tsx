import { InputHTMLAttributes, forwardRef } from 'react';

interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
    label?: string;
}

const Input = forwardRef<HTMLInputElement, InputProps>(
    ({ className, label, ...props }, ref) => {
        return (
            <div className="flex flex-col gap-1.5">
                {label && <label className="text-sm font-medium text-slate-400">{label}</label>}
                <input
                    ref={ref}
                    className={`px-4 py-2.5 bg-slate-900 border border-slate-700 rounded-xl focus:outline-none focus:ring-2 focus:ring-indigo-500/50 focus:border-indigo-500 transition-all text-slate-100 placeholder:text-slate-600 ${className}`}
                    {...props}
                />
            </div>
        );
    }
);
Input.displayName = 'Input';

export { Input };
