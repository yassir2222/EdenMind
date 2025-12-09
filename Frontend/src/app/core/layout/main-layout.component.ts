import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterOutlet } from '@angular/router';
import { SidebarComponent } from '../components/sidebar/sidebar.component';

@Component({
    selector: 'app-main-layout',
    standalone: true,
    imports: [CommonModule, RouterOutlet, SidebarComponent],
    template: `
    <div class="min-h-screen bg-eden-light flex">
      <app-sidebar></app-sidebar>
      <main class="ml-64 flex-1 p-8 h-screen overflow-y-auto">
        <div class="max-w-7xl mx-auto h-full">
           <router-outlet></router-outlet>
        </div>
      </main>
    </div>
  `
})
export class MainLayoutComponent { }
