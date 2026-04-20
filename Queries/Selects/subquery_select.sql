SELECT AVG(total_amount) FROM "Order";


SELECT
    client.username,
    "Order".name,
    "Order".total_amount
FROM client
JOIN "Order" ON "Order".client_id = client.clientid
WHERE "Order".total_amount > (SELECT AVG(total_amount) FROM "Order");