Запрос 5. JOIN (соединение таблиц)

-- ========================================
-- 1. БЕЗ ИНДЕКСА (на внешних ключах)
-- ========================================
EXPLAIN ANALYZE 
SELECT b.*, u.ИМЯ, s.НАЗВАНИЕ_МЕСТА
-- Берём все колонки из бронирований + имя пользователя + название места
FROM BOOKING b
-- JOIN - соединяем таблицы
JOIN USERS u ON b.USER_ID = u.USER_ID
-- JOIN USERS - присоединяем пользователей по USER_ID
JOIN SPACE s ON b.SPACE_ID = s.SPACE_ID
-- JOIN SPACE - присоединяем места по SPACE_ID
WHERE b.СТАТУС = 'активно'
-- WHERE - только активные бронирования
LIMIT 100;
-- LIMIT - показываем только 100 строк


-- ========================================
-- 2. СОЗДАЁМ ИНДЕКСЫ ДЛЯ JOIN (на внешних ключах)
-- ========================================
CREATE INDEX idx_booking_user_id ON BOOKING (USER_ID);
-- Индекс на колонке, по которой JOIN-им с USERS
-- Ускоряет поиск пользователя для каждого бронирования

CREATE INDEX idx_booking_space_id ON BOOKING (SPACE_ID);
-- Индекс на колонке, по которой JOIN-им с SPACE
-- Ускоряет поиск места для каждого бронирования

CREATE INDEX idx_booking_status ON BOOKING (СТАТУС);
-- Индекс на статусе для WHERE


-- ========================================
-- 3. С ИНДЕКСАМИ
-- ========================================
EXPLAIN ANALYZE 
SELECT b.*, u.ИМЯ, s.НАЗВАНИЕ_МЕСТА
FROM BOOKING b
JOIN USERS u ON b.USER_ID = u.USER_ID
JOIN SPACE s ON b.SPACE_ID = s.SPACE_ID
WHERE b.СТАТУС = 'активно'
LIMIT 100;

-- ========================================
-- 4. УДАЛЯЕМ ИНДЕКСЫ
-- ========================================
DROP INDEX idx_booking_user_id;
DROP INDEX idx_booking_space_id;
DROP INDEX idx_booking_status;

Вывод: Индексы на внешних ключах (USER_ID, SPACE_ID) ускоряют соединение таблиц.
Какие индексы нужны: На колонках, по которым соединяешь таблицы (на id и foreign_id)