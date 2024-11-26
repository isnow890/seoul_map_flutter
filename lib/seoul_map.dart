import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class SeoulMap extends StatefulWidget {
  const SeoulMap({super.key});

  @override
  State<SeoulMap> createState() => _SeoulMapState();
}

class _SeoulMapState extends State<SeoulMap> {
  String selectedDistrict = '';
  Map<String, dynamic>? geoJsonData;
  final Map<String, LatLng> districtCenters = {};

  @override
  void initState() {
    super.initState();
    _loadGeoJson();
  }

  Future<void> _loadGeoJson() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/seoul_districts.json');
      setState(() {
        geoJsonData = json.decode(jsonString);
        _calculateDistrictCenters();
      });
    } catch (e) {
      debugPrint('Error loading GeoJSON: $e');
    }
  }

  void _calculateDistrictCenters() {
    if (geoJsonData == null) return;

    final features = geoJsonData!['features'] as List;
    for (var feature in features) {
      final name = feature['properties']['SIG_KOR_NM'] as String;
      final coordinates = feature['geometry']['coordinates'][0] as List;

      // 경계 상자의 최소/최대 좌표 찾기
      double minLat = double.infinity;
      double maxLat = -double.infinity;
      double minLng = double.infinity;
      double maxLng = -double.infinity;

      for (var coord in coordinates) {
        final lat = (coord[1] as num).toDouble();
        final lng = (coord[0] as num).toDouble();

        minLat = minLat > lat ? lat : minLat;
        maxLat = maxLat < lat ? lat : maxLat;
        minLng = minLng > lng ? lng : minLng;
        maxLng = maxLng < lng ? lng : maxLng;
      }

      // 경계 상자의 중심점 계산
      final centerLat = (minLat + maxLat) / 2;
      final centerLng = (minLng + maxLng) / 2;

      // 폴리곤 내부의 점인지 확인하고 필요한 경우 조정
      var point = LatLng(centerLat, centerLng);

      // 일부 구에 대한 수동 조정
      switch (name) {
        case "도봉구":
          point = LatLng(centerLat - 0.010, centerLng + 0.001);
          break;
        case "노원구":
          point = LatLng(centerLat - 0.020, centerLng + 0.001);
          break;
        case "구로구":
          point = LatLng(centerLat - 0.010, centerLng - 0.015);
          break;
        case "금천구":
          point = LatLng(centerLat - 0.000, centerLng + 0.000);
          break;

        case "서대문구":
          point = LatLng(centerLat - 0.011, centerLng - 0.004);
          break;
        case "마포구":
          point = LatLng(centerLat - 0.011, centerLng);
          break;
        case "종로구":
          point = LatLng(centerLat - 0.022, centerLng);
          break;
        case "강북구":
          point = LatLng(centerLat - 0.020, centerLng);
          break;
        case "성북구":
          point = LatLng(centerLat - 0.010, centerLng);
          break;
        case "동대문구":
          point = LatLng(centerLat - 0.010, centerLng);
          break;
        case "강서구":
          point = LatLng(centerLat - 0.010, centerLng);
          break;
        case "강동구":
          point = LatLng(centerLat - 0.003, centerLng);
          break;
        case "강남구":
          point = LatLng(centerLat + 0.002, centerLng - 0.020);
          break;
        case "서초구":
          point = LatLng(centerLat + 0.003, centerLng - 0.030);
          break;

        case "광진구":
          point = LatLng(centerLat - 0.010, centerLng - 0.000);
          break;

        case "송파구":
          point = LatLng(centerLat - 0.002, centerLng + 0.001);
          break;
        case "관악구":
          point = LatLng(centerLat + 0.002, centerLng);
          break;
        case "은평구":
          point = LatLng(centerLat - 0.001, centerLng + 0.008);
          break;
        // case "종로구":
        //   point = LatLng(centerLat - 0.002, centerLng);
        //   break;
        // case "성북구":
        //   point = LatLng(centerLat + 0.001, centerLng);
        //   break;
        case "양천구":
          point = LatLng(centerLat - 0.011, centerLng);
          break;
        case "중구":
          point = LatLng(centerLat - 0.003, centerLng);
          break;
      }

      districtCenters[name] = point;
    }
  }

  List<LatLng> _convertCoordinates(List coordinates) {
    return coordinates
        .map((coord) =>
            LatLng((coord[1] as num).toDouble(), (coord[0] as num).toDouble()))
        .toList();
  }

  List<String> getDistrictNames() {
    if (geoJsonData == null) return [];
    final features = geoJsonData!['features'] as List;
    return features
        .map((feature) => feature['properties']['SIG_KOR_NM'] as String)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (geoJsonData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final features = geoJsonData!['features'] as List;

    return

        // Row(
        //   children: [
        //     Container(
        //       width: 150,
        //       color: Colors.grey[200],
        //       child: ListView.builder(
        //         itemCount: getDistrictNames().length,
        //         itemBuilder: (context, index) {
        //           final district = getDistrictNames()[index];
        //           return ListTile(
        //             title: Text(district),
        //             selected: selectedDistrict == district,
        //             onTap: () {
        //               setState(() {
        //                 print('눌림 : $district');
        //                 selectedDistrict = district;
        //               });
        //             },
        //           );
        //         },
        //       ),
        //     ),
        // Expanded(
        // child:

        SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      width: MediaQuery.of(context).size.width,
      child: FlutterMap(
        options: MapOptions(
          center: const LatLng(37.5665, 126.9780),
          zoom: 10.30,
          interactiveFlags: InteractiveFlag.none,
          onTap: (tapPosition, point) {
            for (var feature in features) {
              final coordinates = feature['geometry']['coordinates'][0] as List;
              final name = feature['properties']['SIG_KOR_NM'] as String;
              final points = _convertCoordinates(coordinates);

              if (_isPointInPolygon(point, points)) {
                setState(() {
                  selectedDistrict = name;
                  print('Selected district: $selectedDistrict'); // 선택된 구 출력
                });
                break;
              }
            }
          },
        ),
        children: [
          PolygonLayer(
            polygons: features.map<Polygon>((feature) {
              final coordinates = feature['geometry']['coordinates'][0] as List;
              final name = feature['properties']['SIG_KOR_NM'] as String;
              final points = _convertCoordinates(coordinates);

              final isSelected = selectedDistrict == name;

              return Polygon(
                isFilled: true,
                points: points,
                // 배경색을 기본적으로 연한 회색으로 설정
                color: isSelected
                    ? Colors.grey.withOpacity(0.3) // 선택됐을 때
                    // : Colors.grey.shade200, // 기본 상태
                    : Colors.white, // 기본 상태
                borderColor: Colors.black38,
                borderStrokeWidth: 1,
              );
            }).toList(),
          ),
          MarkerLayer(
            markers: districtCenters.entries.map((entry) {
              return Marker(
                point: entry.value,
                width: 100,
                height: 40,
                builder: (context) => Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    // color: selectedDistrict == entry.key
                    //     ? Colors.blue.withOpacity(0.2)
                    //     : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    entry.key == "중구"
                        ? entry.key
                        : entry.key.substring(0, entry.key.length - 1),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: selectedDistrict == entry.key
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].longitude > point.longitude) !=
              (polygon[j].longitude > point.longitude) &&
          point.latitude <
              (polygon[j].latitude - polygon[i].latitude) *
                      (point.longitude - polygon[i].longitude) /
                      (polygon[j].longitude - polygon[i].longitude) +
                  polygon[i].latitude) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }
}
