-- ==============================================================================
-- MOEEZ MART COMPLETE DATABASE SCHEMA & SECURITY POLICIES
-- Target: PostgreSQL 15+ / Supabase
-- ==============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ------------------------------------------------------------------------------
-- 1. ENUMS & DOMAINS
-- ------------------------------------------------------------------------------
CREATE TYPE user_role AS ENUM ('super_admin', 'store_manager', 'support_agent', 'customer');
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'processing', 'shipped', 'out_for_delivery', 'delivered', 'cancelled', 'returned', 'refunded');
CREATE TYPE payment_method AS ENUM ('cod', 'jazzcash', 'easypaisa', 'bank_transfer');
CREATE TYPE payment_status AS ENUM ('pending', 'authorized', 'captured', 'failed', 'refunded');
CREATE TYPE discount_type AS ENUM ('fixed_amount', 'percentage');

-- ------------------------------------------------------------------------------
-- 2. CORE USERS & PROFILES
-- ------------------------------------------------------------------------------
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name TEXT NOT NULL,
    phone_number TEXT UNIQUE NOT NULL,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    role user_role NOT NULL DEFAULT 'customer',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, role)
);

CREATE TABLE public.addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    title TEXT DEFAULT 'Home', -- Home, Office, etc.
    recipient_name TEXT NOT NULL,
    phone TEXT NOT NULL,
    street_address TEXT NOT NULL,
    nearest_landmark TEXT,
    city TEXT NOT NULL,
    province TEXT NOT NULL DEFAULT 'Punjab',
    postal_code TEXT,
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 3. PRODUCT CATALOG
-- ------------------------------------------------------------------------------
CREATE TABLE public.categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    description TEXT,
    image_url TEXT,
    parent_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    slug TEXT UNIQUE NOT NULL,
    sku TEXT UNIQUE NOT NULL,
    description TEXT NOT NULL,
    short_description TEXT,
    category_id UUID REFERENCES public.categories(id) ON DELETE SET NULL,
    base_price NUMERIC(12, 2) NOT NULL CHECK (base_price >= 0),
    sale_price NUMERIC(12, 2) CHECK (sale_price IS NULL OR sale_price < base_price),
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    low_stock_threshold INT NOT NULL DEFAULT 5,
    is_featured BOOLEAN DEFAULT FALSE,
    is_published BOOLEAN DEFAULT FALSE,
    brand_name TEXT DEFAULT 'Moeez Mart',
    weight_kg NUMERIC(6, 2) DEFAULT 0.5,
    meta_title TEXT,
    meta_description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.product_images (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    alt_text TEXT,
    display_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.product_variants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    sku TEXT UNIQUE NOT NULL,
    option_name TEXT NOT NULL, -- e.g., "Size", "Color"
    option_value TEXT NOT NULL, -- e.g., "XL", "Navy Blue"
    price_adjustment NUMERIC(12, 2) DEFAULT 0.00,
    stock_quantity INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 4. CARTS, WISHLISTS & MARKETING
-- ------------------------------------------------------------------------------
CREATE TABLE public.carts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES public.profiles(id) ON DELETE CASCADE,
    session_token TEXT UNIQUE, -- For guest cart sync
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.cart_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    cart_id UUID NOT NULL REFERENCES public.carts(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(cart_id, product_id, variant_id)
);

CREATE TABLE public.wishlists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, product_id)
);

