# data/

Data files are git-ignored and must never be committed.

## Required: `hdb_resale_prices.csv`

HDB resale flat prices from data.gov.sg ("Resale flat prices based on registration date from Jan-2017 onwards").

- Expected path: `data/hdb_resale_prices.csv`
- About 244,657 rows, about 24 MB, months from 2017-01
- Header (the loader rejects the file if this changes):

```
month,town,flat_type,block,street_name,storey_range,floor_area_sqm,flat_model,lease_commence_date,remaining_lease,resale_price
```

Download it from data.gov.sg and save it to the path above. The container mounts it read-only.
