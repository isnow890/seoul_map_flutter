import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { InsertProtestBody } from "./types.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, GET, PUT, DELETE, OPTIONS",
};

Deno.serve(async (req) => {
  try {
    // OPTIONS 요청 처리
    if (req.method === "OPTIONS") {
      return new Response("ok", {
        headers: corsHeaders,
      });
    }

    // Supabase 클라이언트 초기화
    const supabaseClient = createClient(
      Deno.env.get("SUPABASE_URL") ??
        "",
      Deno.env.get(
        "SUPABASE_SERVICE_ROLE_KEY",
      ) ?? "",
    );

    switch (req.method) {
      case "GET":
        return await getProtests(supabaseClient);

      // 생성 (Create)
      case "POST": {
        const body = await req.json();
        return await insertProtest(supabaseClient, body);
      }

      // // 수정 (Update)
      // case 'PUT': {
      //   if (!protestId) {
      //     throw new Error('protest_id is required')
      //   }

      //   const updateDto: UpdateProtestDto = await req.json()

      //   // 빈 업데이트 체크
      //   if (Object.keys(updateDto).length === 0) {
      //     throw new Error('No update data provided')
      //   }

      //   const { data, error } = await supabaseClient
      //     .from('protest_main')
      //     .update(updateDto)
      //     .eq('protest_id', protestId)
      //     .select()
      //     .single()

      //   if (error) throw error

      //   return new Response(
      //     JSON.stringify(data),
      //     {
      //       headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      //       status: 200
      //     }
      //   )
      // }

      // // 삭제 (Delete)
      // case 'DELETE': {
      //   if (!protestId) {
      //     throw new Error('protest_id is required')
      //   }

      //   const { error } = await supabaseClient
      //     .from('protest_main')
      //     .delete()
      //     .eq('protest_id', protestId)

      //   if (error) throw error

      //   return new Response(
      //     JSON.stringify({ message: 'Protest deleted successfully' }),
      //     {
      //       headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      //       status: 200
      //     }
      //   )
      // }

      default:
        return new Response(
          JSON.stringify({ error: "Method not allowed" }),
          {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 405,
          },
        );
    }
  } catch (error) {
    return new Response(
      JSON.stringify({
        error: error.message || "Unknown error occurred",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
});

async function getProtests(supabase: any) {
  const { data, error } = await supabase.from("protest_main")
    .select(`*,protest_detail(*)`)
    .order("started_at", { ascending: false });

  if (error) throw error;

  return new Response(
    JSON.stringify({ data }),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    },
  );
}

async function insertProtest(
  supabase: any,
  body: InsertProtestBody,
) {
  const { mainData, detailsData } = body;

  const { data: mainInsert, error: mainError } = await supabase
    .from("protest_main")
    .insert(mainData)
    .select()
    .single();

  if (mainError) throw mainError;

  const detailsWithId = detailsData.map((detail, index) => ({
    ...detail,
    protest_id: mainInsert.protest_id,
    seq: index + 1,
  }));

  const { data: detailInsert, error: detailError } = await supabase
    .from("protest_detail")
    .insert(detailsWithId)
    .select();

  if (detailError) throw detailError;

  return new Response(
    JSON.stringify({
      main: mainInsert,
      details: detailInsert,
    }),
    {
      headers: { "Content-Type": "application/json" },
      status: 201,
    },
  );
}
