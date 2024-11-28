export interface InsertProtestBody {
  mainData: {
    started_at: string;
    protest_count: number;
    storage_url: string;
    board_url: string;
    image_url: string;
    board_id: number;
    board_seq: number;
  };
  detailsData: Array<{
    start_time?: string;
    end_time?: string;
    place: string;
    place1?: string;
    place2?: string;
    place3?: string;
    count?: number;
    zone?: string;
    remark?: string;
    police_station?: string;
  }>;
}

export interface PoliceStation {
  id: number; // bigint -> number
  created_at: string; // timestamp -> string (ISO date string)
  station_name: string | null; // text can be null
  zone: string | null; // text can be null
}
