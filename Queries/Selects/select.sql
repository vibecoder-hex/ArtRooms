SELECT name, status, total_amount, creation_data, payment_type
FROM art_rooms."Order"
WHERE payment_type = 'card';
