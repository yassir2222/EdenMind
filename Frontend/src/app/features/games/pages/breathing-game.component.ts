import { Component, OnDestroy, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

@Component({
    selector: 'app-breathing-game',
    standalone: true,
    imports: [CommonModule, RouterLink],
    template: `
    <div class="h-full flex flex-col items-center justify-center animate-fade-in relative overflow-hidden">
      <div class="absolute inset-0 bg-gradient-to-b from-blue-50 to-white -z-10"></div>
    
      <div class="text-center mb-12 z-10">
        <h2 class="text-4xl font-bold text-eden-dark mb-4">4-7-8 Breathing</h2>
        <p class="text-xl text-eden-primary font-medium tracking-wide">{{ instruction() }}</p>
      </div>

      <div class="relative z-10">
        <!-- Breathing Circle -->
        <div class="w-64 h-64 rounded-full bg-gradient-to-tr from-eden-soothing to-blue-100 flex items-center justify-center shadow-2xl transition-all duration-[4000ms] ease-in-out transform"
             [ngClass]="{
               'scale-150': phase() === 'inhale', 
               'scale-100': phase() === 'exhale',
               'scale-125': phase() === 'hold'
             }">
           <div class="w-56 h-56 rounded-full bg-white opacity-20 blur-xl absolute"></div>
           <span class="text-6xl font-light text-eden-primary relative z-10">{{ timerDisplay() }}</span>
        </div>
        
        <!-- Ripples -->
        <div class="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-64 h-64 border-4 border-eden-soothing rounded-full animate-ping opacity-20 pointer-events-none" *ngIf="phase() === 'inhale'"></div>
      </div>

      <div class="mt-16 z-10 flex gap-4">
        <button (click)="toggleSession()" class="px-8 py-3 rounded-full font-bold shadow-lg transition transform hover:-translate-y-1 active:scale-95"
                [ngClass]="active() ? 'bg-red-400 hover:bg-red-500 text-white' : 'bg-eden-primary hover:bg-teal-600 text-white'">
           {{ active() ? 'Stop Session' : 'Start Breathing' }}
        </button>
        <a routerLink="/dashboard/games" class="px-8 py-3 rounded-full bg-white text-gray-600 font-bold shadow-md hover:bg-gray-50 transition">
           Back
        </a>
      </div>
    </div>
  `
})
export class BreathingGameComponent implements OnDestroy {
    phase = signal<'idle' | 'inhale' | 'hold' | 'exhale'>('idle');
    instruction = signal<string>('Ready to relax?');
    timerDisplay = signal<string | number>('');
    active = signal(false);

    private intervalId: any;
    private timeouts: any[] = [];

    toggleSession() {
        if (this.active()) {
            this.stop();
        } else {
            this.start();
        }
    }

    start() {
        this.active.set(true);
        this.runCycle();
    }

    stop() {
        this.active.set(false);
        this.phase.set('idle');
        this.instruction.set('Session Paused');
        this.timerDisplay.set('');
        this.clearOps();
    }

    clearOps() {
        this.timeouts.forEach(t => clearTimeout(t));
        this.timeouts = [];
    }

    runCycle() {
        if (!this.active()) return;

        // Inhale (4s)
        this.phase.set('inhale');
        this.instruction.set('Inhale deeply...');
        this.countdown(4);

        const t1 = setTimeout(() => {
            // Hold (7s)
            if (!this.active()) return;
            this.phase.set('hold');
            this.instruction.set('Hold your breath...');
            this.countdown(7);

            const t2 = setTimeout(() => {
                // Exhale (8s)
                if (!this.active()) return;
                this.phase.set('exhale');
                this.instruction.set('Exhale slowly...');
                this.countdown(8);

                const t3 = setTimeout(() => {
                    if (!this.active()) return;
                    this.runCycle(); // Loop
                }, 8000);
                this.timeouts.push(t3);

            }, 7000);
            this.timeouts.push(t2);

        }, 4000);
        this.timeouts.push(t1);
    }

    countdown(seconds: number) {
        let left = seconds;
        this.timerDisplay.set(left);
        const int = setInterval(() => {
            left--;
            if (left > 0) {
                this.timerDisplay.set(left);
            } else {
                clearInterval(int);
            }
        }, 1000);
        this.timeouts.push(setTimeout(() => clearInterval(int), seconds * 1000));
    }

    ngOnDestroy() {
        this.stop();
    }
}
