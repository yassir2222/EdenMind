import { Component, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

interface DistortionScenario {
    id: number;
    thought: string;
    distortion: string; // The correct answer
    options: string[]; // Options to choose from
    rationalResponse: string;
}

@Component({
    selector: 'app-distortion-hunter',
    standalone: true,
    imports: [CommonModule, RouterLink],
    template: `
    <div class="min-h-full flex flex-col items-center justify-center animate-fade-in relative overflow-hidden bg-gradient-to-b from-purple-50 to-white px-4 py-8">
      
      <!-- Ambient Background Elements -->
      <div class="absolute top-20 left-10 w-32 h-32 bg-purple-200 rounded-full blur-3xl opacity-30 animate-pulse"></div>
      <div class="absolute bottom-20 right-10 w-40 h-40 bg-eden-mint rounded-full blur-3xl opacity-20"></div>

       <!-- Header -->
       <div class="text-center mb-8 z-10 w-full max-w-2xl relative">
            <a routerLink="/dashboard/games" class="absolute left-0 top-1 text-gray-400 hover:text-eden-primary transition">
              ← Back
            </a>
            <h2 class="text-3xl font-bold text-gray-800">Distortion Hunter</h2>
            <p class="text-gray-500 text-sm">Identify the cognitive distortion to clear the fog.</p>
            
            <div class="flex justify-center gap-2 mt-4">
               @for (star of stars(); track $index) {
                  <span class="text-2xl transition-all duration-500 transform" [class.scale-125]="star === '★'">{{ star }}</span>
               }
            </div>
       </div>

      <!-- Game Area -->
      <div class="w-full max-w-2xl relative z-10 min-h-[500px] flex flex-col">
        
        @if (!gameComplete()) {
            <!-- Thought Cloud (Enemy) -->
            <div class="bg-gray-800 text-white p-8 rounded-3xl shadow-xl mb-8 relative transform transition-all duration-500 hover:scale-[1.02]"
                 [ngClass]="{'animate-shake': shake(), 'bg-green-600': isCorrect() === true, 'bg-red-500': isCorrect() === false}">
                
                <div class="absolute -top-6 -left-6 text-6xl opacity-20">☁️</div>
                <div class="absolute -bottom-6 -right-6 text-6xl opacity-20">🌩️</div>

                <h3 class="text-xl font-medium mb-2 opacity-70 uppercase tracking-widest text-xs">Negative Thought</h3>
                <p class="text-2xl font-bold leading-relaxed">"{{ currentScenario()?.thought }}"</p>
                
                <!-- Feedback Overlay -->
                @if (isCorrect() !== null) {
                    <div class="absolute inset-0 flex items-center justify-center bg-black/10 backdrop-blur-[2px] rounded-3xl">
                       <div class="text-6xl animate-bounce">
                          {{ isCorrect() ? '✨' : '❌' }}
                       </div>
                    </div>
                }
            </div>

            <!-- Options -->
            <div class="grid grid-cols-1 md:grid-cols-2 gap-4" [class.pointer-events-none]="isCorrect() !== null">
                @for (option of currentOptions(); track option) {
                    <button (click)="checkAnswer(option)" 
                            class="bg-white p-6 rounded-2xl shadow-sm border-2 border-transparent hover:border-purple-200 hover:shadow-md transition-all text-left group relative overflow-hidden">
                        <span class="font-bold text-gray-700 group-hover:text-purple-600 transition-colors">{{ option }}</span>
                        <div class="absolute inset-0 bg-purple-50 transform scale-x-0 group-hover:scale-x-100 transition-transform origin-left -z-10"></div>
                    </button>
                }
            </div>
        } 
        
        <!-- Rational Response / Level Complete Screen -->
        @if (showRational()) {
            <div class="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40 backdrop-blur-sm animate-fade-in">
                <div class="bg-white rounded-3xl p-8 max-w-lg w-full shadow-2xl relative">
                    <div class="absolute -top-10 left-1/2 -translate-x-1/2 bg-eden-mint text-white w-20 h-20 rounded-full flex items-center justify-center text-4xl shadow-lg border-4 border-white">
                        💡
                    </div>
                    
                    <div class="mt-8 text-center">
                        <h3 class="text-2xl font-bold text-gray-800 mb-2">That's it!</h3>
                        <p class="text-purple-500 font-bold mb-6 uppercase tracking-wider text-xs">REFRAMED THOUGHT</p>
                        
                        <div class="bg-purple-50 p-6 rounded-xl border border-purple-100 mb-8 text-left">
                           <p class="text-gray-700 italic text-lg text-center">"{{ currentScenario()?.rationalResponse }}"</p>
                        </div>
                        
                        <button (click)="nextLevel()" class="w-full bg-eden-primary text-white py-4 rounded-xl font-bold hover:bg-eden-mint-dark transition shadow-lg transform active:scale-95">
                           Next Thought →
                        </button>
                    </div>
                </div>
            </div>
        }

        <!-- Game Complete Screen -->
        @if (gameComplete()) {
             <div class="bg-white rounded-3xl p-10 text-center shadow-xl border border-purple-100 animate-scale-in">
                 <div class="text-8xl mb-6">🎉</div>
                 <h2 class="text-4xl font-bold text-gray-800 mb-4">Mind Clear!</h2>
                 <p class="text-gray-500 text-lg mb-8">You've successfully challenged 5 common cognitive distortions. Keep practicing this in your daily life.</p>
                 
                 <div class="flex flex-col gap-3">
                     <button (click)="restart()" class="bg-purple-500 text-white py-3 px-8 rounded-full font-bold hover:bg-purple-600 transition shadow-md">
                        Play Again
                     </button>
                     <a routerLink="/dashboard/games" class="text-gray-400 hover:text-gray-600 font-medium p-2">
                        Back to Games
                     </a>
                 </div>
             </div>
        }

      </div>

    </div>
  `,
    styles: [`
    .animate-shake {
      animation: shake 0.5s cubic-bezier(.36,.07,.19,.97) both;
    }
    @keyframes shake {
      10%, 90% { transform: translate3d(-1px, 0, 0); }
      20%, 80% { transform: translate3d(2px, 0, 0); }
      30%, 50%, 70% { transform: translate3d(-4px, 0, 0); }
      40%, 60% { transform: translate3d(4px, 0, 0); }
    }
  `]
})
export class DistortionHunterComponent {

    scenarios: DistortionScenario[] = [
        {
            id: 1,
            thought: "I made a mistake in the presentation. Everyone must think I'm incompetent.",
            distortion: "Mind Reading",
            options: ["Mind Reading", "Fortune Telling", "All-or-Nothing Thinking", "Emotional Reasoning"],
            rationalResponse: "I cannot know what others are thinking. One mistake does not define my competence."
        },
        {
            id: 2,
            thought: "If I don't get an A on this test, I'm a complete failure.",
            distortion: "All-or-Nothing Thinking",
            options: ["Should Statements", "All-or-Nothing Thinking", "Laboring", "Personalization"],
            rationalResponse: "Success is a spectrum. Getting a B or C doesn't erase my worth or potential."
        },
        {
            id: 3,
            thought: "I feel anxious, so something bad is definitely going to happen.",
            distortion: "Emotional Reasoning",
            options: ["Emotional Reasoning", "Catastrophizing", "Mental Filter", "Disqualifying the Positive"],
            rationalResponse: "Feelings are not facts. My anxiety is a reaction, not a prediction of the future."
        },
        {
            id: 4,
            thought: "My friend didn't text back. They must be angry with me.",
            distortion: "Jumping to Conclusions",
            options: ["Jumping to Conclusions", "Labeling", "Should Statements", "Magnification"],
            rationalResponse: "There are many reasons they haven't replied. They might be busy, sleeping, or away from their phone."
        },
        {
            id: 5,
            thought: "I should have known better. I'm so stupid.",
            distortion: "Labeling",
            options: ["Labeling", "Mind Reading", "Discounting the Positive", "Catastrophizing"],
            rationalResponse: "I am human and learning. Calling myself names isn't helpful. 'I made a mistake' is more accurate than 'I am stupid'."
        }
    ];

    level = signal(0);
    gameComplete = signal(false);
    currentScenario = signal<DistortionScenario | null>(null);
    currentOptions = signal<string[]>([]);

    // UI States
    isCorrect = signal<boolean | null>(null); // null = waiting, true = correct, false = wrong
    shake = signal(false);
    showRational = signal(false);

    // Stars display
    stars = signal<string[]>(['☆', '☆', '☆', '☆', '☆']);

    constructor() {
        this.loadLevel(0);
    }

    loadLevel(idx: number) {
        if (idx >= this.scenarios.length) {
            this.gameComplete.set(true);
            return;
        }

        const scenario = this.scenarios[idx];
        this.currentScenario.set(scenario);
        // Shuffle options for fun? Standard is fine for now as they are hardcoded shuffled-ish
        this.currentOptions.set(this.shuffleArray([...scenario.options]));
        this.isCorrect.set(null);
        this.showRational.set(false);
    }

    checkAnswer(selectedOption: string) {
        if (this.isCorrect() !== null) return; // Prevent spam

        const scenario = this.currentScenario();
        if (selectedOption === scenario?.distortion) {
            // Correct
            this.isCorrect.set(true);
            this.updateStar(this.level());
            setTimeout(() => {
                this.showRational.set(true);
            }, 1000);
        } else {
            // Wrong
            this.isCorrect.set(false);
            this.shake.set(true);
            setTimeout(() => {
                this.shake.set(false);
                this.isCorrect.set(null); // Reset to try again
            }, 800);
        }
    }

    nextLevel() {
        this.level.update(l => l + 1);
        this.loadLevel(this.level());
    }

    restart() {
        this.level.set(0);
        this.stars.set(['☆', '☆', '☆', '☆', '☆']);
        this.gameComplete.set(false);
        this.loadLevel(0);
    }

    updateStar(idx: number) {
        this.stars.update(curr => {
            const arr = [...curr];
            arr[idx] = '★';
            return arr;
        });
    }

    shuffleArray(array: any[]) {
        for (let i = array.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [array[i], array[j]] = [array[j], array[i]];
        }
        return array;
    }
}
