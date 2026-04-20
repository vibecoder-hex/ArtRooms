SELECT
    name,
    retailprice,
    CASE
        WHEN retailprice < 70000 THEN 'Малая'
        WHEN retailprice >= 70000 AND retailprice <= 120000 THEN 'Средняя'
        WHEN retailprice > 120000 THEN 'Большая'
    END AS retailpricecategory
FROM product;