import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { tap } from 'rxjs';

interface AuthResponse {
    token: string;
}

@Injectable({
    providedIn: 'root'
})
export class AuthService {
    private http = inject(HttpClient);
    private router = inject(Router);

    // Signal for logged in state
    isLoggedIn = signal(!!localStorage.getItem('token'));

    login(credentials: { email: string, password: string }) {
        return this.http.post<AuthResponse>('/api/auth/login', credentials).pipe(
            tap(res => {
                localStorage.setItem('token', res.token);
                this.isLoggedIn.set(true);
                this.router.navigate(['/dashboard']);
            })
        );
    }

    register(data: { firstName: string, lastName: string, email: string, password: string }) {
        return this.http.post<AuthResponse>('/api/auth/register', data).pipe(
            tap(res => {
                localStorage.setItem('token', res.token);
                this.isLoggedIn.set(true);
                this.router.navigate(['/dashboard']);
            })
        );
    }

    logout() {
        localStorage.removeItem('token');
        this.isLoggedIn.set(false);
        this.router.navigate(['/login']);
    }
}