CREATE TABLE public.coupons (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code TEXT UNIQUE NOT NULL,
    discount_type discount_type NOT NULL,
    discount_amount NUMERIC(12, 2) NOT NULL CHECK (discount_amount > 0),
    min_order_value NUMERIC(12, 2) DEFAULT 0,
    max_discount_amount NUMERIC(12, 2), -- Useful for percentage caps
    usage_limit INT,
    used_count INT DEFAULT 0,
    starts_at TIMESTAMPTZ NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 5. ORDERS & PAYMENTS
-- ------------------------------------------------------------------------------
CREATE TABLE public.orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_number TEXT UNIQUE NOT NULL,
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    customer_name TEXT NOT NULL,
    customer_email TEXT NOT NULL,
    customer_phone TEXT NOT NULL,
    shipping_address_json JSONB NOT NULL,
    subtotal_pkr NUMERIC(12, 2) NOT NULL,
    shipping_cost_pkr NUMERIC(12, 2) NOT NULL DEFAULT 0,
    discount_amount_pkr NUMERIC(12, 2) DEFAULT 0,
    total_amount_pkr NUMERIC(12, 2) NOT NULL,
    status order_status NOT NULL DEFAULT 'pending',
    payment_method payment_method NOT NULL,
    payment_status payment_status NOT NULL DEFAULT 'pending',
    coupon_id UUID REFERENCES public.coupons(id),
    delivery_notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    product_id UUID REFERENCES public.products(id) ON DELETE SET NULL,
    variant_id UUID REFERENCES public.product_variants(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    variant_info TEXT,
    unit_price_pkr NUMERIC(12, 2) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    total_price_pkr NUMERIC(12, 2) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    provider payment_method NOT NULL,
    transaction_id TEXT UNIQUE,
    merchant_reference TEXT UNIQUE NOT NULL,
    amount_pkr NUMERIC(12, 2) NOT NULL,
    payload_response JSONB,
    status payment_status NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.shipments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
    courier_name TEXT NOT NULL DEFAULT 'Manual Dispatch', -- e.g., TCS, Leopard, CallCourier
    tracking_number TEXT UNIQUE,
    shipped_at TIMESTAMPTZ,
    estimated_delivery TIMESTAMPTZ,
    delivered_at TIMESTAMPTZ,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 6. REVIEWS, CHAT & AUDIT LOGS
-- ------------------------------------------------------------------------------
CREATE TABLE public.reviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    is_verified_purchase BOOLEAN DEFAULT FALSE,
    is_approved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.support_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    session_id TEXT, -- For guest chats
    status TEXT DEFAULT 'open', -- open, resolved, closed
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.support_messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    conversation_id UUID NOT NULL REFERENCES public.support_conversations(id) ON DELETE CASCADE,
    sender_type TEXT NOT NULL, -- 'customer', 'agent', 'bot'
    sender_id UUID,
    message_text TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE TABLE public.admin_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
    action TEXT NOT NULL,
    entity_type TEXT NOT NULL,
    entity_id UUID,
    changes JSONB,
    ip_address TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ------------------------------------------------------------------------------
-- 7. HELPER FUNCTIONS & TRIGGERS (ATOMIC STOCK & AUTHORIZATION)
-- ------------------------------------------------------------------------------

-- Helper to verify admin privileges in security policies
CREATE OR REPLACE FUNCTION public.is_admin(user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles 
    WHERE user_roles.user_id = $1 AND role IN ('super_admin', 'store_manager')
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Atomic Stock Decrementing Function
CREATE OR REPLACE FUNCTION public.decrement_product_stock(
    p_product_id UUID, 
    p_variant_id UUID, 
    p_quantity INT
)
RETURNS VOID AS $$
BEGIN
    IF p_variant_id IS NOT NULL THEN
        UPDATE public.product_variants
        SET stock_quantity = stock_quantity - p_quantity
        WHERE id = p_variant_id AND stock_quantity >= p_quantity;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient variant stock for ID %', p_variant_id;
        END IF;
    ELSE
        UPDATE public.products
        SET stock_quantity = stock_quantity - p_quantity
        WHERE id = p_product_id AND stock_quantity >= p_quantity;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Insufficient product stock for ID %', p_product_id;
        END IF;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ------------------------------------------------------------------------------
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ------------------------------------------------------------------------------
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;

-- Profiles: Users manage their own profiles; Admins view all.
CREATE POLICY "Users view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id OR public.is_admin(auth.uid()));
CREATE POLICY "Users update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Products: Public view for published products; Admins full control.
CREATE POLICY "Public view published products" ON public.products FOR SELECT USING (is_published = true OR public.is_admin(auth.uid()));
CREATE POLICY "Admin manage products" ON public.products FOR ALL USING (public.is_admin(auth.uid()));

-- Orders: Users view their own orders; Admins view/manage all.
CREATE POLICY "Users view own orders" ON public.orders FOR SELECT USING (auth.uid() = user_id OR public.is_admin(auth.uid()));
CREATE POLICY "Users insert orders" ON public.orders FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
CREATE POLICY "Admin update orders" ON public.orders FOR UPDATE USING (public.is_admin(auth.uid()));

-- Reviews: Approved reviews are public; Users create own; Admins manage all.
CREATE POLICY "Public view approved reviews" ON public.reviews FOR SELECT USING (is_approved = true OR auth.uid() = user_id OR public.is_admin(auth.uid()));
CREATE POLICY "Users create reviews" ON public.reviews FOR INSERT WITH CHECK (auth.uid() = user_id);