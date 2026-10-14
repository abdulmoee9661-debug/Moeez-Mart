import React, { useState } from 'react';
import { MessageSquare, X, Send, Bot } from 'lucide-react';

export default function StorefrontSupportChat() {
  const [isOpen, setIsOpen] = useState(false);
  const [messages, setMessages] = useState([
    { sender: 'bot', text: 'Assalamu Alaikum! Welcome to Moeez Mart support. How can I assist you with your order today?' }
  ]);
  const [input, setInput] = useState('');

  const handleSend = () => {
    if (!input.trim()) return;

    const userMsg = { sender: 'customer', text: input };
    setMessages(prev => [...prev, userMsg]);
    const currentQuery = input.toLowerCase();
    setInput('');

    // Rule-based decision engine using verified store knowledge
    setTimeout(() => {
      let reply = "I've passed your inquiry to our support team. Abdul Moeez's staff will respond shortly.";
      
      if (currentQuery.includes('shipping') || currentQuery.includes('delivery')) {
        reply = "We offer nationwide shipping across Pakistan! Delivery takes 2-4 business days for major cities (Lahore, Karachi, Islamabad) and 3-6 days for other regions. Shipping is free for orders over PKR 5,000.";
      } else if (currentQuery.includes('payment') || currentQuery.includes('cod')) {
        reply = "We support Cash on Delivery (COD), JazzCash, Easypaisa, and Direct Bank Transfers. You can select your preferred method at checkout.";
      } else if (currentQuery.includes('return') || currentQuery.includes('refund')) {
        reply = "Moeez Mart offers a 7-day hassle-free return policy for unused items in original packaging. Contact us here or via WhatsApp (+92 300 1234567) to initiate a return.";
      }

      setMessages(prev => [...prev, { sender: 'bot', text: reply }]);
    }, 600);
  };

  return (
    <div className="fixed bottom-6 right-6 z-50">
      {!isOpen ? (
        <button
          onClick={() => setIsOpen(true)}
          className="bg-emerald-900 text-white p-4 rounded-full shadow-2xl hover:bg-emerald-800 flex items-center gap-2 border-2 border-amber-400 transition-all transform hover:scale-105"
        >
          <MessageSquare size={24} />
          <span className="text-sm font-semibold pr-1">Chat Support</span>
        </button>
      ) : (
        <div className="bg-white rounded-2xl shadow-2xl w-80 sm:w-96 border border-slate-200 overflow-hidden flex flex-col h-[480px]">
          {/* Header */}
          <div className="bg-emerald-900 text-white p-4 flex justify-between items-center">
            <div className="flex items-center gap-2">
              <Bot className="text-amber-400" size={20} />
              <div>
                <h3 className="font-bold text-sm">Moeez Mart Support</h3>
                <p className="text-[10px] text-emerald-200">Online | Typical reply in mins</p>
              </div>
            </div>
            <button onClick={() => setIsOpen(false)} className="text-emerald-200 hover:text-white">
              <X size={20} />
            </button>
          </div>

          {/* Messages Body */}
          <div className="flex-1 p-4 overflow-y-auto space-y-3 bg-slate-50 text-sm">
            {messages.map((m, idx) => (
              <div
                key={idx}
                className={`flex ${m.sender === 'customer' ? 'justify-end' : 'justify-start'}`}
              >
                <div
                  className={`max-w-[80%] rounded-xl px-3.5 py-2 leading-relaxed ${
                    m.sender === 'customer'
                      ? 'bg-emerald-900 text-white rounded-br-none'
                      : 'bg-white text-slate-800 border border-slate-200 rounded-bl-none shadow-sm'
                  }`}
                >
                  {m.text}
                </div>
              </div>
            ))}
          </div>

          {/* Input Area */}
          <div className="p-3 bg-white border-t border-slate-200 flex gap-2">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSend()}
              placeholder="Ask about shipping, COD, returns..."
              className="flex-1 text-sm border border-slate-300 rounded-lg px-3 py-2 focus:outline-none focus:ring-1 focus:ring-emerald-800"
            />
            <button
              onClick={handleSend}
              className="bg-emerald-900 text-white p-2 rounded-lg hover:bg-emerald-800 transition-colors"
            >
              <Send size={18} />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}