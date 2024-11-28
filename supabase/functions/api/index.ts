import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import { corsHeaders } from "./utils/cors.ts";
import { getZones } from "./services/zoneService.ts";
import { getProtests, insertProtest } from "./services/protestService.ts";
import { uploadImage } from "./services/imageService.ts";

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
      // deno-lint-ignore no-case-declarations
      case "GET":
        const url = new URL(req.url);
        const pathParts = url.pathname.split("/").filter(Boolean);

        const endpoint = pathParts[pathParts.length - 1]; // 마지막 경로 부분을 가져옵니다

        switch (endpoint) {
          case "list":
            return await getProtests(supabaseClient);

          case "zone":
            return await getZones(supabaseClient);
          default:
            return new Response(
              JSON.stringify({ error: "Invalid endpoint" }),
              {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 404,
              },
            );
        }

      // 생성 (Create)
      case "POST": {
        const contentType = req.headers.get("content-type") || "";
        if (contentType.includes("multipart/form-data")) {
          return await uploadImage(supabaseClient, req);
        }

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
  } catch (error: unknown) {
    return new Response(
      JSON.stringify({
        error: error instanceof Error
          ? error.message
          : "Unknown error occurred",
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
});
