-- Seed default exercises
INSERT INTO public.exercises (name, category, muscle_group, type, equipment, description, is_default) VALUES
-- Chest
('Bench Press', 'strength', 'chest', 'compound', 'barbell', 'Horizontal chest press on flat bench', true),
('Incline Bench Press', 'strength', 'chest', 'compound', 'barbell', 'Upper chest press on incline bench', true),
('Dumbbell Flyes', 'strength', 'chest', 'isolation', 'dumbbell', 'Chest fly movement with dumbbells', true),
('Push-ups', 'strength', 'chest', 'compound', 'bodyweight', 'Classic push-up movement', true),

-- Back
('Deadlift', 'strength', 'back', 'compound', 'barbell', 'Hip hinge movement targeting posterior chain', true),
('Pull-ups', 'strength', 'back', 'compound', 'bodyweight', 'Vertical pulling movement', true),
('Barbell Row', 'strength', 'back', 'compound', 'barbell', 'Horizontal row with barbell', true),
('Lat Pulldown', 'strength', 'back', 'compound', 'cable', 'Vertical pulling on machine', true),

-- Shoulders
('Overhead Press', 'strength', 'shoulders', 'compound', 'barbell', 'Vertical press overhead', true),
('Lateral Raises', 'strength', 'shoulders', 'isolation', 'dumbbell', 'Side delt isolation', true),
('Face Pulls', 'strength', 'shoulders', 'isolation', 'cable', 'Rear delt and rotator cuff work', true),

-- Arms
('Barbell Curl', 'strength', 'biceps', 'isolation', 'barbell', 'Bicep curl with barbell', true),
('Hammer Curl', 'strength', 'biceps', 'isolation', 'dumbbell', 'Neutral grip bicep curl', true),
('Tricep Dips', 'strength', 'triceps', 'compound', 'bodyweight', 'Bodyweight tricep dips', true),
('Overhead Tricep Extension', 'strength', 'triceps', 'isolation', 'dumbbell', 'Overhead tricep isolation', true),

-- Legs
('Squat', 'strength', 'legs', 'compound', 'barbell', 'Back squat with barbell', true),
('Front Squat', 'strength', 'legs', 'compound', 'barbell', 'Front-loaded squat', true),
('Leg Press', 'strength', 'legs', 'compound', 'machine', 'Machine leg press', true),
('Romanian Deadlift', 'strength', 'legs', 'compound', 'barbell', 'Hip hinge targeting hamstrings', true),
('Leg Curl', 'strength', 'legs', 'isolation', 'machine', 'Hamstring isolation', true),
('Leg Extension', 'strength', 'legs', 'isolation', 'machine', 'Quad isolation', true),
('Calf Raises', 'strength', 'calves', 'isolation', 'machine', 'Standing or seated calf raises', true),

-- Core
('Plank', 'strength', 'core', 'isolation', 'bodyweight', 'Isometric core hold', true),
('Hanging Leg Raises', 'strength', 'core', 'isolation', 'bodyweight', 'Hanging ab exercise', true),
('Cable Crunches', 'strength', 'core', 'isolation', 'cable', 'Cable ab crunches', true),

-- Cardio
('Running', 'cardio', 'full body', 'cardio', 'none', 'Running or jogging', true),
('Cycling', 'cardio', 'full body', 'cardio', 'machine', 'Stationary or outdoor cycling', true),
('Rowing', 'cardio', 'full body', 'cardio', 'machine', 'Rowing machine', true);
