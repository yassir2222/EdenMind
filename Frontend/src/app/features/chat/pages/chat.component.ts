import { Component, inject, OnInit, ViewChild, ElementRef, effect } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ChatService } from '../../../core/services/chat.service';

@Component({
  selector: 'app-chat',
  standalone: true,
  imports: [CommonModule, FormsModule],
  template: `
    <div class="h-[calc(100vh-100px)] flex flex-col bg-white rounded-3xl overflow-hidden shadow-sm relative">
       <!-- Header (Bot Info) -->
       <div class="bg-white p-6 border-b border-gray-100 flex items-center justify-between sticky top-0 z-10">
          <div class="flex items-center gap-4">
             <div class="relative">
                 <div class="w-12 h-12 bg-eden-mint rounded-full flex items-center justify-center text-white overflow-hidden shadow-sm">
                    <!-- Bot Avatar Placeholder -->
                    <img src="https://api.dicebear.com/7.x/bottts/svg?seed=Eden" class="w-full h-full p-1" alt="Bot">
                 </div>
                 <div class="absolute bottom-0 right-0 w-3 h-3 bg-green-500 border-2 border-white rounded-full"></div>
             </div>
             <div>
                <h2 class="font-bold text-gray-900 text-lg">EdenMindBot</h2>
                <p class="text-gray-400 text-xs font-medium">Therapeutic Companion</p>
             </div>
          </div>
          
          <div class="flex gap-2">
             <button class="p-2 text-gray-400 hover:bg-gray-50 rounded-full transition"><span class="material-icons">📊</span></button>
             <button class="p-2 text-gray-400 hover:bg-gray-50 rounded-full transition"><span class="material-icons">⚙️</span></button>
          </div>
       </div>

       <!-- Chat Area -->
       <div class="flex-1 overflow-y-auto p-6 bg-gray-50 space-y-6" #scrollContainer>
           
           <div class="flex justify-center my-4">
              <span class="bg-gray-200 text-gray-500 text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider">Today</span>
           </div>

           @if (chatService.messages().length === 0 && !chatService.isLoading()) {
              <div class="mt-20 flex flex-col items-center justify-center text-gray-400">
                 <div class="w-20 h-20 bg-eden-mint-light rounded-full flex items-center justify-center mb-6 animate-pulse">
                    <span class="text-4xl">👋</span>
                 </div>
                 <p class="font-medium text-lg text-gray-500">How are you feeling right now?</p>
                 <p class="text-sm text-gray-400 mt-2">I'm here to listen.</p>
              </div>
           }

           @for (msg of chatService.messages(); track msg.id || $index) {
             <div class="flex w-full" [ngClass]="{'justify-end': msg.sender === 'USER', 'justify-start': msg.sender === 'BOT'}">
               <!-- Bot Message -->
               @if (msg.sender === 'BOT') {
                 <div class="flex gap-3 max-w-[80%] lg:max-w-[70%] animate-fade-in-up">
                    <div class="w-8 h-8 flex-shrink-0 rounded-full overflow-hidden bg-eden-mint mt-1">
                       <img src="https://api.dicebear.com/7.x/bottts/svg?seed=Eden" class="w-full h-full p-0.5" alt="Bot">
                    </div>
                    <div class="bg-white p-5 rounded-2xl rounded-tl-none shadow-sm text-gray-700 leading-relaxed border border-gray-100">
                       {{ msg.content }}
                    </div>
                 </div>
               }
               
               <!-- User Message -->
               @if (msg.sender === 'USER') {
                 <div class="bg-eden-blue text-white p-5 rounded-2xl rounded-tr-none shadow-md max-w-[80%] lg:max-w-[70%] leading-relaxed animate-fade-in-up">
                    {{ msg.content }}
                 </div>
               }
             </div>
           }

           <!-- Typing Indicator -->
           @if (chatService.isLoading()) {
              <div class="flex gap-3 max-w-[80%] animate-pulse">
                 <div class="w-8 h-8 flex-shrink-0 rounded-full overflow-hidden bg-eden-mint mt-1">
                    <img src="https://api.dicebear.com/7.x/bottts/svg?seed=Eden" class="w-full h-full p-0.5" alt="Bot">
                 </div>
                 <div class="bg-transparent text-gray-400 text-sm italic pt-2">
                    EdenMindBot is typing...
                 </div>
              </div>
           }
       </div>

       <!-- Input Area -->
       <div class="bg-white p-6 border-t border-gray-100">
           <!-- Suggested Actions Chips -->
           <div class="flex gap-2 mb-4 overflow-x-auto pb-2 scrollbar-none">
              <button (click)="quickReply('I feel anxious')" class="whitespace-nowrap bg-blue-50 text-blue-600 px-4 py-2 rounded-full text-sm font-bold hover:bg-blue-100 transition">Je me sens anxieux</button>
              <button (click)="quickReply('Breathing exercise')" class="whitespace-nowrap bg-blue-50 text-blue-600 px-4 py-2 rounded-full text-sm font-bold hover:bg-blue-100 transition">Exercice de respiration</button>
              <button (click)="quickReply('Need motivation')" class="whitespace-nowrap bg-blue-50 text-blue-600 px-4 py-2 rounded-full text-sm font-bold hover:bg-blue-100 transition">Besoin de motivation</button>
              <button (click)="quickReply('Just chatting')" class="whitespace-nowrap bg-blue-50 text-blue-600 px-4 py-2 rounded-full text-sm font-bold hover:bg-blue-100 transition">Juste discuter</button>
           </div>
           
           <form (ngSubmit)="sendMessage()" class="relative flex items-center">
             <button type="button" class="absolute left-4 text-gray-400 hover:text-gray-600 transition">
                <span class="text-xl">+</span>
             </button>
             <input [(ngModel)]="newMessage" name="message" type="text" 
                    class="w-full pl-12 pr-14 py-4 rounded-full bg-gray-50 border-none focus:ring-0 focus:bg-gray-100 transition text-gray-700 placeholder-gray-400"
                    placeholder="Partagez vos pensées..." required [disabled]="chatService.isLoading()">
             
             <div class="absolute right-2 flex items-center gap-2">
                 <button type="button" class="p-2 text-gray-400 hover:text-gray-600 transition">
                    🎤
                 </button>
                 <button type="submit" [disabled]="!newMessage.trim() || chatService.isLoading()" 
                         class="bg-eden-blue hover:bg-blue-600 text-white w-10 h-10 rounded-full shadow-md flex items-center justify-center transition transform active:scale-95 disabled:opacity-50 disabled:cursor-not-allowed">
                   <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5 ml-0.5">
                      <path d="M3.478 2.405a.75.75 0 00-.926.94l2.432 7.905H13.5a.75.75 0 010 1.5H4.984l-2.432 7.905a.75.75 0 00.926.94 60.519 60.519 0 0018.445-8.986.75.75 0 000-1.218A60.517 60.517 0 003.478 2.405z" />
                    </svg>
                 </button>
             </div>
           </form>
           <p class="text-center text-[10px] text-gray-300 mt-2">EdenMindBot est une IA de soutien. En cas d'urgence médicale, contactez les services appropriés.</p>
       </div>
    </div>
  `
})
export class ChatComponent implements OnInit {
  chatService = inject(ChatService);
  newMessage = '';
  @ViewChild('scrollContainer') scrollContainer!: ElementRef;

  constructor() {
    effect(() => {
      this.chatService.messages();
      setTimeout(() => this.scrollToBottom(), 100);
    });
  }

  ngOnInit() {
    this.chatService.loadConversations();
  }

  quickReply(text: string) {
    this.newMessage = text;
    // Optional: Auto send
    // this.sendMessage();
  }

  sendMessage() {
    if (this.newMessage.trim()) {
      this.chatService.sendMessage(this.newMessage);
      this.newMessage = '';
    }
  }

  scrollToBottom() {
    if (this.scrollContainer) {
      this.scrollContainer.nativeElement.scrollTop = this.scrollContainer.nativeElement.scrollHeight;
    }
  }
}
