SELECT
    product.name,
    supplier.suppliername
FROM product
JOIN supplier
    ON supplier.supplierid = product.supplier_id
WHERE supplier.suppliername = 'МДФ-Комплект';