interface InsertProtestBody {
  mainData: {
    started_at: string;
    protest_count: number;
    scrap_no: number;
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
