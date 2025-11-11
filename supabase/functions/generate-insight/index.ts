import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface InsightRequest {
  userId: string;
  type: 'daily' | 'recovery' | 'deload' | 'pr_celebration';
  context?: any;
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { userId, type, context } = await req.json() as InsightRequest;

    if (!userId) {
      return new Response(
        JSON.stringify({ error: 'Missing userId' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

    // Get user data from Supabase
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    // Fetch recent workout data
    const { data: recentWorkouts } = await supabase
      .from('workout_sessions')
      .select(`
        *,
        workout_sets (
          weight,
          reps,
          exercises (name)
        )
      `)
      .eq('user_id', userId)
      .order('start_time', { ascending: false })
      .limit(7);

    // Fetch sleep data
    const { data: recentSleep } = await supabase
      .from('sleep_entries')
      .select('*')
      .eq('user_id', userId)
      .order('sleep_date', { ascending: false })
      .limit(7);

    // Fetch user profile
    const { data: user } = await supabase
      .from('users')
      .select('*')
      .eq('id', userId)
      .single();

    // Build context for AI
    const aiContext = buildContext(type, { user, recentWorkouts, recentSleep, context });

    // Call Groq API
    const groqApiKey = Deno.env.get('GROQ_API_KEY');
    if (!groqApiKey) {
      throw new Error('GROQ_API_KEY not configured');
    }

    const groqResponse = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${groqApiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.3-70b-versatile',
        messages: [
          {
            role: 'system',
            content: getSystemPrompt(type)
          },
          {
            role: 'user',
            content: aiContext
          }
        ],
        temperature: 0.7,
        max_tokens: 256,
      }),
    });

    if (!groqResponse.ok) {
      throw new Error(`Groq API failed: ${groqResponse.status}`);
    }

    const groqData = await groqResponse.json();
    const insight = groqData.choices[0]?.message?.content || 'Stay consistent and trust the process! 💪';

    return new Response(
      JSON.stringify({ 
        success: true, 
        insight,
        type 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    console.error('Error in generate-insight function:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

function getSystemPrompt(type: string): string {
  const prompts = {
    daily: 'You are a motivational fitness coach. Generate a short, encouraging daily insight (max 2 sentences) based on user progress. Be energetic and use emojis.',
    recovery: 'You are a recovery specialist. Analyze sleep and workout data to give actionable recovery advice (max 2 sentences). Be direct and helpful.',
    deload: 'You are a training expert. Recommend when to take a deload week based on fatigue signals (max 2 sentences). Be professional.',
    pr_celebration: 'You are a hype coach. Celebrate the user\'s personal record achievement (max 2 sentences). Be extremely enthusiastic with emojis!'
  };

  return prompts[type] || prompts.daily;
}

function buildContext(type: string, data: any): string {
  const { user, recentWorkouts, recentSleep, context } = data;

  if (type === 'pr_celebration' && context) {
    return `User ${user?.name} just hit a PR: ${context.exercise} at ${context.weight}kg! Previous best was ${context.previousBest}kg. Celebrate this achievement!`;
  }

  if (type === 'deload') {
    const avgSleep = recentSleep?.reduce((sum, s) => sum + s.hours_slept, 0) / (recentSleep?.length || 1);
    const avgRecovery = recentSleep?.reduce((sum, s) => sum + ((s.sleep_quality + (10 - s.soreness_level) + s.energy_level) / 3), 0) / (recentSleep?.length || 1);
    
    return `User has been training for ${recentWorkouts?.length || 0} sessions in the last week. Average sleep: ${avgSleep.toFixed(1)}h. Average recovery score: ${((avgRecovery / 10) * 100).toFixed(0)}/100. Should they deload?`;
  }

  if (type === 'recovery') {
    const lastSleep = recentSleep?.[0];
    return `Last night: ${lastSleep?.hours_slept || 0}h sleep, quality ${lastSleep?.sleep_quality || 0}/10, soreness ${lastSleep?.soreness_level || 0}/10. Recovery advice?`;
  }

  // Daily insight
  const workoutCount = recentWorkouts?.length || 0;
  const streak = user?.current_streak || 0;
  
  return `User ${user?.name} has ${workoutCount} workouts this week and a ${streak}-day streak. Goal: ${user?.fitness_goal}. Give motivational insight.`;
}
