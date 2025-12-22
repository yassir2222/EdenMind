import { Component, inject, OnInit, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder } from '@angular/forms';
import { UserService } from '../../../core/services/user.service';

@Component({
   selector: 'app-profile',
   standalone: true,
   imports: [CommonModule, ReactiveFormsModule],
   template: `
    <div class="max-w-4xl mx-auto animate-fade-in-up pb-10">
      <h2 class="text-3xl font-bold text-gray-800 mb-6">Your Profile</h2>
      
      <div class="bg-white p-8 rounded-3xl shadow-sm border border-gray-100 relative overflow-hidden">
        <!-- Decoration -->
        <div class="absolute top-0 right-0 w-64 h-64 bg-eden-green rounded-full mix-blend-multiply filter blur-3xl opacity-30 -mr-16 -mt-16 pointer-events-none"></div>

        @if (userService.currentUser(); as user) {
           <form [formGroup]="profileForm" (ngSubmit)="onSubmit()" class="space-y-6 relative z-10">
              <!-- Header Section -->
              <div class="flex flex-col md:flex-row items-center gap-8 mb-8 pb-8 border-b border-gray-100">
                 <div class="relative group">
                     <div class="w-32 h-32 rounded-full flex items-center justify-center text-3xl font-bold text-white shadow-inner flex-shrink-0 overflow-hidden bg-gray-100 border-4 border-white">
                        @if (profileForm.get('avatarUrl')?.value) {
                            <img [src]="profileForm.get('avatarUrl')?.value" class="w-full h-full object-cover" alt="Profile">
                        } @else {
                            <div class="w-full h-full bg-gradient-to-br from-eden-soothing to-eden-secondary flex items-center justify-center">
                                {{ user.firstName[0] }}{{ user.lastName[0] }}
                            </div>
                        }
                     </div>
                     <button type="button" (click)="generateAvatar()" class="absolute bottom-0 right-0 bg-eden-primary text-white p-2 rounded-full shadow-lg hover:scale-110 transition nav-button" title="Generate New Avatar">
                        <span class="material-icons text-xl">casino</span>
                     </button>
                 </div>

                 <div class="text-center md:text-left flex-1">
                    <h3 class="text-2xl font-bold text-gray-800">{{ user.firstName }} {{ user.lastName }}</h3>
                    <p class="text-gray-500 mb-2">{{ user.email }}</p>
                    
                    <!-- Avatar URL Input (Optional) -->
                    <div class="mt-4 max-w-sm">
                        <label class="text-xs font-bold text-gray-400 uppercase tracking-wider mb-1 block text-left">Avatar URL</label>
                        <div class="flex gap-2">
                             <input formControlName="avatarUrl" type="text" class="flex-1 px-3 py-2 text-sm rounded-xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white" placeholder="https://...">
                        </div>
                        <p class="text-[10px] text-gray-400 text-left mt-1">Paste an image URL or click the dice to generate one.</p>
                    </div>
                 </div>
              </div>

              <!-- Personal Info -->
              <h4 class="text-lg font-bold text-gray-800 border-l-4 border-eden-primary pl-3 mb-4">Personal Information</h4>
              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Phone Number</label>
                    <input formControlName="phoneNumber" type="tel" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white">
                 </div>
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Birthday</label>
                    <input formControlName="birthday" type="date" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white">
                 </div>
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Country</label>
                    <input formControlName="country" type="text" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white">
                 </div>
              </div>

              <!-- Context Context -->
               <h4 class="text-lg font-bold text-gray-800 border-l-4 border-eden-primary pl-3 mt-8 mb-4">Therapy Context</h4>
               
               <div>
                 <label class="block text-sm font-bold text-gray-700 mb-2">Bio / Notes</label>
                 <textarea formControlName="bio" rows="3" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition resize-none bg-gray-50 focus:bg-white" placeholder="Share a little about yourself..."></textarea>
                 <p class="text-xs text-gray-400 mt-2">The AI therapist uses this to understand you better.</p>
              </div>

              <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Family Situation</label>
                    <select formControlName="familySituation" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-white appearance-none cursor-pointer">
                       <option value="">Select...</option>
                       <option value="Single">Single</option>
                       <option value="Married">Married</option>
                       <option value="Divorced">Divorced</option>
                       <option value="Widowed">Widowed</option>
                       <option value="Other">Other</option>
                    </select>
                 </div>
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Children Count</label>
                    <input formControlName="childrenCount" type="number" min="0" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white">
                 </div>
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Work Type</label>
                    <input formControlName="workType" type="text" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white" placeholder="e.g. Student, Engineer">
                 </div>
                 <div>
                    <label class="block text-sm font-bold text-gray-700 mb-2">Work Hours (Weekly)</label>
                    <input formControlName="workHours" type="text" class="w-full px-5 py-3 rounded-2xl border border-gray-200 focus:ring-2 focus:ring-eden-secondary outline-none transition bg-gray-50 focus:bg-white" placeholder="e.g. 40h">
                 </div>
              </div>

              <div class="flex justify-end pt-6 border-t border-gray-50">
                 <button type="submit" [disabled]="profileForm.invalid || profileForm.pristine" class="bg-eden-primary text-white py-3 px-8 rounded-xl font-bold shadow-lg hover:bg-teal-600 transition disabled:opacity-50 hover:-translate-y-0.5 transform">Save Changes</button>
              </div>
           </form>
        } @else {
           <div class="text-center py-20 flex flex-col items-center">
              <div class="w-12 h-12 border-4 border-eden-soothing border-t-eden-primary rounded-full animate-spin mb-4"></div>
              <p class="text-gray-400">Loading profile data...</p>
           </div>
        }
      </div>
    </div>
  `
})
export class ProfileComponent implements OnInit {
   userService = inject(UserService);
   fb = inject(FormBuilder);

   userId: string | null = null;

   profileForm = this.fb.group({
      firstName: [''],
      lastName: [''],
      email: [''],
      avatarUrl: [''],
      bio: [''],
      familySituation: [''],
      workType: [''],
      phoneNumber: [''],
      birthday: [''],
      country: [''],
      childrenCount: [0],
      workHours: ['']
   });

   constructor() {
      effect(() => {
         const user = this.userService.currentUser();
         if (user) {
            this.profileForm.patchValue(user);
         }
      });
   }

   ngOnInit() {
      this.userId = this.userService.getUserIdFromToken();
      if (this.userId) {
         this.userService.loadProfile(this.userId);
      }
   }

   generateAvatar() {
      const seed = Math.random().toString(36).substring(7);
      const url = `https://api.dicebear.com/7.x/personas/svg?seed=${seed}`;
      this.profileForm.patchValue({ avatarUrl: url });
      this.profileForm.markAsDirty();
   }

   onSubmit() {
      if (this.profileForm.valid && this.userId) {
         // Merge current user data with form values to ensure no fields are lost/null
         const user = this.userService.currentUser();
         const updatedProfile = {
            ...user,
            ...this.profileForm.value
         };

         this.userService.updateProfile(this.userId, updatedProfile as any).subscribe({
            next: () => alert('Profile updated successfully!'),
            error: (err) => console.error('Update failed', err)
         });
      }
   }
}
