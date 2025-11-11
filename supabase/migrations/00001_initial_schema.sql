-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Users table (extends Supabase auth.users)
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT UNIQUE,
    age INTEGER NOT NULL,
    sex TEXT NOT NULL CHECK (sex IN ('male', 'female', 'other')),
    height DECIMAL NOT NULL, -- in cm
    weight DECIMAL NOT NULL, -- in kg
    body_fat_percentage DECIMAL,
    fitness_goal TEXT NOT NULL CHECK (fitness_goal IN ('bulk', 'cut', 'recomp', 'maintain')),
    experience_level TEXT NOT NULL CHECK (experience_level IN ('beginner', 'intermediate', 'advanced')),
    tdee DECIMAL,
    target_calories DECIMAL,
    target_protein DECIMAL,
    target_carbs DECIMAL,
    target_fat DECIMAL,
    profile_image_url TEXT,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Exercises table
CREATE TABLE public.exercises (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL UNIQUE,
    category TEXT NOT NULL CHECK (category IN ('strength', 'cardio', 'flexibility', 'sports')),
    muscle_group TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('compound', 'isolation', 'cardio')),
    equipment TEXT NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false, -- For seeded exercises
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User exercise stats (personal bests, favorites)
CREATE TABLE public.user_exercise_stats (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    is_favorite BOOLEAN DEFAULT false,
    times_performed INTEGER DEFAULT 0,
    last_performed TIMESTAMPTZ,
    personal_best DECIMAL,
    personal_best_date TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, exercise_id)
);

-- Workout sessions
CREATE TABLE public.workout_sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    notes TEXT,
    overall_rating INTEGER CHECK (overall_rating BETWEEN 1 AND 10),
    is_completed BOOLEAN DEFAULT false,
    focus_area TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Workout sets
CREATE TABLE public.workout_sets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    session_id UUID NOT NULL REFERENCES public.workout_sessions(id) ON DELETE CASCADE,
    exercise_id UUID NOT NULL REFERENCES public.exercises(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    set_number INTEGER NOT NULL,
    weight DECIMAL NOT NULL,
    reps INTEGER NOT NULL,
    rpe INTEGER CHECK (rpe BETWEEN 1 AND 10),
    is_warmup BOOLEAN DEFAULT false,
    is_failure BOOLEAN DEFAULT false,
    rest_time INTEGER, -- in seconds
    notes TEXT,
    completed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Nutrition entries
CREATE TABLE public.nutrition_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    food_name TEXT NOT NULL,
    serving_size DECIMAL NOT NULL,
    calories DECIMAL NOT NULL,
    protein DECIMAL NOT NULL,
    carbs DECIMAL NOT NULL,
    fat DECIMAL NOT NULL,
    fiber DECIMAL,
    sugar DECIMAL,
    meal_type TEXT NOT NULL CHECK (meal_type IN ('breakfast', 'lunch', 'dinner', 'snack')),
    is_custom_food BOOLEAN DEFAULT false,
    notes TEXT,
    consumed_at TIMESTAMPTZ DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ DEFAULT NOW()
);

-- Sleep entries
CREATE TABLE public.sleep_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    sleep_date DATE NOT NULL,
    hours_slept DECIMAL NOT NULL,
    sleep_quality INTEGER NOT NULL CHECK (sleep_quality BETWEEN 1 AND 10),
    soreness_level INTEGER NOT NULL CHECK (soreness_level BETWEEN 1 AND 10),
    energy_level INTEGER NOT NULL CHECK (energy_level BETWEEN 1 AND 10),
    stress_level INTEGER NOT NULL CHECK (stress_level BETWEEN 1 AND 10),
    had_restlessness BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, sleep_date)
);

-- Training crews
CREATE TABLE public.crews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    creator_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    invite_code TEXT UNIQUE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crew members
CREATE TABLE public.crew_members (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crew_id UUID NOT NULL REFERENCES public.crews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    joined_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(crew_id, user_id)
);

-- Crew challenges
CREATE TABLE public.crew_challenges (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    crew_id UUID NOT NULL REFERENCES public.crews(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    type TEXT NOT NULL CHECK (type IN ('volume', 'consistency', 'pr')),
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Crew challenge scores
CREATE TABLE public.crew_challenge_scores (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    challenge_id UUID NOT NULL REFERENCES public.crew_challenges(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    score DECIMAL DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(challenge_id, user_id)
);

-- Sync queue for offline changes
CREATE TABLE public.sync_queue (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    table_name TEXT NOT NULL,
    record_id UUID NOT NULL,
    operation TEXT NOT NULL CHECK (operation IN ('insert', 'update', 'delete')),
    data JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    synced BOOLEAN DEFAULT false,
    synced_at TIMESTAMPTZ
);

-- Indexes for performance
CREATE INDEX idx_workout_sessions_user_id ON public.workout_sessions(user_id);
CREATE INDEX idx_workout_sessions_start_time ON public.workout_sessions(start_time);
CREATE INDEX idx_workout_sets_session_id ON public.workout_sets(session_id);
CREATE INDEX idx_workout_sets_user_id ON public.workout_sets(user_id);
CREATE INDEX idx_workout_sets_exercise_id ON public.workout_sets(exercise_id);
CREATE INDEX idx_nutrition_entries_user_id ON public.nutrition_entries(user_id);
CREATE INDEX idx_nutrition_entries_consumed_at ON public.nutrition_entries(consumed_at);
CREATE INDEX idx_sleep_entries_user_id ON public.sleep_entries(user_id);
CREATE INDEX idx_sleep_entries_sleep_date ON public.sleep_entries(sleep_date);
CREATE INDEX idx_crew_members_user_id ON public.crew_members(user_id);
CREATE INDEX idx_crew_members_crew_id ON public.crew_members(crew_id);
CREATE INDEX idx_sync_queue_user_id ON public.sync_queue(user_id);
CREATE INDEX idx_sync_queue_synced ON public.sync_queue(synced);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply updated_at triggers
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_exercise_stats_updated_at BEFORE UPDATE ON public.user_exercise_stats
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_workout_sessions_updated_at BEFORE UPDATE ON public.workout_sessions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_crews_updated_at BEFORE UPDATE ON public.crews
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
