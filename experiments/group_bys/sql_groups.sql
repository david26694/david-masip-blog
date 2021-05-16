-- # Count based on 1 column
SELECT species, count(*) FROM "penguins" group by 1

-- # Count based on 1 column
SELECT species, island, count(*) FROM "penguins" group by 1, 2


-- # Many aggregates per column
SELECT 
    species, 
    island, 
    avg(bill_length_mm),
    median(bill_length_mm), 
    sum(flipper_length_mm is not null) FROM "penguins" 
group by 1, 2

-- # Group by filter (having)
with high_penguins as (
    select species, island from penguins group by 1, 2 having count(*) > 70
) select p.* 
from penguins p
inner join high_penguins using(species, island)


-- # Group by mutate
-- Doesn't work in sqlite
select 
    *, 
    avg(bill_length_mm) over (partition by species, island) 
from penguins

-- # Count relative
with species_island_counts as (
    select species, island, count(*) as n from penguins
), species_counts as (
    select 
        species, 
        island, 
        sum(n) over (partition by species) as species_n,
        n
    from species_island_counts
) select 
    species, 
    island, 
    n / species_n as fraction 
    from species_counts
-- # Agg with two columns
