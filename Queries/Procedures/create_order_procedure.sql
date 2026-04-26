CREATE OR REPLACE PROCEDURE create_order_with_items(
    p_client_id INTEGER,
    p_payment_type payment_type,
    p_items JSON  -- Формат: [{"product_id": 1, "quantity": 2}, ...]
)
LANGUAGE plpgsql AS $$
DECLARE
    v_order_id INTEGER;
    v_item JSON;
    v_product_id INTEGER;
    v_quantity INTEGER;
    v_available INTEGER;
    v_total_amount INTEGER := 0;
    v_product_price INTEGER;
BEGIN
    -- Проверяем наличие всех товаров на складах
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::INTEGER;
        v_quantity := (v_item->>'quantity')::INTEGER;

        SELECT SUM(quantity_of_product_in_warehouses) INTO v_available
        FROM product_and_warehouses
        WHERE product_id = v_product_id;

        IF v_available IS NULL OR v_available < v_quantity THEN
            RAISE EXCEPTION 'Товар ID: % недоступен в нужном количестве (запрошено: %, доступно: %)',
                v_product_id, v_quantity, COALESCE(v_available, 0);
        END IF;

        SELECT retailprice INTO v_product_price FROM product WHERE productid = v_product_id;
        v_total_amount := v_total_amount + (v_product_price * v_quantity);
    END LOOP;

    -- Создаем заказ
    SELECT COALESCE(MAX(orderid), 0) + 1 INTO v_order_id FROM "Order";

    INSERT INTO "Order" (orderid, name, status, total_amount, payment_type, creation_data, client_id)
    VALUES (v_order_id, 'Заказ №' || v_order_id, 'New', v_total_amount, p_payment_type, CURRENT_DATE, p_client_id);

    -- Добавляем товары в заказ и списываем со складов
    FOR v_item IN SELECT * FROM json_array_elements(p_items)
    LOOP
        v_product_id := (v_item->>'product_id')::INTEGER;
        v_quantity := (v_item->>'quantity')::INTEGER;

        INSERT INTO product_and_order (product_and_order_id, product_id, order_id, quantity_of_ordered_products)
        VALUES ((SELECT COALESCE(MAX(product_and_order_id), 0) + 1 FROM product_and_order),
                v_product_id, v_order_id, v_quantity);

        -- Списываем со складов (упрощенная логика - списываем с первого склада где есть остаток)
        UPDATE product_and_warehouses
        SET quantity_of_product_in_warehouses = quantity_of_product_in_warehouses - v_quantity
        WHERE product_id = v_product_id
          AND quantity_of_product_in_warehouses >= v_quantity
          AND warehouse_id = (
              SELECT warehouse_id FROM product_and_warehouses
              WHERE product_id = v_product_id AND quantity_of_product_in_warehouses >= v_quantity
              LIMIT 1
          );
    END LOOP;

    COMMIT;
    RAISE NOTICE 'Заказ №% успешно создан на сумму % руб.', v_order_id, v_total_amount;
END;
$$;