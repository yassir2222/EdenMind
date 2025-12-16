import { Component, ElementRef, HostListener, OnDestroy, OnInit, ViewChild, signal, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';

interface Block {
    width: number;
    x: number;
    y: number; // Bottom position
    color: string;
}

@Component({
    selector: 'app-serenity-tower',
    standalone: true,
    imports: [CommonModule, RouterLink],
    template: `
    <div class="h-full flex flex-col items-center justify-center animate-fade-in relative overflow-hidden bg-gradient-to-b from-blue-50 to-white">
      
      <!-- Header / Score -->
      <div class="absolute top-8 z-10 text-center">
        <h2 class="text-3xl font-bold text-eden-dark mb-1">Serenity Tower</h2>
        <p class="text-eden-primary font-medium tracking-wide text-xl">Score: {{ score() }}</p>
        <p class="text-gray-400 text-sm mt-1" *ngIf="!gameStarted()">Press Space or Click to Start</p>
      </div>

      <!-- Game Area -->
      <div #gameContainer class="relative w-full max-w-md h-[600px] border-b-4 border-gray-200 cursor-pointer touch-none" (mousedown)="handleInput($event)">
        
        <!-- Base -->
        <div class="absolute bottom-0 left-1/2 -translate-x-1/2 w-48 h-4 bg-gray-300 rounded-t-lg"></div>

        <!-- Stacked Blocks -->
        @for (block of blocks(); track $index) {
          <div class="absolute h-10 rounded-md transition-colors duration-500 shadow-sm"
               [style.width.px]="block.width"
               [style.left.px]="block.x"
               [style.bottom.px]="block.y"
               [style.background-color]="block.color">
          </div>
        }

        <!-- Current Moving Block -->
        @if (currentBlock() && !gameOver()) {
          <div class="absolute h-10 rounded-md shadow-lg"
               [style.width.px]="currentBlock()!.width"
               [style.left.px]="currentBlock()!.x"
               [style.bottom.px]="currentBlock()!.y"
               [style.background-color]="currentBlock()!.color">
          </div>
        }

        <!-- Game Over Overlay -->
        @if (gameOver()) {
           <div class="absolute inset-0 bg-white/60 backdrop-blur-sm flex flex-col items-center justify-center z-20 animate-fade-in">
              <h3 class="text-4xl font-bold text-gray-800 mb-2">Game Over</h3>
              <p class="text-xl text-eden-dark mb-6">You stacked {{ score() }} blocks!</p>
              
              <div class="flex gap-4">
                 <button (click)="restart()" class="bg-eden-mint hover:bg-eden-mint-dark text-white px-8 py-3 rounded-full font-bold shadow-lg transition transform hover:-translate-y-1">
                    Try Again
                 </button>
                 <a routerLink="/dashboard/games" class="bg-white text-gray-600 px-8 py-3 rounded-full font-bold shadow-md hover:bg-gray-50 transition border border-gray-100">
                    Exit
                 </a>
              </div>
           </div>
        }
      </div>

      <!-- Instruction / Footer -->
      <div class="mt-8 text-center text-gray-400 text-sm">
         Tap screen or press Spacebar to place the block at the right moment.
      </div>
      
       <a routerLink="/dashboard/games" class="absolute top-6 left-6 w-10 h-10 bg-white rounded-full flex items-center justify-center shadow-md text-gray-500 hover:text-eden-primary transition z-20">
          ←
       </a>

    </div>
  `,
    styles: [`
    :host {
      display: block;
      height: 100%;
    }
  `]
})
export class SerenityTowerComponent implements OnInit, OnDestroy {
    @ViewChild('gameContainer') gameContainer!: ElementRef;

    // Game State
    gameStarted = signal(false);
    gameOver = signal(false);
    score = signal(0);
    blocks = signal<Block[]>([]);
    currentBlock = signal<Block | null>(null);

    // Config
    private readonly BLOCK_HEIGHT = 40;
    private readonly BASE_WIDTH = 200;
    private readonly GAME_WIDTH = 448; // max-w-md approx
    private readonly MOVEMENT_SPEED_BASE = 2; // Pixels per frame

    // Animation State
    private animationId: number | null = null;
    private direction: 1 | -1 = 1;
    private speed = this.MOVEMENT_SPEED_BASE;
    private hue = 160; // Starting hue (mint-ish)

    constructor() { }

    ngOnInit(): void {
        // Initial setup
        this.resetGame();
    }

    ngOnDestroy(): void {
        this.stopGameLoop();
    }

    @HostListener('window:keydown', ['$event'])
    handleKeydown(event: KeyboardEvent) {
        if (event.code === 'Space') {
            this.handleInput();
        }
    }

    handleInput(event?: Event) {
        if (event) {
            event.preventDefault(); // Prevent double tap on touch
        }

        if (!this.gameStarted()) {
            this.startGame();
            return;
        }

        if (this.gameOver()) {
            return;
        }

        this.placeBlock();
    }

    resetGame() {
        this.gameOver.set(false);
        this.gameStarted.set(false);
        this.score.set(0);
        this.blocks.set([]);
        this.currentBlock.set(null);
        this.hue = 160;
        this.speed = this.MOVEMENT_SPEED_BASE;
    }

    restart() {
        this.resetGame();
        setTimeout(() => this.startGame(), 100);
    }

    startGame() {
        this.gameStarted.set(true);

        // Create base block (invisible logic-wise, but visual logic uses it)
        // Actually, let's just create the first moving block directly based on base width
        const startY = 20; // Just above base
        this.spawnBlock(this.BASE_WIDTH, startY);

        this.startGameLoop();
    }

    spawnBlock(width: number, y: number) {
        // Start from random side
        const startX = Math.random() > 0.5 ? 0 : this.GAME_WIDTH - width;
        this.direction = Math.random() > 0.5 ? 1 : -1;

        // Cycle colors
        this.hue = (this.hue + 10) % 360;
        const color = `hsl(${this.hue}, 70%, 65%)`;

        this.currentBlock.set({
            width,
            x: startX,
            y,
            color
        });
    }

    startGameLoop() {
        this.stopGameLoop();

        const loop = () => {
            this.update();
            this.animationId = requestAnimationFrame(loop);
        };
        this.animationId = requestAnimationFrame(loop);
    }

    stopGameLoop() {
        if (this.animationId) {
            cancelAnimationFrame(this.animationId);
            this.animationId = null;
        }
    }

    update() {
        const block = this.currentBlock();
        if (!block || this.gameOver()) return;

        // Move block
        let newX = block.x + (this.speed * this.direction);

        // Bounce off walls (or wrap? Tower stackers usually bounce)
        // Actually, usually they go back and forth
        const containerWidth = this.gameContainer?.nativeElement?.clientWidth || this.GAME_WIDTH;

        if (newX + block.width > containerWidth) {
            newX = containerWidth - block.width;
            this.direction = -1;
        } else if (newX < 0) {
            newX = 0;
            this.direction = 1;
        }

        this.currentBlock.update(b => b ? { ...b, x: newX } : null);
    }

    placeBlock() {
        const current = this.currentBlock();
        if (!current) return;

        const prevBlock = this.blocks().length > 0
            ? this.blocks()[this.blocks().length - 1]
            : { width: this.BASE_WIDTH, x: (this.getContainerWidth() - this.BASE_WIDTH) / 2 }; // Imaginary base block

        // Calculate overlap
        const currentLeft = current.x;
        const currentRight = current.x + current.width;
        const prevLeft = prevBlock.x!;
        const prevRight = prevBlock.x! + prevBlock.width;

        // Check if missed completely
        if (currentRight < prevLeft || currentLeft > prevRight) {
            this.triggerGameOver();
            return;
        }

        // Calculate cut
        let newWidth = current.width;
        let newX = current.x;

        const overlapLeft = Math.max(currentLeft, prevLeft);
        const overlapRight = Math.min(currentRight, prevRight);
        newWidth = overlapRight - overlapLeft;
        newX = overlapLeft;

        // Tolerance for 'perfect' placement
        const tolerance = 5;
        if (Math.abs(currentLeft - prevLeft) < tolerance) {
            newX = prevLeft;
            newWidth = prevBlock.width; // Recover full width of previous? Or just don't shrink? usually don't shrink.
            // Bonus effect here?
        }

        // Add to stack
        const placedBlock: Block = {
            ...current,
            x: newX,
            width: newWidth,
            y: current.y // Keep the y we were at
        };

        this.blocks.update(bs => [...bs, placedBlock]);
        this.score.update(s => s + 1);

        // Spawn next
        // Scroll down if too high?
        // For now, let's just let it go up. If it goes off screen, we might need to scroll the container.
        // Let's scroll the camera if y > 300
        if (placedBlock.y > 400) {
            this.shiftTowerDown();
        } else {
            this.spawnBlock(newWidth, placedBlock.y + this.BLOCK_HEIGHT);
        }

        // Speed up slightly
        this.speed += 0.2;
    }

    shiftTowerDown() {
        // visual shift not implemented fully in this simple version, 
        // but we can just spawn the next one at the same Y and move everyone else down?
        // easier: CSS transform the container or just modify Y of all blocks.

        this.blocks.update(bs => bs.map(b => ({ ...b, y: b.y - this.BLOCK_HEIGHT })));

        // The last placed block is now lower, so we spawn at the same Y as it *was* (which is now top)
        const last = this.blocks()[this.blocks().length - 1];
        this.spawnBlock(last.width, last.y + this.BLOCK_HEIGHT);
    }

    triggerGameOver() {
        this.gameOver.set(true);
        this.stopGameLoop();
    }

    getContainerWidth() {
        return this.gameContainer?.nativeElement?.clientWidth || this.GAME_WIDTH;
    }
}
