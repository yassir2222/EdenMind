import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { tap } from 'rxjs';

export interface MoodLog {
    id?: string;
    emotionType: string;
    activities: string; // comma separated or text
    note: string;
    recordedAt?: string; // ISO date from backend
}

@Injectable({
    providedIn: 'root'
})
export class MoodService {
    private http = inject(HttpClient);
    moods = signal<MoodLog[]>([]);

    loadMoods() {
        this.http.get<MoodLog[]>('/api/emotions').subscribe({
            next: (res) => this.moods.set(res),
            error: (err) => console.error('Error loading moods', err)
        });
    }

    logMood(mood: MoodLog) {
        return this.http.post<MoodLog>('/api/emotions', mood).pipe(
            tap(() => {
                this.loadMoods();
            })
        );
    }
}
