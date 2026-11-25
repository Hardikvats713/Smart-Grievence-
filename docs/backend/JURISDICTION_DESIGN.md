# Geographical Jurisdiction Design & PostGIS Architecture
## Smart Grievance Management Information System — Arunachal Pradesh

### 1. Spatial Structure Overview
Civic administration in Arunachal Pradesh requires spatial awareness due to diverse geography (mountainous terrain, urban capital complex, and rural circles). Smart Grievance embeds PostGIS spatial types directly into PostgreSQL.

```
State (AR - Arunachal Pradesh)
 └── District (e.g., Papum Pare, Capital Complex Itanagar)
      └── Administrative Area / Ward (e.g., Ward 01 - Ganga, Ward 02 - Bank Tinali)
           └── Geographic Coordinates (Latitude, Longitude via PostGIS Point)
```

---

### 2. PostGIS Geometry & Spatial Queries

#### Point Geometry for Grievances
Every grievance stores its geographical location as a native PostGIS geography point:
```sql
location_point geography(Point, 4326) NOT NULL
```
- Spatial Reference System Identifier (SRID): `4326` (WGS 84 GPS standard).
- Automatically populated on insert/update using:
  ```sql
  NEW.location_point := ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
  ```

#### Spatial Indexing
```sql
CREATE INDEX idx_grievances_location_point ON public.grievances USING GIST (location_point);
```

#### Officer Jurisdiction Containment Check
When a Department Officer attempts to access or modify a grievance:
```sql
SELECT g.id 
FROM public.grievances g
JOIN public.jurisdictions j ON j.id = :officer_jurisdiction_id
WHERE g.id = :grievance_id
  AND (
    -- If jurisdiction has boundary polygon
    (j.boundary IS NOT NULL AND ST_Contains(j.boundary::geometry, g.location_point::geometry))
    OR
    -- Or matches administrative area / district scope
    (g.district_id = j.district_id AND (j.administrative_area_id IS NULL OR g.jurisdiction_id = j.id))
  );
```

#### Spatial Proximity & Hotspot Clustering
Find all grievances within 500 meters of an incident to detect duplicate reports or infrastructure failures:
```sql
SELECT id, reference_number, category_id, title,
       ST_Distance(location_point, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography) AS distance_meters
FROM public.grievances
WHERE ST_DWithin(location_point, ST_SetSRID(ST_MakePoint(:lng, :lat), 4326)::geography, 500)
  AND status NOT IN ('CLOSED', 'REJECTED');
```
