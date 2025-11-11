import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface SyncRequest {
  userId: string;
  changes: Array<{
    table: string;
    operation: 'insert' | 'update' | 'delete';
    data: any;
    localId?: string;
  }>;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { userId, changes } = await req.json() as SyncRequest;

    if (!userId || !changes) {
      return new Response(
        JSON.stringify({ error: 'Missing userId or changes' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const results = [];
    const errors = [];

    // Process each change
    for (const change of changes) {
      try {
        let result;

        switch (change.operation) {
          case 'insert':
            const insertData = { ...change.data, user_id: userId };
            result = await supabase.from(change.table).insert(insertData).select();
            break;

          case 'update':
            const updateData = { ...change.data, updated_at: new Date().toISOString() };
            result = await supabase
              .from(change.table)
              .update(updateData)
              .eq('id', change.data.id)
              .eq('user_id', userId)
              .select();
            break;

          case 'delete':
            result = await supabase
              .from(change.table)
              .delete()
              .eq('id', change.data.id)
              .eq('user_id', userId);
            break;
        }

        if (result.error) {
          errors.push({
            localId: change.localId,
            table: change.table,
            error: result.error.message
          });
        } else {
          results.push({
            localId: change.localId,
            table: change.table,
            serverData: result.data?.[0],
            success: true
          });
        }

      } catch (err) {
        errors.push({
          localId: change.localId,
          table: change.table,
          error: err.message
        });
      }
    }

    // Update streak if workout synced
    const workoutSynced = changes.some(c => c.table === 'workout_sessions' && c.operation === 'insert');
    if (workoutSynced) {
      await updateStreak(supabase, userId);
    }

    return new Response(
      JSON.stringify({ 
        success: true, 
        results,
        errors: errors.length > 0 ? errors : undefined,
        syncedCount: results.length,
        errorCount: errors.length
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    console.error('Error in sync-data function:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

async function updateStreak(supabase: any, userId: string) {
  try {
    // Get last 2 workout dates
    const { data: workouts } = await supabase
      .from('workout_sessions')
      .select('start_time')
      .eq('user_id', userId)
      .order('start_time', { ascending: false })
      .limit(2);

    if (!workouts || workouts.length === 0) return;

    const today = new Date();
    const lastWorkout = new Date(workouts[0].start_time);
    
    // Check if last workout was today or yesterday
    const daysDiff = Math.floor((today.getTime() - lastWorkout.getTime()) / (1000 * 60 * 60 * 24));

    let streakUpdate;
    
    if (daysDiff === 0) {
      // Same day, no streak change
      return;
    } else if (daysDiff === 1) {
      // Consecutive day, increment streak
      const { data: user } = await supabase
        .from('users')
        .select('current_streak, longest_streak')
        .eq('id', userId)
        .single();

      const newStreak = (user?.current_streak || 0) + 1;
      const longestStreak = Math.max(newStreak, user?.longest_streak || 0);

      streakUpdate = {
        current_streak: newStreak,
        longest_streak: longestStreak
      };
    } else {
      // Streak broken, reset to 1
      streakUpdate = {
        current_streak: 1
      };
    }

    await supabase
      .from('users')
      .update(streakUpdate)
      .eq('id', userId);

  } catch (error) {
    console.error('Error updating streak:', error);
  }
}
