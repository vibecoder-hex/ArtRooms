CREATE OR REPLACE VIEW warehouse_price_sum_view AS
    SELECT
        warehouse.name,
        SUM(product.costprice * product_and_warehouses.quantity_of_product_in_warehouses) AS cost_prise_sum,
        SUM(product_and_warehouses.quantity_of_product_in_warehouses) AS total_quantity_of_product_in_warehouses
    FROM warehouse
    JOIN product_and_warehouses
    ON product_and_warehouses.warehouse_id = warehouse.warehouseid
            JOIN product
            ON product_and_warehouses.product_id = product.productid
    GROUP BY warehouse.name
    HAVING SUM(product.costprice * product_and_warehouses.quantity_of_product_in_warehouses) > 1500000
        AND SUM(product_and_warehouses.quantity_of_product_in_warehouses) % 2 = 0;

SELECT * FROM warehouse_price_sum_view;