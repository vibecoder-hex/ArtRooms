CREATE OR REPLACE FUNCTION update_stock_on_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE product_and_warehouses
    SET quantity_of_product_in_warehouses = quantity_of_product_in_warehouses - NEW.quantity_of_ordered_products
    WHERE product_id = NEW.product_id
      AND quantity_of_product_in_warehouses >= NEW.quantity_of_ordered_products
      AND warehouse_id = 1;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Недостаточно товара (ID: %) на складах', NEW.product_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_stock
AFTER INSERT ON product_and_order
FOR EACH ROW EXECUTE FUNCTION update_stock_on_order();