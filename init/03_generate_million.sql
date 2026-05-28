-- ========================================
-- 3. Генерация 1 000 000 бронирований (самый надёжный способ)
-- ========================================

DO $$
DECLARE
    current_max INT;
    start_hours INT;
    duration_hours INT;
BEGIN
    SELECT COALESCE(MAX(BOOKING_ID), 0) INTO current_max FROM BOOKING;
    
    FOR i IN 1..1000000 LOOP
        start_hours := 8 + (random() * 10)::INT;  -- от 8 до 18 часов
        duration_hours := 1 + (random() * 4)::INT; -- от 1 до 5 часов
        
        INSERT INTO BOOKING (BOOKING_ID, USER_ID, SPACE_ID, ДАТА_БРОНИРОВАНИЯ, ВРЕМЯ_НАЧАЛА, ВРЕМЯ_КОНЦА, СТАТУС)
        VALUES (
            current_max + i,
            (random() * 4 + 1)::INT,
            (random() * 3 + 1)::INT,
            DATE '2026-01-01' + (random() * 365)::INT,
            MAKE_TIME(start_hours, 0, 0),
            MAKE_TIME(start_hours + duration_hours, 0, 0),
            CASE WHEN random() > 0.2 THEN 'активно' ELSE 'завершено' END
        );
    END LOOP;
END $$;