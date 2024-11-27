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
    JSON.stringify(data),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 200,
    },
  );
}

async function uploadImage(supabase: any, req: Request) {
  try {
    const formData = await req.formData();
    const file = formData.get("file");

    if (!file) {
      throw new Error("No file uploaded");
    }

    if (!(file instanceof File)) {
      throw new Error("Invalid file type");
    }

    if (!file.type.includes("jpeg") && !file.type.includes("jpg")) {
      throw new Error("Only JPG/JPEG files are allowed");
    }

    // 파일 이름 생성 (타임스탬프-원본파일명.jpg)
    const fileName = `${Date.now()}-${file.name}`;

    // Storage에 업로드
    const { data, error } = await supabase
      .storage
      .from("protest") // 여기에 실제 bucket 이름을 입력하세요
      .upload(fileName, file, {
        contentType: file.type,
        cacheControl: "3600",
        upsert: false,
      });

    if (error) throw error;

    // 업로드된 파일의 공개 URL 가져오기
    const { data: { publicUrl } } = supabase
      .storage
      .from("protest")
      .getPublicUrl(fileName);

    return new Response(
      JSON.stringify({
        fileName: fileName,
        publicUrl: publicUrl,
      }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 200,
      },
    );
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 400,
      },
    );
  }
}
async function insertProtest(
  supabase: any,
  body: InsertProtestBody,
) {
  const { mainData, detailsData } = body;

  // 기존 insert 로직
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

  const { error: detailError } = await supabase
    .from("protest_detail")
    .insert(detailsWithId);

  if (detailError) throw detailError;

  // getProtests와 동일한 형식으로 새로 조회
  const { data, error } = await supabase
    .from("protest_main")
    .select(`*,protest_detail(*)`)
    .eq("protest_id", mainInsert.protest_id)
    .single();

  if (error) throw error;

  return new Response(
    JSON.stringify(data),
    {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
      status: 201,
    },
  );
}
