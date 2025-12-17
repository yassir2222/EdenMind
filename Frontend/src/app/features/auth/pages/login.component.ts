import { Component, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { RouterLink } from '@angular/router';

@Component({
  selector: 'app-login',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule, RouterLink],
  template: `
    <div class="min-h-screen flex bg-white font-sans">
      <!-- Left Side: Form -->
      <div class="w-full lg:w-1/2 flex flex-col p-8 lg:p-16 justify-center">
        <div class="max-w-md mx-auto w-full">
          <!-- Logo -->
          <div class="flex items-center gap-2 mb-12">
             <div class="w-8 h-8 bg-eden-mint rounded-lg flex items-center justify-center text-white font-bold">EM</div>
             <span class="text-xl font-bold text-gray-800">EdenMind</span>
          </div>

          <h1 class="text-4xl font-bold text-gray-900 mb-2">Welcome Back</h1>
          <p class="text-gray-500 mb-8">Your safe space for growth and balance awaits.</p>

          @if (errorMessage()) {
            <div class="bg-red-50 border-l-4 border-red-500 p-4 mb-6 rounded-r-xl animate-fade-in">
              <div class="flex items-center">
                <span class="text-red-500 text-xl mr-3">⚠️</span>
                <p class="text-sm text-red-700 font-bold">{{ errorMessage() }}</p>
              </div>
            </div>
          }

          <form [formGroup]="loginForm" (ngSubmit)="onSubmit()" class="space-y-6">
            <div>
              <label class="block text-sm font-semibold text-gray-700 mb-2">Email Address</label>
              <div class="relative">
                <input formControlName="email" type="email" 
                       class="w-full px-4 py-3 pl-10 rounded-xl bg-gray-50 border border-gray-200 focus:ring-2 focus:ring-eden-mint focus:border-transparent outline-none transition" 
                       placeholder="you@example.com">
                <span class="absolute left-3 top-3.5 text-gray-400">📧</span>
              </div>
            </div>

            <div>
              <div class="flex justify-between items-center mb-2">
                 <label class="block text-sm font-semibold text-gray-700">Password</label>
                 <a href="#" class="text-sm text-eden-mint font-semibold hover:underline">Forgot password?</a>
              </div>
              <div class="relative">
                <input formControlName="password" type="password" 
                       class="w-full px-4 py-3 pl-10 rounded-xl bg-gray-50 border border-gray-200 focus:ring-2 focus:ring-eden-mint focus:border-transparent outline-none transition" 
                       placeholder="••••••••">
                <span class="absolute left-3 top-3.5 text-gray-400">🔒</span>
              </div>
            </div>

            <button type="submit" [disabled]="loginForm.invalid" 
                    class="w-full bg-eden-mint hover:bg-eden-mint-dark text-white font-bold py-4 rounded-full shadow-lg transition transform hover:-translate-y-0.5 disabled:opacity-50 disabled:cursor-not-allowed">
              Log in to EdenMind
            </button>
          </form>

          <div class="relative my-8">
            <div class="absolute inset-0 flex items-center"><div class="w-full border-t border-gray-200"></div></div>
            <div class="relative flex justify-center text-sm"><span class="px-2 bg-white text-gray-500">Or continue with</span></div>
          </div>

          <div class="grid grid-cols-2 gap-4">
             <button class="flex items-center justify-center gap-2 px-4 py-3 border border-gray-200 rounded-full hover:bg-gray-50 transition font-medium text-gray-700">
               <span>G</span> Google
             </button>
             <button class="flex items-center justify-center gap-2 px-4 py-3 border border-gray-200 rounded-full hover:bg-gray-50 transition font-medium text-gray-700">
               <span></span> Apple
             </button>
          </div>

          <p class="mt-8 text-center text-sm text-gray-600">
            Don't have an account yet? 
            <a routerLink="/register" class="text-eden-mint font-bold hover:underline">Join us</a>
          </p>
        </div>
      </div>

      <!-- Right Side: Image -->
      <div class="hidden lg:block w-1/2 relative overflow-hidden bg-gray-900">
         <!-- Placeholder for leaf image - using a simple gradient overlay on a placeholder that looks green/nature -->
         <img src="https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?q=80&w=2560&auto=format&fit=crop" 
              class="absolute inset-0 w-full h-full object-cover" alt="Nature">
         <div class="absolute inset-0 bg-gradient-to-br from-green-900/40 to-black/60 z-10"></div>
         
         <div class="absolute bottom-12 left-12 right-12 z-20 text-white">
            <div class="inline-flex items-center gap-2 bg-white/20 backdrop-blur-md px-3 py-1 rounded-full text-xs font-bold mb-6 border border-white/10">
               <span>💡</span> Daily Tip
            </div>
            <blockquote class="text-4xl font-bold leading-tight mb-4 drop-shadow-md">
              "Peace comes from within. Do not seek it without."
            </blockquote>
            <cite class="text-gray-200 not-italic font-medium">- Buddha</cite>
         </div>
      </div>
    </div>
  `
})
export class LoginComponent {
  private fb = inject(FormBuilder);
  private authService = inject(AuthService);

  errorMessage = signal('');

  loginForm = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required]]
  });

  onSubmit() {
    if (this.loginForm.valid) {
      this.errorMessage.set('');
      // @ts-ignore
      this.authService.login(this.loginForm.value).subscribe({
        error: (err) => {
          console.error('Login failed', err);
          this.errorMessage.set('Invalid email or password. Please try again.');
        }
      });
    }
  }
}
