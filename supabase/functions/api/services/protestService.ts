import { corsHeaders } from "../utils/cors.ts";
import { InsertProtestBody, PoliceStation } from "../types.ts";
export async function getProtests(supabase: any) {
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

export async function insertProtest(supabase: any, body: InsertProtestBody) {
  const { mainData, detailsData } = body;

  const { data: mainInsert, error: mainError } = await supabase
    .from("protest_main")
    .insert(mainData)
    .select()
    .single();

  if (mainError) throw mainError;

  const { data: zoneData, error: zoneError } = await supabase.from(
    "police_station",
  ).select(
    "*",
  )
    .order("created_at", { ascending: false });

  const zoneDataType: PoliceStation[] = zoneData;

  if (zoneError) throw zoneError;

  const detailsWithId = detailsData.map((detail, index) => ({
    ...detail,
    protest_id: mainInsert.protest_id,
    seq: index + 1,
    zone: getZone(detail.police_station ?? "", zoneDataType!),
  }));

  detailsData.map((detail, index) => ({
    ...detail,
    protest_id: mainInsert.protest_id,
    seq: index + 1,
    zone: detail.police_station,
  }));

  const { error: detailError } = await supabase
    .from("protest_detail")
    .insert(detailsWithId);

  if (detailError) throw detailError;

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

function getZone(policeStation: string, zoneData: PoliceStation[]) {
  const stations = policeStation.split(",");
  const uniqueZones = new Set(
    stations
      .map((station) => {
        const match = zoneData.find((data) =>
          data.station_name === station?.trim()
        );
        return match?.zone;
      })
      .filter((zone) => zone != null) // null/undefined 제거
      .map((zone) => zone as string),
  ); // null/undefined가 제거되었으므로 string으로 타입 단언 가능

  return Array.from(uniqueZones).join(",");
}
