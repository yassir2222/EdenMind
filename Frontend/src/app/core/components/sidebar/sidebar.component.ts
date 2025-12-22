import { Component, inject, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../../services/auth.service';
import { UserService } from '../../services/user.service';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  template: `
    <div class="h-screen w-64 bg-white border-r border-gray-100 flex flex-col fixed left-0 top-0 shadow-soft z-50 py-6">
      <!-- Logo -->
      <div class="px-8 flex items-center gap-3 mb-10">
        <div class="w-8 h-8 bg-eden-mint rounded-lg flex items-center justify-center text-white font-bold text-sm">EM</div>
        <div class="flex flex-col">
            <h1 class="font-bold text-gray-900 leading-none">EdenMind</h1>
            <span class="text-[10px] text-gray-400 font-medium tracking-wide">Therapeutic Companion</span>
        </div>
      </div>
      
      <!-- Menu -->
      <nav class="flex-1 px-4 space-y-2">
        <p class="px-4 text-xs font-bold text-gray-400 uppercase tracking-wider mb-2">Menu</p>

        <a routerLink="/dashboard" routerLinkActive="bg-eden-mint-light text-eden-mint-dark font-bold" [routerLinkActiveOptions]="{exact: true}" class="flex items-center px-4 py-3 text-gray-500 rounded-xl hover:bg-gray-50 hover:text-gray-900 transition-all duration-200 group">
          <span class="material-icons mr-3 text-xl w-6 text-center">dashboard</span>
          <span class="font-medium">Dashboard</span>
        </a>

        <a routerLink="/dashboard/chat" routerLinkActive="bg-eden-mint-light text-eden-mint-dark font-bold" class="flex items-center px-4 py-3 text-gray-500 rounded-xl hover:bg-gray-50 hover:text-gray-900 transition-all duration-200 group">
          <span class="material-icons mr-3 text-xl w-6 text-center">chat_bubble_outline</span>
          <span class="font-medium">Chat AI</span>
        </a>

        <a routerLink="/dashboard/mood" routerLinkActive="bg-eden-mint-light text-eden-mint-dark font-bold" class="flex items-center px-4 py-3 text-gray-500 rounded-xl hover:bg-gray-50 hover:text-gray-900 transition-all duration-200 group">
          <span class="material-icons mr-3 text-xl w-6 text-center">mood</span>
          <span class="font-medium">Mood Tracker</span>
        </a>

        <a routerLink="/dashboard/games" routerLinkActive="bg-eden-mint-light text-eden-mint-dark font-bold" class="flex items-center px-4 py-3 text-gray-500 rounded-xl hover:bg-gray-50 hover:text-gray-900 transition-all duration-200 group">
          <span class="material-icons mr-3 text-xl w-6 text-center">extension</span>
          <span class="font-medium">Mini-Games</span>
        </a>


      </nav>

      <!-- Bottom Actions -->
      <div class="mt-auto px-4 space-y-2">
         <div class="h-px bg-gray-100 my-4"></div>
         
         <button (click)="logout()" class="w-full flex items-center px-4 py-3 text-gray-400 rounded-xl hover:bg-red-50 hover:text-red-500 transition-all duration-200 cursor-pointer mb-2">
            <span class="material-icons mr-3 text-xl w-6 text-center">logout</span>
            <span class="font-medium">Sign Out</span>
         </button>

         @if (userService.currentUser(); as user) {
            <div [routerLink]="['/dashboard/profile']" class="bg-gray-50 p-3 rounded-2xl flex items-center gap-3 cursor-pointer hover:bg-eden-mint-light hover:scale-105 transition transform duration-200 border border-transparent hover:border-eden-mint">
                <div class="w-10 h-10 bg-eden-secondary text-white rounded-full flex items-center justify-center font-bold shadow-sm overflow-hidden">
                    @if (user.avatarUrl) {
                        <img [src]="user.avatarUrl" class="w-full h-full object-cover">
                    } @else {
                        {{ user.firstName[0] }}{{ user.lastName[0] }}
                    }
                </div>
                <div class="flex-1 min-w-0">
                    <p class="text-sm font-bold text-gray-900 truncate">{{ user.firstName }} {{ user.lastName }}</p>
                    <p class="text-xs text-gray-500 truncate">{{ user.email }}</p>
                </div>
                <span class="material-icons text-gray-400 text-sm">chevron_right</span>
            </div>
         }
      </div>
    </div>
  `
})
export class SidebarComponent implements OnInit {
  authService = inject(AuthService);
  userService = inject(UserService);

  ngOnInit() {
    // Ensure user data is loaded if not already
    if (!this.userService.currentUser()) {
      const userId = this.userService.getUserIdFromToken();
      if (userId) {
        this.userService.loadProfile(userId);
      }
    }
  }

  logout() {
    this.authService.logout();
  }
}
