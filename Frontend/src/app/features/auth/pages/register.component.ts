import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, Validators } from '@angular/forms';
import { AuthService } from '../../../core/services/auth.service';
import { RouterLink } from '@angular/router';

@Component({
    selector: 'app-register',
    standalone: true,
    imports: [CommonModule, ReactiveFormsModule, RouterLink],
    template: `
    <div class="min-h-screen flex items-center justify-center bg-eden-light py-10 animate-fade-in">
      <div class="bg-white p-8 rounded-2xl shadow-xl w-full max-w-lg border-t-4 border-eden-secondary">
        <h2 class="text-3xl font-bold text-center text-eden-dark mb-2">Join EdenMind</h2>
        <p class="text-center text-gray-500 mb-8">Your journey to mental clarity starts here.</p>
        
        <form [formGroup]="registerForm" (ngSubmit)="onSubmit()" class="space-y-4">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">First Name</label>
              <input formControlName="firstName" type="text" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-eden-secondary focus:border-transparent outline-none transition" placeholder="Eden">
            </div>
            <div>
              <label class="block text-sm font-medium text-gray-700 mb-1">Last Name</label>
              <input formControlName="lastName" type="text" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-eden-secondary focus:border-transparent outline-none transition" placeholder="Mind">
            </div>
          </div>

          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
            <input formControlName="email" type="email" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-eden-secondary focus:border-transparent outline-none transition" placeholder="you@example.com">
          </div>
          
          <div>
            <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
            <input formControlName="password" type="password" class="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-eden-secondary focus:border-transparent outline-none transition" placeholder="••••••••">
          </div>

          <button type="submit" [disabled]="registerForm.invalid" class="w-full bg-eden-secondary hover:bg-green-500 text-white font-bold py-3 rounded-lg shadow-md hover:shadow-lg transition transform hover:-translate-y-0.5 disabled:opacity-50 mt-4 disabled:transform-none cursor-pointer">
            Create Account
          </button>
        </form>

        <p class="mt-6 text-center text-sm text-gray-600">
          Already have an account? 
          <a routerLink="/login" class="text-eden-secondary font-bold hover:underline">Sign In</a>
        </p>
      </div>
    </div>
  `
})
export class RegisterComponent {
    private fb = inject(FormBuilder);
    private authService = inject(AuthService);

    registerForm = this.fb.group({
        firstName: ['', [Validators.required]],
        lastName: ['', [Validators.required]],
        email: ['', [Validators.required, Validators.email]],
        password: ['', [Validators.required, Validators.minLength(6)]]
    });

    onSubmit() {
        if (this.registerForm.valid) {
            // @ts-ignore
            this.authService.register(this.registerForm.value).subscribe({
                error: (err) => alert('Registration failed. Please try again.')
            });
        }
    }
}
