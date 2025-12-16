import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs';

export interface UserProfile {
    id?: string;
    firstName: string;
    lastName: string;
    email: string;
    bio?: string | null;
    familySituation?: string | null;
    workType?: string | null;
    phoneNumber?: string | null;
    birthday?: string | null;
    workHours?: string | null;
    childrenCount?: number | null;
    country?: string | null;
    avatarUrl?: string | null;
}

@Injectable({
    providedIn: 'root'
})
export class UserService {
    private http = inject(HttpClient);
    currentUser = signal<UserProfile | null>(null);

    loadProfile(id: string) {
        this.http.get<UserProfile>(`/api/users/${id}`).subscribe({
            next: (res) => this.currentUser.set(res),
            error: (err) => console.error('Error loading profile', err)
        });
    }

    updateProfile(id: string, data: Partial<UserProfile>) {
        return this.http.put<UserProfile>(`/api/users/${id}`, data).pipe(
            tap(updated => this.currentUser.set(updated))
        );
    }

    getUserIdFromToken(): string | null {
        const token = localStorage.getItem('token');
        if (!token) return null;

        try {
            const decoded = this.decodeToken(token);
            return decoded.id || decoded.sub || null; // Adjust based on your backend token structure
        } catch (e) {
            console.error('Failed to decode token', e);
            return null;
        }
    }

    private decodeToken(token: string): any {
        const payload = token.split('.')[1];
        if (!payload) throw new Error('Invalid token');

        const base64 = payload.replace(/-/g, '+').replace(/_/g, '/');
        const jsonPayload = decodeURIComponent(window.atob(base64).split('').map(function (c) {
            return '%' + ('00' + c.charCodeAt(0).toString(16)).slice(-2);
        }).join(''));

        return JSON.parse(jsonPayload);
    }
}
