interface InsertProtestBody {
  mainData: {
    started_at: string;
    protest_count: number;
    storage_url: string;
    post_url: string;
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
  }>;
}
