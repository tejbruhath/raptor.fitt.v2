import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.38.4';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface WorkoutParseRequest {
  input: string;
  userId: string;
}

interface ParsedSet {
  exerciseName: string;
  weight: number;
  sets: number;
  reps: number;
  rpe?: number;
}

serve(async (req) => {
  // Handle CORS preflight requests
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { input, userId } = await req.json() as WorkoutParseRequest;

    if (!input || !userId) {
      return new Response(
        JSON.stringify({ error: 'Missing input or userId' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      );
    }

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
            content: `You are a workout logging assistant. Parse natural language workout input and return structured JSON.

Rules:
1. Identify exercise name, weight (kg), sets, reps
2. Common aliases: "bench" = "Bench Press", "squat" = "Squat", "dl" or "dead" = "Deadlift"
3. Format: exercise weight sets reps (e.g., "bench 80 3 10")
4. RPE (rate of perceived exertion) if mentioned (1-10)
5. Return ONLY valid JSON array, no markdown or extra text

Example input: "bench 80 3 10, squat 100 4 8"
Example output: [{"exerciseName":"Bench Press","weight":80,"sets":3,"reps":10},{"exerciseName":"Squat","weight":100,"sets":4,"reps":8}]`
          },
          {
            role: 'user',
            content: input
          }
        ],
        temperature: 0.3,
        max_tokens: 1024,
      }),
    });

    if (!groqResponse.ok) {
      const errorText = await groqResponse.text();
      console.error('Groq API error:', errorText);
      throw new Error(`Groq API failed: ${groqResponse.status}`);
    }

    const groqData = await groqResponse.json();
    const aiResponse = groqData.choices[0]?.message?.content || '';

    // Parse AI response
    let parsedSets: ParsedSet[];
    try {
      // Remove markdown code blocks if present
      const cleanedResponse = aiResponse
        .replace(/```json\n?/g, '')
        .replace(/```\n?/g, '')
        .trim();
      
      parsedSets = JSON.parse(cleanedResponse);
    } catch (e) {
      console.error('Failed to parse AI response:', aiResponse);
      // Fallback to regex parsing
      parsedSets = regexParse(input);
    }

    // Match exercise names to database
    const supabaseUrl = Deno.env.get('SUPABASE_URL')!;
    const supabaseKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { data: exercises, error: exerciseError } = await supabase
      .from('exercises')
      .select('id, name');

    if (exerciseError) {
      console.error('Error fetching exercises:', exerciseError);
    }

    // Match parsed exercise names to database
    const matchedSets = parsedSets.map(set => {
      const matched = exercises?.find(ex => 
        ex.name.toLowerCase().includes(set.exerciseName.toLowerCase()) ||
        set.exerciseName.toLowerCase().includes(ex.name.toLowerCase())
      );

      return {
        ...set,
        exerciseId: matched?.id || null,
        exerciseName: matched?.name || set.exerciseName,
      };
    });

    return new Response(
      JSON.stringify({ 
        success: true, 
        parsed: matchedSets,
        rawAiResponse: aiResponse 
      }),
      { 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200 
      }
    );

  } catch (error) {
    console.error('Error in parse-workout function:', error);
    return new Response(
      JSON.stringify({ error: error.message }),
      { 
        status: 500, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      }
    );
  }
});

// Fallback regex parser
function regexParse(input: string): ParsedSet[] {
  const results: ParsedSet[] = [];
  
  // Pattern: exercise name followed by weight, sets, reps
  const pattern = /([a-zA-Z\s]+?)\s+(\d+(?:\.\d+)?)\s+(\d+)\s+(\d+)(?:\s+rpe\s*(\d+))?/gi;
  
  let match;
  while ((match = pattern.exec(input)) !== null) {
    results.push({
      exerciseName: match[1].trim(),
      weight: parseFloat(match[2]),
      sets: parseInt(match[3]),
      reps: parseInt(match[4]),
      rpe: match[5] ? parseInt(match[5]) : undefined,
    });
  }
  
  return results;
}
