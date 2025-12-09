import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { MoodService, MoodLog } from '../../../core/services/mood.service';

@Component({
    selector: 'app-mood-tracker',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule],
    template: `
    <div class="h-full flex flex-col gap-6 max-w-5xl mx-auto">
      <div class="flex justify-between items-center">
          <div>
            <h2 class="text-3xl font-bold text-gray-800">Mood Tracker</h2>
            <p class="text-gray-500">Track your emotional journey</p>
          </div>
        
        <button (click)="isLogging = !isLogging" class="bg-eden-secondary text-white px-6 py-3 rounded-xl font-bold shadow-lg hover:bg-green-600 transition transform hover:-translate-y-0.5">
          {{ isLogging ? 'Cancel' : '+ Log Mood' }}
        </button>
      </div>

      <!-- Log Mood Form -->
      @if (isLogging) {
        <div class="bg-white p-8 rounded-3xl shadow-lg border border-gray-100 animate-fade-in-down">
           <form [formGroup]="moodForm" (ngSubmit)="onSubmit()" class="flex flex-col gap-6">
             <div>
               <label class="block text-sm font-bold text-gray-700 mb-3">How do you feel right now?</label>
               <div class="flex flex-wrap gap-3">
                 @for (emotion of emotions; track emotion) {
                    <button type="button" 
                            (click)="selectEmotion(emotion)"
                            [class.bg-eden-primary]="moodForm.get('emotionType')?.value === emotion"
                            [class.text-white]="moodForm.get('emotionType')?.value === emotion"
                            [class.shadow-md]="moodForm.get('emotionType')?.value === emotion"
                            [class.bg-gray-50]="moodForm.get('emotionType')?.value !== emotion"
                            class="px-5 py-2 rounded-full transition-all duration-200 text-sm font-medium hover:bg-eden-soothing hover:text-eden-primary border border-transparent">
                       {{ emotion }}
                    </button>
                 }
               </div>
             </div>

             <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Activities</label>
                    <input formControlName="activities" type="text" class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition" placeholder="e.g. Working, Exercising, Sleeping">
                </div>

                <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Note (Optional)</label>
                    <input formControlName="note" type="text" class="w-full px-4 py-3 rounded-xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition" placeholder="Any thoughts...">
                </div>
             </div>

             <div class="flex justify-end">
                <button type="submit" [disabled]="moodForm.invalid" class="bg-eden-primary text-white py-3 px-10 rounded-xl font-bold shadow-md hover:bg-teal-600 transition disabled:opacity-50">Save Entry</button>
             </div>
           </form>
        </div>
      }

      <!-- History -->
      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6 overflow-y-auto pb-10">
        @if (moodService.moods().length === 0) {
            <div class="col-span-full flex flex-col items-center justify-center p-10 text-gray-400">
                <p>No mood logs yet. Start tracking today!</p>
            </div>
        }
        @for (log of moodService.moods(); track log.id) {
           <div class="bg-white p-6 rounded-3xl shadow-sm border border-gray-50 hover:shadow-lg transition-all duration-300 transform hover:-translate-y-1 group">
              <div class="flex justify-between items-start mb-4">
                 <span class="bg-eden-soothing text-eden-primary px-4 py-1.5 rounded-full text-sm font-bold group-hover:bg-eden-primary group-hover:text-white transition-colors">{{ log.emotionType }}</span>
                 <span class="text-xs text-gray-400">{{ log.timestamp | date:'MMM d, h:mm a' }}</span>
              </div>
              <p class="text-gray-800 font-bold mb-2 text-lg">{{ log.activities }}</p>
              @if (log.note) {
                <p class="text-gray-500 text-sm leading-relaxed">"{{ log.note }}"</p>
              }
           </div>
        }
      </div>
    </div>
  `
})
export class MoodTrackerComponent implements OnInit {
    moodService = inject(MoodService);
    fb = inject(FormBuilder);

    isLogging = false;
    emotions = ['Happy', 'Excited', 'Calm', 'Grateful', 'Sad', 'Anxious', 'Angry', 'Tired', 'Bored'];

    moodForm = this.fb.group({
        emotionType: ['', Validators.required],
        activities: ['', Validators.required],
        note: ['']
    });

    ngOnInit() {
        this.moodService.loadMoods();
    }

    selectEmotion(emotion: string) {
        this.moodForm.patchValue({ emotionType: emotion });
    }

    onSubmit() {
        if (this.moodForm.valid) {
            // @ts-ignore
            this.moodService.logMood({ ...this.moodForm.value, timestamp: new Date().toISOString() }).subscribe({
                next: () => {
                    this.isLogging = false;
                    this.moodForm.reset();
                }
            });
        }
    }
}
