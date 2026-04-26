CREATE OR REPLACE FUNCTION prevent_client_delete()
RETURNS TRIGGER AS $$
DECLARE
    order_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO order_count
    FROM "Order"
    WHERE client_id = OLD.clientid
      AND status IN ('New', 'In processing', 'Ready to delivery');

    IF order_count > 0 THEN
        RAISE EXCEPTION 'Невозможно удалить клиента (ID: %) с активными заказами', OLD.clientid;
    END IF;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_client_delete
BEFORE DELETE ON client
FOR EACH ROW EXECUTE FUNCTION prevent_client_delete();