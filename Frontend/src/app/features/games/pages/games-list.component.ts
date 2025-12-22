import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

@Component({
   selector: 'app-games-list',
   standalone: true,
   imports: [CommonModule, RouterLink],
   template: `
    <div class="max-w-6xl mx-auto animate-fade-in-up">
      <div class="mb-10 text-center">
        <h2 class="text-4xl font-bold text-eden-dark mb-4">Therapeutic Activities</h2>
        <p class="text-gray-500 text-lg">Take a moment to center yourself with these exercises.</p>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-8">
        <!-- Breathing -->
        <a routerLink="/dashboard/games/breathing" class="group bg-white rounded-3xl p-8 shadow-sm border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-300 relative overflow-hidden">
           <div class="absolute inset-0 bg-gradient-to-br from-blue-50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
           <div class="relative z-10">
               <div class="w-16 h-16 bg-blue-100 text-blue-500 rounded-2xl flex items-center justify-center mb-6 text-3xl group-hover:scale-110 transition-transform shadow-inner">
                  <span class="material-icons">air</span>
               </div>
               <h3 class="text-xl font-bold text-gray-800 mb-3 group-hover:text-eden-primary transition-colors">Breathing Exercise</h3>
               <p class="text-gray-500 leading-relaxed">A simple 4-7-8 rhythm to calm your nervous system and reduce anxiety instantly.</p>
           </div>
        </a>

        <!-- Distortion Hunter -->
        <a routerLink="/dashboard/games/distortion-hunter" class="group bg-white rounded-3xl p-8 shadow-sm border border-gray-100 relative overflow-hidden transition-all duration-300 hover:shadow-xl hover:-translate-y-2">
           <div class="absolute inset-0 bg-gradient-to-br from-purple-50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
           <div class="relative z-10">
               <div class="w-16 h-16 bg-purple-100 text-purple-500 rounded-2xl flex items-center justify-center mb-6 text-3xl group-hover:rotate-12 transition-transform">
                  <span class="material-icons">psychology</span>
               </div>
               <h3 class="text-xl font-bold text-gray-800 mb-3 text-eden-primary transition-colors">Distortion Hunter</h3>
               <p class="text-gray-500 leading-relaxed">Identify and challenge cognitive distortions in this interactive CBT mini-game.</p>
           </div>
        </a>

        <!-- Serenity Tower -->
        <a routerLink="/dashboard/games/serenity-tower" class="group bg-white rounded-3xl p-8 shadow-sm border border-gray-100 hover:shadow-xl hover:-translate-y-2 transition-all duration-300 relative overflow-hidden">
           <div class="absolute inset-0 bg-gradient-to-br from-green-50 to-transparent opacity-0 group-hover:opacity-100 transition-opacity duration-500"></div>
           <div class="relative z-10">
               <div class="w-16 h-16 bg-green-100 text-green-500 rounded-2xl flex items-center justify-center mb-6 text-3xl group-hover:scale-110 transition-transform shadow-inner">
                  <span class="material-icons">balance</span>
               </div>
               <h3 class="text-xl font-bold text-gray-800 mb-3 text-eden-primary transition-colors">Serenity Tower</h3>
               <p class="text-gray-500 leading-relaxed">Build a tower of focus and balance. A mindfulness game to improve concentration.</p>
           </div>
        </a>
      </div>
    </div>
  `
})
export class GamesListComponent { }
