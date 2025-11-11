-- Enable Row Level Security on all tables
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.exercises ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_exercise_stats ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.workout_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.nutrition_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sleep_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crew_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crew_challenges ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.crew_challenge_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.sync_queue ENABLE ROW LEVEL SECURITY;

-- Users policies
CREATE POLICY "Users can view own profile" ON public.users
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON public.users
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Exercises policies (public read, authenticated write)
CREATE POLICY "Anyone can view exercises" ON public.exercises
    FOR SELECT USING (true);

CREATE POLICY "Authenticated users can create exercises" ON public.exercises
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- User exercise stats policies
CREATE POLICY "Users can view own exercise stats" ON public.user_exercise_stats
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own exercise stats" ON public.user_exercise_stats
    FOR ALL USING (auth.uid() = user_id);

-- Workout sessions policies
CREATE POLICY "Users can view own workout sessions" ON public.workout_sessions
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own workout sessions" ON public.workout_sessions
    FOR ALL USING (auth.uid() = user_id);

-- Workout sets policies
CREATE POLICY "Users can view own workout sets" ON public.workout_sets
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own workout sets" ON public.workout_sets
    FOR ALL USING (auth.uid() = user_id);

-- Nutrition entries policies
CREATE POLICY "Users can view own nutrition entries" ON public.nutrition_entries
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own nutrition entries" ON public.nutrition_entries
    FOR ALL USING (auth.uid() = user_id);

-- Sleep entries policies
CREATE POLICY "Users can view own sleep entries" ON public.sleep_entries
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own sleep entries" ON public.sleep_entries
    FOR ALL USING (auth.uid() = user_id);

-- Crews policies
CREATE POLICY "Users can view crews they're in" ON public.crews
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.crew_members
            WHERE crew_members.crew_id = crews.id
            AND crew_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create crews" ON public.crews
    FOR INSERT WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Creators can update their crews" ON public.crews
    FOR UPDATE USING (auth.uid() = creator_id);

-- Crew members policies
CREATE POLICY "Users can view members of their crews" ON public.crew_members
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.crew_members cm
            WHERE cm.crew_id = crew_members.crew_id
            AND cm.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join crews" ON public.crew_members
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can leave crews" ON public.crew_members
    FOR DELETE USING (auth.uid() = user_id);

-- Crew challenges policies
CREATE POLICY "Users can view challenges in their crews" ON public.crew_challenges
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.crew_members
            WHERE crew_members.crew_id = crew_challenges.crew_id
            AND crew_members.user_id = auth.uid()
        )
    );

CREATE POLICY "Crew creators can manage challenges" ON public.crew_challenges
    FOR ALL USING (
        EXISTS (
            SELECT 1 FROM public.crews
            WHERE crews.id = crew_challenges.crew_id
            AND crews.creator_id = auth.uid()
        )
    );

-- Crew challenge scores policies
CREATE POLICY "Users can view scores in their challenges" ON public.crew_challenge_scores
    FOR SELECT USING (
        EXISTS (
            SELECT 1 FROM public.crew_challenges cc
            JOIN public.crew_members cm ON cm.crew_id = cc.crew_id
            WHERE cc.id = crew_challenge_scores.challenge_id
            AND cm.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can update own scores" ON public.crew_challenge_scores
    FOR ALL USING (auth.uid() = user_id);

-- Sync queue policies
CREATE POLICY "Users can view own sync queue" ON public.sync_queue
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can manage own sync queue" ON public.sync_queue
    FOR ALL USING (auth.uid() = user_id);
