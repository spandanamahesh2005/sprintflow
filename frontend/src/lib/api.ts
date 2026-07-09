import axios from 'axios';

const api = axios.create({
    baseURL: 'http://localhost:3001',
});

api.interceptors.request.use((config) => {
    if (typeof window === 'undefined') {
        return config;
    }

    const token = localStorage.getItem('token');
    if (token) {
        config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
});

api.interceptors.response.use(
    (response) => response,
    (error) => {
        if (typeof window !== 'undefined' && error?.response?.status === 401) {
            localStorage.removeItem('token');
            localStorage.removeItem('user');

            const currentPath = window.location.pathname;
            const isAuthPage = currentPath === '/login' || currentPath === '/register';
            if (!isAuthPage) {
                window.location.href = '/login';
            }
        }

        return Promise.reject(error);
    }
);

export default api;
