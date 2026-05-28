Эксперимент: Блокировка данных

-- Убедимся, что бронирование с ID=1 существует и имеет статус 'активно'
SELECT BOOKING_ID, СТАТУС FROM BOOKING WHERE BOOKING_ID = 1;

Сессия 1 (первый терминал)
-- Начинаем транзакцию
BEGIN;

-- Обновляем статус бронирования (НЕ делаем COMMIT)
UPDATE BOOKING SET СТАТУС = 'заблокировано' WHERE BOOKING_ID = 1;

-- Проверяем, что обновилось
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;


Сессия 2 (второй терминал)
-- Пытаемся прочитать это же бронирование
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;
-- Покажет старый статус (не 'заблокировано') — потому что READ COMMITTED

-- Пытаемся обновить это же бронирование
UPDATE BOOKING SET СТАТУС = 'попытка' WHERE BOOKING_ID = 1;
-- Здесь будет ВИСЕТЬ (ждун)! Первая сессия заблокировала строку


--Вторая сессия ждёт, пока первая сделает COMMIT или ROLLBACK.


Возвращаемся в Сессию 1
-- Фиксируем изменения
COMMIT;
-- Теперь блокировка снята


Возвращаемся в Сессию 2
--После COMMIT в первой сессии — второй запрос UPDATE выполнится.
--------------------------------------------------



Разные уровни изоляции:
Уровень READ COMMITTED (по умолчанию)

-- Сессия 1
BEGIN;
UPDATE BOOKING SET СТАТУС = 'активно' WHERE BOOKING_ID = 1;

-- Сессия 2
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;
-- Видит СТАРЫЙ статус (не 'изменено'), т.к. транзакция 1 ещё не закоммичена

-- Сессия 1
COMMIT;

-- Сессия 2
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;
-- Теперь видит НОВЫЙ статус
------------------------------------------


Уровень REPEATABLE READ

-- В обеих сессиях сначала установим уровень
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- Сессия 1
BEGIN;
UPDATE BOOKING SET СТАТУС = 'новый' WHERE BOOKING_ID = 1;

-- Сессия 2 (до COMMIT в сессии 1)
BEGIN;
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;
-- Видит СТАРЫЙ статус

-- Сессия 1
COMMIT;

-- Сессия 2 (после COMMIT)
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;
-- Всё ещё видит СТАРЫЙ статус! (гарантия повторяемого чтения)

-- Сессия 2
COMMIT;
SELECT * FROM BOOKING WHERE BOOKING_ID = 1;
-- Теперь видит НОВЫЙ статус
------------------------------------------------------


Уровень SERIALIZABLE (самый строгий)

-- В обеих сессиях
BEGIN TRANSACTION ISOLATION LEVEL SERIALIZABLE;
UPDATE BOOKING SET СТАТУС = 'активно' WHERE BOOKING_ID = 1;
UPDATE BOOKING SET СТАТУС = 'отменено' WHERE BOOKING_ID = 1;

-- Сессия 1
BEGIN;
UPDATE BOOKING SET СТАТУС = 'значение1' WHERE BOOKING_ID = 1;

-- Сессия 2
BEGIN;
UPDATE BOOKING SET СТАТУС = 'значение2' WHERE BOOKING_ID = 1;
-- Будет ОШИБКА: could not serialize access due to concurrent update
-- Сериализуемый уровень не позволяет параллельно менять одни и те же данные
----------------------------------------------


Аномалия "Грязное чтение" (Dirty Read)
    В PostgreSQL не бывает dirty read даже на самом низком уровне — это защита.
    Но можно показать аномалию "Неповторяющееся чтение":

-- Уровень READ COMMITTED
-- Сессия 1
BEGIN;
UPDATE BOOKING SET СТАТУС = 'версия1' WHERE BOOKING_ID = 1;

-- Сессия 2
BEGIN;
SELECT СТАТУС FROM BOOKING WHERE BOOKING_ID = 1;  -- видит старый статус

-- Сессия 1
COMMIT;

-- Сессия 2
SELECT СТАТУС FROM BOOKING WHERE BOOKING_ID = 1;  -- видит НОВЫЙ статус!
-- Это аномалия "неповторяющееся чтение" — в одной транзакции SELECT показал разное
