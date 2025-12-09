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
}
