class ChatApp {
    constructor() {
        this.apiKey = localStorage.getItem('chat_api_key') || '';
        this.botId = localStorage.getItem('chat_bot_id') || '';
        this.currentConversationId = null;
        this.messages = [];
        
        this.initializeElements();
        this.setupEventListeners();
        this.checkConfiguration();
    }

    initializeElements() {
        this.messagesContainer = document.getElementById('messages-container');
        this.messageInput = document.getElementById('message-input');
        this.sendBtn = document.getElementById('send-btn');
        this.conversationsList = document.getElementById('conversations-list');
        this.conversationTitle = document.getElementById('conversation-title');
        this.currentBotSpan = document.getElementById('current-bot');
        this.settingsModal = document.getElementById('settings-modal');
        this.apiKeyInput = document.getElementById('api-key-input');
        this.botIdInput = document.getElementById('bot-id-input');
        
        // New configuration display elements
        this.configDisplay = document.getElementById('config-display');
        this.configEdit = document.getElementById('config-edit');
        this.apiKeyDisplay = document.getElementById('api-key-display');
        this.botIdDisplay = document.getElementById('bot-id-display');
    }

    setupEventListeners() {
        // Send message
        this.sendBtn.addEventListener('click', () => this.sendMessage());
        this.messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') this.sendMessage();
        });

        // New conversation
        document.getElementById('new-conversation-btn').addEventListener('click', () => {
            this.createNewConversation();
        });

        // Settings - Edit mode
        document.getElementById('save-settings').addEventListener('click', () => {
            this.saveSettings();
        });

        document.getElementById('cancel-settings-edit').addEventListener('click', () => {
            this.cancelEditSettings();
        });

        // Settings - Display mode
        document.getElementById('edit-settings').addEventListener('click', () => {
            this.enterEditMode();
        });

        document.getElementById('cancel-settings-display').addEventListener('click', () => {
            this.hideSettings();
        });
    }

    checkConfiguration() {
        if (this.apiKey && this.botId) {
            this.enableChat();
            this.loadConversations();
            this.currentBotSpan.textContent = `ID: ${this.botId}`;
            this.updateStatusIndicator(true, 'Configurado');
        } else {
            this.updateStatusIndicator(false, 'Sin configurar');
            this.showSettings();
        }
    }

    updateStatusIndicator(isConfigured, text) {
        const indicator = document.getElementById('status-indicator');
        const statusText = document.getElementById('status-text');
        
        if (isConfigured) {
            indicator.className = 'w-2 h-2 bg-green-500 rounded-full mr-1';
            statusText.textContent = text;
        } else {
            indicator.className = 'w-2 h-2 bg-red-500 rounded-full mr-1';
            statusText.textContent = text;
        }
    }

    showSettings() {
        this.settingsModal.classList.remove('hidden');
        this.settingsModal.classList.add('flex');
        
        // Check if we have saved configuration
        if (this.apiKey && this.botId) {
            this.showDisplayMode();
        } else {
            this.showEditMode();
        }
    }

    showDisplayMode() {
        this.configDisplay.classList.remove('hidden');
        this.configEdit.classList.add('hidden');
        
        // Update display values
        this.apiKeyDisplay.textContent = this.apiKey ? this.maskApiKey(this.apiKey) : 'No configurada';
        this.botIdDisplay.textContent = this.botId || 'No configurado';
    }

    showEditMode() {
        this.configDisplay.classList.add('hidden');
        this.configEdit.classList.remove('hidden');
        
        // Populate current values
        this.apiKeyInput.value = this.apiKey;
        this.botIdInput.value = this.botId;
        
        // Focus on first empty field
        if (!this.apiKey) {
            this.apiKeyInput.focus();
        } else if (!this.botId) {
            this.botIdInput.focus();
        }
    }

    enterEditMode() {
        this.showEditMode();
    }

    cancelEditSettings() {
        if (this.apiKey && this.botId) {
            this.showDisplayMode();
        } else {
            this.hideSettings();
        }
    }

    hideSettings() {
        this.settingsModal.classList.add('hidden');
        this.settingsModal.classList.remove('flex');
    }

    maskApiKey(apiKey) {
        if (!apiKey || apiKey.length < 8) return apiKey;
        const start = apiKey.substring(0, 4);
        const end = apiKey.substring(apiKey.length - 4);
        const middle = '*'.repeat(Math.min(apiKey.length - 8, 20));
        return `${start}${middle}${end}`;
    }

    saveSettings() {
        const newApiKey = this.apiKeyInput.value.trim();
        const newBotId = this.botIdInput.value.trim();

        if (!newApiKey || !newBotId) {
            alert('Por favor, completa todos los campos');
            return;
        }

        // Save the values
        this.apiKey = newApiKey;
        this.botId = newBotId;

        localStorage.setItem('chat_api_key', this.apiKey);
        localStorage.setItem('chat_bot_id', this.botId);

        // Show success and switch to display mode
        this.showDisplayMode();
        this.enableChat();
        this.loadConversations();
        this.currentBotSpan.textContent = `ID: ${this.botId}`;
        this.updateStatusIndicator(true, 'Configurado');
        
        // Clear welcome message if exists
        if (this.messagesContainer.children.length === 1 && 
            this.messagesContainer.firstElementChild.classList.contains('text-center')) {
            this.messagesContainer.innerHTML = '';
        }

        // Show success message
        setTimeout(() => {
            this.hideSettings();
        }, 1000);
    }

    enableChat() {
        this.messageInput.disabled = false;
        this.sendBtn.disabled = false;
    }

    async sendMessage() {
        const message = this.messageInput.value.trim();
        if (!message) return;

        this.addMessage('user', message);
        this.messageInput.value = '';
        this.setLoading(true);

        try {
            const response = await axios.post('/chat/send_message', {
                message: message,
                bot_id: this.botId,
                conversation_id: this.currentConversationId,
                auto_create_conversation: this.currentConversationId ? 'false' : 'true'
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            if (response.data.success) {
                this.addMessage('assistant', response.data.response);
                
                if (response.data.conversation_id && !this.currentConversationId) {
                    this.currentConversationId = response.data.conversation_id;
                    this.loadConversations();
                }
            } else {
                throw new Error(response.data.error || 'Error desconocido');
            }
        } catch (error) {
            console.error('Error:', error);
            this.addMessage('system', `Error: ${error.response?.data?.error || error.message}`);
        } finally {
            this.setLoading(false);
        }
    }

    addMessage(role, content) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `flex ${role === 'user' ? 'justify-end' : 'justify-start'}`;
        
        const messageClass = {
            'user': 'bg-blue-500 text-white',
            'assistant': 'bg-white text-gray-800 border border-gray-200',
            'system': 'bg-red-100 text-red-800 border border-red-200'
        };

        messageDiv.innerHTML = `
            <div class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${messageClass[role]}">
                <p class="text-sm whitespace-pre-wrap">${this.escapeHtml(content)}</p>
                <p class="text-xs opacity-70 mt-1">${new Date().toLocaleTimeString()}</p>
            </div>
        `;

        this.messagesContainer.appendChild(messageDiv);
        this.messagesContainer.scrollTop = this.messagesContainer.scrollHeight;
    }

    setLoading(loading) {
        if (loading) {
            this.sendBtn.disabled = true;
            this.sendBtn.textContent = 'Enviando...';
            this.messageInput.disabled = true;
        } else {
            this.sendBtn.disabled = false;
            this.sendBtn.textContent = 'Enviar';
            this.messageInput.disabled = false;
            this.messageInput.focus();
        }
    }

    async loadConversations() {
        try {
            const response = await axios.get('/chat/conversations', {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                params: {
                    bot_id: this.botId
                }
            });

            if (response.data.success) {
                this.renderConversations(response.data.conversations);
            }
        } catch (error) {
            console.error('Error loading conversations:', error);
        }
    }

    renderConversations(conversations) {
        this.conversationsList.innerHTML = '';
        
        if (conversations.length === 0) {
            this.conversationsList.innerHTML = `
                <div class="p-4 text-center text-gray-500">
                    <p class="text-sm">No hay conversaciones aún</p>
                    <p class="text-xs mt-1">Crea una nueva para empezar</p>
                </div>
            `;
            return;
        }
        
        conversations.forEach(conv => {
            const convDiv = document.createElement('div');
            convDiv.className = `p-3 border-b border-gray-100 cursor-pointer hover:bg-gray-50 ${
                conv.id === this.currentConversationId ? 'bg-blue-50 border-l-4 border-l-blue-500' : ''
            }`;
            
            convDiv.innerHTML = `
                <h4 class="font-medium text-sm text-gray-800 truncate">${this.escapeHtml(conv.title)}</h4>
                <p class="text-xs text-gray-500 mt-1">${conv.message_count} mensajes</p>
                <p class="text-xs text-gray-400">${new Date(conv.updated_at).toLocaleDateString()}</p>
            `;
            
            convDiv.addEventListener('click', () => this.selectConversation(conv));
            this.conversationsList.appendChild(convDiv);
        });
    }

    async selectConversation(conversation) {
        this.currentConversationId = conversation.id;
        this.conversationTitle.textContent = conversation.title;
        this.messagesContainer.innerHTML = '';
        
        try {
            const response = await axios.get('/chat/conversation_history', {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'X-Requested-With': 'XMLHttpRequest'
                },
                params: {
                    conversation_id: conversation.id,
                    bot_id: this.botId
                }
            });

            if (response.data.success) {
                response.data.messages.forEach(msg => {
                    this.addMessageFromHistory(msg.role, msg.content, msg.timestamp);
                });
            }
        } catch (error) {
            console.error('Error loading conversation history:', error);
            this.addMessage('system', 'Error cargando el historial de la conversación');
        }
        
        this.loadConversations(); // Refresh sidebar
    }

    addMessageFromHistory(role, content, timestamp) {
        const messageDiv = document.createElement('div');
        messageDiv.className = `flex ${role === 'user' ? 'justify-end' : 'justify-start'}`;
        
        const messageClass = {
            'user': 'bg-blue-500 text-white',
            'assistant': 'bg-white text-gray-800 border border-gray-200'
        };

        messageDiv.innerHTML = `
            <div class="max-w-xs lg:max-w-md px-4 py-2 rounded-lg ${messageClass[role]}">
                <p class="text-sm whitespace-pre-wrap">${this.escapeHtml(content)}</p>
                <p class="text-xs opacity-70 mt-1">${new Date(timestamp).toLocaleTimeString()}</p>
            </div>
        `;

        this.messagesContainer.appendChild(messageDiv);
    }

    async createNewConversation() {
        const title = prompt('Título de la conversación:') || `Chat ${new Date().toLocaleTimeString()}`;
        
        try {
            const response = await axios.post('/chat/create_conversation', {
                title: title,
                bot_id: this.botId
            }, {
                headers: {
                    'Authorization': `Bearer ${this.apiKey}`,
                    'Content-Type': 'application/json',
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            if (response.data.success) {
                this.currentConversationId = response.data.conversation.id;
                this.conversationTitle.textContent = response.data.conversation.title;
                this.messagesContainer.innerHTML = '';
                this.loadConversations();
            } else {
                alert('Error creando conversación: ' + response.data.error);
            }
        } catch (error) {
            alert('Error: ' + (error.response?.data?.error || error.message));
        }
    }

    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
}

// Initialize the app
document.addEventListener('DOMContentLoaded', () => {
    new ChatApp();
});
