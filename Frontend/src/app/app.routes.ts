import { Routes } from '@angular/router';
import { LoginComponent } from './features/auth/pages/login.component';
import { RegisterComponent } from './features/auth/pages/register.component';
import { MainLayoutComponent } from './core/layout/main-layout.component';
import { ChatComponent } from './features/chat/pages/chat.component';
import { MoodTrackerComponent } from './features/mood-tracker/pages/mood-tracker.component';
import { ProfileComponent } from './features/profile/pages/profile.component';
import { GamesListComponent } from './features/games/pages/games-list.component';
import { BreathingGameComponent } from './features/games/pages/breathing-game.component';
import { authGuard } from './core/guards/auth.guard';
import { DashboardOverviewComponent } from './features/dashboard/pages/dashboard-overview.component';

export const routes: Routes = [
    { path: '', redirectTo: 'login', pathMatch: 'full' },
    { path: 'login', component: LoginComponent },
    { path: 'register', component: RegisterComponent },
    {
        path: 'dashboard',
        component: MainLayoutComponent,
        canActivate: [authGuard],
        children: [
            { path: '', component: DashboardOverviewComponent },
            { path: 'chat', component: ChatComponent },
            { path: 'mood', component: MoodTrackerComponent },
            { path: 'profile', component: ProfileComponent },
            { path: 'games', component: GamesListComponent },
            { path: 'games/breathing', component: BreathingGameComponent },
            { path: 'games/serenity-tower', loadComponent: () => import('./features/games/pages/serenity-tower.component').then(m => m.SerenityTowerComponent) },
            { path: 'games/distortion-hunter', loadComponent: () => import('./features/games/pages/distortion-hunter.component').then(m => m.DistortionHunterComponent) }
        ]
    },
    { path: '**', redirectTo: 'login' }
];
