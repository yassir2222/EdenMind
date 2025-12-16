import { Injectable, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';

export interface Message {
    id?: string;
    content: string;
    sender: 'USER' | 'BOT'; // Adjust based on backend enum
    timestamp?: string;
}

export interface Conversation {
    id: string;
    summary?: string; // or title
    createdAt?: string;
}

@Injectable({
    providedIn: 'root'
})
export class ChatService {
    private http = inject(HttpClient);

    conversations = signal<Conversation[]>([]);
    activeConversationId = signal<string | null>(null);
    messages = signal<Message[]>([]);
    isLoading = signal<boolean>(false);

    loadConversations() {
        // Backend endpoint /api/chat/conversations returns 500 due to infinite recursion.
        // Mocking as empty list to allow UI to load.
        console.warn('Backend /api/chat/conversations is broken (recursion). Mocking empty list.');
        this.conversations.set([]);
    }

    selectConversation(id: string) {
        this.activeConversationId.set(id);
        this.loadMessages(id);
    }

    loadMessages(conversationId: string) {
        this.isLoading.set(true);
        // Backend endpoint /api/chat/conversations/{id}/messages returns 500 due to infinite recursion.
        // Mocking as empty list.
        console.warn('Backend /api/chat/conversations/:id/messages is broken (recursion). Mocking empty list.');
        
        // Simulate network delay
        setTimeout(() => {
            this.messages.set([]);
            this.isLoading.set(false);
        }, 500);
    }

    sendMessage(query: string) {
        const convId = this.activeConversationId();

        // Optimistic UI update
        const userMsg: Message = { content: query, sender: 'USER', timestamp: new Date().toISOString() };
        this.messages.update(msgs => [...msgs, userMsg]);
        this.isLoading.set(true);

        this.http.post<any>('/api/chat/query', { query, conversationId: convId }).subscribe({
            next: (res) => {
                // Backend returns { answer: "...", conversationId: 123 }
                const botMsg: Message = {
                    content: res.answer,
                    sender: 'BOT',
                    timestamp: new Date().toISOString()
                };
                
                this.messages.update(msgs => [...msgs, botMsg]);
                
                if (res.conversationId && !convId) {
                    this.activeConversationId.set(res.conversationId);
                    // Do NOT call loadConversations() as it crashes
                }
                this.isLoading.set(false);
            },
            error: (err) => {
                console.error('Send message failed', err);
                this.isLoading.set(false);
                // Optionally add an error message to the chat
                const errorMsg: Message = {
                    content: "Sorry, I couldn't reach the server. Please try again.",
                    sender: 'BOT',
                    timestamp: new Date().toISOString()
                };
                this.messages.update(msgs => [...msgs, errorMsg]);
            }
        });
    }

    startNewChat() {
        this.activeConversationId.set(null);
        this.messages.set([]);
    }
}
