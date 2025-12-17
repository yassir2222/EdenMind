import { Component, inject, OnInit, computed, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { MoodService, MoodLog } from '../../../core/services/mood.service';
import { UserService } from '../../../core/services/user.service';

@Component({
   selector: 'app-dashboard-overview',
   standalone: true,
   imports: [CommonModule, RouterLink],
   template: `
    <div class="max-w-7xl mx-auto space-y-8 animate-fade-in">
      <!-- Header -->
      <div class="flex justify-between items-end">
        <div>
           <h2 class="text-gray-500 font-medium uppercase tracking-wider text-xs mb-1">{{ currentDate | date:'fullDate' }}</h2>
           <h1 class="text-4xl font-bold text-gray-900">Good Morning, {{ (userService.currentUser()?.firstName) || 'Eden' }} <span class="text-eden-mint text-5xl">.</span></h1>
           <p class="text-gray-500 mt-2">Welcome back to your safe space. You're on a <span class="font-bold text-gray-800">{{ streakDays }}-day mindfulness streak!</span></p>
        </div>
        <a routerLink="chat" class="hidden md:flex bg-eden-mint hover:bg-eden-mint-dark text-white px-6 py-3 rounded-full font-bold shadow-soft items-center gap-2 transition transform hover:-translate-y-0.5">
           <svg xmlns="http://www.w3.org/2000/svg" class="h-5 w-5" viewBox="0 0 20 20" fill="currentColor">
             <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM9.555 7.168A1 1 0 008 8v4a1 1 0 001.555.832l3-2a1 1 0 000-1.664l-3-2z" clip-rule="evenodd" />
           </svg>
           Start Session
        </a>
      </div>

      <!-- Quick Actions (Static for now, but linked) -->
      <div>
         <div class="flex items-center gap-2 mb-4">
            <span class="text-eden-mint font-bold text-xl">⚡</span>
            <h3 class="text-xl font-bold text-gray-900">Quick Actions</h3>
         </div>
         <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
            <!-- Mood Check-in -->
            <div class="bg-gray-50 rounded-3xl p-6 hover:bg-white hover:shadow-soft transition border border-transparent hover:border-gray-100 group cursor-pointer" routerLink="mood">
               <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center text-2xl shadow-sm mb-4 text-eden-mint">
                  🙂
               </div>
               <h4 class="font-bold text-lg text-gray-900 mb-2">Daily Mood Check-in</h4>
               <p class="text-gray-500 text-sm mb-4">Track how you are feeling today to get personalized advice.</p>
               <span class="text-eden-mint font-bold text-sm flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                  Check In →
               </span>
            </div>

            <!-- Resume Session -->
            <div class="bg-gray-50 rounded-3xl p-6 hover:bg-white hover:shadow-soft transition border border-transparent hover:border-gray-100 group cursor-pointer" routerLink="chat">
               <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center text-2xl shadow-sm mb-4 text-blue-400">
                  💬
               </div>
               <h4 class="font-bold text-lg text-gray-900 mb-2">Resume Session</h4>
               <p class="text-gray-500 text-sm mb-4">Continue your conversation with Eden from where you left off.</p>
               <span class="text-eden-mint font-bold text-sm flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                  Chat Now →
               </span>
            </div>

            <!-- Breathe -->
            <div class="bg-gray-50 rounded-3xl p-6 hover:bg-white hover:shadow-soft transition border border-transparent hover:border-gray-100 group cursor-pointer" routerLink="games">
               <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center text-2xl shadow-sm mb-4 text-purple-400">
                  💨
               </div>
               <h4 class="font-bold text-lg text-gray-900 mb-2">Breathe</h4>
               <p class="text-gray-500 text-sm mb-4">Take a moment to center yourself with a 2-minute exercise.</p>
               <span class="text-eden-mint font-bold text-sm flex items-center gap-1 group-hover:translate-x-1 transition-transform">
                  Start →
               </span>
            </div>
         </div>
      </div>

      <!-- Bottom Section: History & Insight -->
      <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
         <!-- Mood History Chart -->
         <div class="lg:col-span-2 bg-white rounded-3xl p-8 border border-gray-100 shadow-sm">
            <div class="flex justify-between items-center mb-6">
               <h3 class="font-bold text-lg text-gray-900">Mood History (Last 7 Days)</h3>
            </div>
            
            <div class="flex items-end justify-between h-48 gap-4 px-4">
               @for (day of weeklyChartData; track day.label) {
                  <div class="w-full rounded-t-xl transition-all relative group flex flex-col justify-end"
                       [class.bg-gray-100]="!day.mood"
                       [class.hover:bg-gray-200]="!day.mood"
                       [ngClass]="day.colorClass"
                       [style.height.%]="day.height">
                     
                     <div class="opacity-0 group-hover:opacity-100 absolute -top-8 left-1/2 -translate-x-1/2 bg-gray-800 text-white text-xs py-1 px-2 rounded whitespace-nowrap z-10 transition-opacity">
                        {{ day.mood || 'No Data' }}
                     </div>
                     
                     <!-- Day Label (below bar, conceptually, but we can put it inside or absolute bottom if using flex) -->
                     <!-- Actually let's put it hidden or visually below with a container approach -->
                  </div>
               }
            </div>
            <!-- Labels Row -->
             <div class="flex justify-between px-4 mt-2">
                @for (day of weeklyChartData; track day.label) {
                    <div class="w-full text-center text-xs text-gray-400 font-bold">{{ day.label }}</div>
                }
             </div>
         </div>

         <!-- Daily Insight -->
         <div class="bg-eden-mint-light rounded-3xl p-8 flex flex-col items-center justify-center text-center relative overflow-hidden">
             <!-- Background decoration -->
             <div class="absolute top-0 right-0 w-32 h-32 bg-eden-mint opacity-10 rounded-full -mr-16 -mt-16 blur-2xl"></div>
             
             <div class="w-12 h-12 bg-white rounded-full flex items-center justify-center text-2xl shadow-sm mb-6 z-10 text-eden-mint">
                💡
             </div>
             <h3 class="font-bold text-lg text-gray-900 mb-2 z-10">Daily Insight</h3>
             <blockquote class="italic text-gray-600 mb-4 z-10">"Peace comes from within. Do not seek it without."</blockquote>
             <cite class="text-xs font-bold text-gray-500 uppercase tracking-widest z-10">- Buddha</cite>
         </div>
      </div>
    </div>
  `
})
export class DashboardOverviewComponent implements OnInit {
   moodService = inject(MoodService);
   userService = inject(UserService);

   currentDate = new Date();
   streakDays = 0;
   weeklyChartData: any[] = [];

   constructor() {
      effect(() => {
         const moods = this.moodService.moods();
         this.calculateStreak(moods);
         this.generateChartData(moods);
      });
   }

   ngOnInit() {
      this.moodService.loadMoods();
   }

   calculateStreak(moods: MoodLog[]) {
      if (!moods.length) {
         this.streakDays = 0;
         return;
      }

      const sorted = [...moods].sort((a, b) => new Date(b.recordedAt!).getTime() - new Date(a.recordedAt!).getTime());

      let streak = 0;
      let today = new Date();
      today.setHours(0, 0, 0, 0);

      // Remove time component for comparison
      const dates = sorted.map(m => {
         const d = new Date(m.recordedAt!);
         d.setHours(0, 0, 0, 0);
         return d.getTime();
      });

      // Unique dates
      const uniqueDates = [...new Set(dates)];

      if (uniqueDates.length === 0) return;

      // Check if latest is today or yesterday
      const latest = uniqueDates[0];
      const diffDays = (today.getTime() - latest) / (1000 * 3600 * 24);

      if (diffDays > 1) {
         this.streakDays = 0;
         return;
      }

      streak = 1;
      for (let i = 0; i < uniqueDates.length - 1; i++) {
         const curr = uniqueDates[i];
         const prev = uniqueDates[i + 1];
         const diff = (curr - prev) / (1000 * 3600 * 24);

         if (diff === 1) {
            streak++;
         } else {
            break;
         }
      }
      this.streakDays = streak;
   }

   generateChartData(moods: MoodLog[]) {
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      const chart = [];
      const today = new Date(); // Start from today

      // Generate last 7 days (reverse order to show oldest on left? No, usually chronologically: Oldest -> Newest)
      // Let's do Oldest -> Newest (Today is rightmost)

      for (let i = 6; i >= 0; i--) {
         const d = new Date();
         d.setDate(today.getDate() - i);
         d.setHours(0, 0, 0, 0);

         // Find mood for this day
         const mood = moods.find(m => {
            const md = new Date(m.recordedAt!);
            md.setHours(0, 0, 0, 0);
            return md.getTime() === d.getTime();
         });

         // Map mood to style
         let height = 15; // default base height
         let colorClass = 'bg-gray-100'; // default empty
         let moodLabel = null;

         if (mood) {
            moodLabel = mood.emotionType;
            switch (mood.emotionType.toLowerCase()) {
               case 'happy':
               case 'excited':
               case 'joyful':
                  height = 85;
                  colorClass = 'bg-eden-mint shadow-lg shadow-eden-mint/30';
                  break;
               case 'clam':
               case 'relaxed':
                  height = 60;
                  colorClass = 'bg-blue-300';
                  break;
               case 'sad':
                  height = 30;
                  colorClass = 'bg-indigo-300';
                  break;
               case 'anxious':
                  height = 45;
                  colorClass = 'bg-orange-300';
                  break;
               case 'angry':
                  height = 70;
                  colorClass = 'bg-red-400';
                  break;
               default:
                  height = 50;
                  colorClass = 'bg-eden-secondary';
            }
         }

         chart.push({
            label: days[d.getDay()],
            height: height,
            colorClass: colorClass,
            mood: moodLabel
         });
      }

      this.weeklyChartData = chart;
   }
}
