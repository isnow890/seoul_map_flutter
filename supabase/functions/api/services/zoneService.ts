import { corsHeaders } from "../utils/cors.ts";

export async function getZones(supabase: any) {
    const { data, error } = await supabase.from("police_station").select("*")
        .order("created_at", { ascending: false });

    if (error) throw error;
    return new Response(
        JSON.stringify(data),
        {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 200,
        },
    );
}
