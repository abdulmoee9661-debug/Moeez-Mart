import React, { useState } from 'react';
import { ShoppingBag, Search, User, Menu, X, Phone, Heart } from 'lucide-react';

export default function StorefrontLayout({ children, cartCount = 0 }) {
  const [isMobileMenuOpen, setIsMobileMenuOpen] = useState(false);

  return (
    <div className="min-h-screen flex flex-col bg-slate-50 font-sans text-slate-800">
      {/* Top Banner */}
      <div className="bg-emerald-950 text-emerald-100 text-xs py-2 px-4 text-center flex justify-between items-center max-w-7xl mx-auto w-full">
        <span>🇵🇰 Free Express Shipping across Pakistan on orders over PKR 5,000!</span>
        <span className="hidden md:inline">Support: +92 300 1234567 | Support Hours: 9 AM - 9 PM PKT</span>
      </div>

      {/* Main Header */}
      <header className="sticky top-0 z-40 bg-white border-b border-slate-200 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-20 flex items-center justify-between">
          
          {/* Logo */}
          <div className="flex items-center gap-3">
            <button 
              onClick={() => setIsMobileMenuOpen(!isMobileMenuOpen)} 
              className="md:hidden p-2 text-slate-600 hover:text-emerald-900"
            >
              {isMobileMenuOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
            <a href="/" className="flex items-center gap-2 text-decoration-none">
              <div className="w-10 h-10 bg-emerald-900 rounded-lg flex items-center justify-center text-amber-400 font-serif font-bold text-xl shadow-md">
                M
              </div>
              <div>
                <span className="font-serif font-bold text-2xl tracking-tight text-emerald-950 block leading-none">
                  MOEEZ MART
                </span>
                <span className="text-[9px] tracking-widest uppercase font-semibold text-amber-600 block mt-1">
                  Abdul Moeez Commerce
                </span>
              </div>
            </a>
          </div>

          {/* Search Bar */}
          <div className="hidden md:flex flex-1 max-w-md mx-8">
            <div className="relative w-full">
              <input
                type="text"
                placeholder="Search electronics, fashion, home goods in PKR..."
                className="w-full pl-10 pr-4 py-2 text-sm border border-slate-300 rounded-full focus:outline-none focus:ring-2 focus:ring-emerald-800 focus:border-transparent transition-all"
              />
              <Search className="absolute left-3 top-2.5 text-slate-400" size={18} />
            </div>
          </div>

          {/* Header Action Items */}
          <div className="flex items-center gap-4">
            <a href="/wishlist" className="p-2 text-slate-600 hover:text-emerald-900 relative">
              <Heart size={22} />
            </a>
            <a href="/account" className="p-2 text-slate-600 hover:text-emerald-900">
              <User size={22} />
            </a>
            <a href="/cart" className="flex items-center gap-2 bg-emerald-900 text-white px-4 py-2 rounded-full hover:bg-emerald-800 transition-colors shadow-sm">
              <ShoppingBag size={18} />
              <span className="text-sm font-medium hidden sm:inline">Cart</span>
              {cartCount > 0 && (
                <span className="bg-amber-500 text-emerald-950 text-xs font-bold rounded-full h-5 w-5 flex items-center justify-center">
                  {cartCount}
                </span>
              )}
            </a>
          </div>
        </div>

        {/* Categories Navigation Bar */}
        <nav className="hidden md:block bg-slate-100 border-t border-slate-200">
          <div className="max-w-7xl mx-auto px-4 flex gap-8 py-2.5 text-sm font-medium text-slate-700">
            <a href="/shop" className="hover:text-emerald-800">All Products</a>
            <a href="/category/electronics" className="hover:text-emerald-800">Electronics</a>
            <a href="/category/fashion" className="hover:text-emerald-800">Men & Women Fashion</a>
            <a href="/category/home-kitchen" className="hover:text-emerald-800">Home & Kitchen</a>
            <a href="/category/beauty" className="hover:text-emerald-800">Beauty & Personal Care</a>
            <a href="/deals" className="text-amber-600 font-semibold hover:text-amber-700">Flash Deals 🔥</a>
          </div>
        </nav>
      </header>

      {/* Main Content Area */}
      <main className="flex-1 max-w-7xl mx-auto w-full px-4 sm:px-6 lg:px-8 py-8">
        {children}
      </main>

      {/* Footer */}
      <footer className="bg-emerald-950 text-slate-300 border-t border-emerald-900 mt-16">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12 grid grid-cols-1 md:grid-cols-4 gap-8">
          <div>
            <h3 className="text-white font-serif font-bold text-xl mb-4">Moeez Mart</h3>
            <p className="text-sm text-slate-400 mb-4 leading-relaxed">
              Your premier Pakistani online shopping hub. Delivering high-quality products directly to your doorstep with guaranteed reliability.
            </p>
            <p className="text-xs text-amber-400 font-semibold">Founded by Abdul Moeez</p>
          </div>
          <div>
            <h4 className="text-white text-sm font-semibold mb-4 uppercase tracking-wider">Customer Care</h4>
            <ul className="space-y-2 text-sm">
              <li><a href="/help" className="hover:text-amber-400">Help Center & FAQ</a></li>
              <li><a href="/track-order" className="hover:text-amber-400">Track Your Order</a></li>
              <li><a href="/returns" className="hover:text-amber-400">Returns & Exchanges</a></li>
              <li><a href="/shipping" className="hover:text-amber-400">Shipping Policies</a></li>
            </ul>
          </div>
          <div>
            <h4 className="text-white text-sm font-semibold mb-4 uppercase tracking-wider">Payment Partners</h4>
            <div className="flex flex-wrap gap-2 text-xs font-bold">
              <span className="bg-slate-800 px-3 py-1.5 rounded text-slate-200 border border-slate-700">Cash on Delivery</span>
              <span className="bg-red-900/60 text-red-200 px-3 py-1.5 rounded border border-red-800">JazzCash</span>
              <span className="bg-green-900/60 text-green-200 px-3 py-1.5 rounded border border-green-800">Easypaisa</span>
              <span className="bg-blue-900/60 text-blue-200 px-3 py-1.5 rounded border border-blue-800">Bank Transfer</span>
            </div>
          </div>
          <div>
            <h4 className="text-white text-sm font-semibold mb-4 uppercase tracking-wider">Store Contact</h4>
            <p className="text-sm text-slate-400">Headquarters: Gulberg III, Lahore, Pakistan</p>
            <p className="text-sm text-slate-400 mt-2">Email: support@moeezmart.pk</p>
          </div>
        </div>
        <div className="bg-emerald-900/40 py-4 text-center text-xs text-slate-400 border-t border-emerald-900">
          © {new Date().getFullYear()} Moeez Mart. All Rights Reserved. Built for Pakistan.
        </div>
      </footer>
    </div>
  );
}