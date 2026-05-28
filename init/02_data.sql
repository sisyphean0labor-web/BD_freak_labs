-- ========================================
-- 3. Вставляем данные
-- ========================================

-- Коворкинги
INSERT INTO COWORKING (COWORKING_ID, НАЗВАНИЕ, АДРЕС, ТЕЛЕФОН) 
VALUES (1, 'Тверской', 'Тверская 15', '+7 (495) 123-45-67');

INSERT INTO COWORKING (COWORKING_ID, НАЗВАНИЕ, АДРЕС, ТЕЛЕФОН) 
VALUES (2, 'Цифровой', 'Ленина 10', '+7 (495) 987-65-43');

INSERT INTO COWORKING (COWORKING_ID, НАЗВАНИЕ, АДРЕС, ТЕЛЕФОН) 
VALUES (3, 'Парковый', 'Парковая 5', '+7 (499) 111-22-33');

-- Места
INSERT INTO SPACE (SPACE_ID, COWORKING_ID, НАЗВАНИЕ_МЕСТА, ТИП, ЦЕНА_ЗА_ЧАС) 
VALUES (1, 1, 'Переговорка Альфа', 'переговорка', 1500.00);

INSERT INTO SPACE (SPACE_ID, COWORKING_ID, НАЗВАНИЕ_МЕСТА, ТИП, ЦЕНА_ЗА_ЧАС) 
VALUES (2, 1, 'Стол №8', 'рабочее место', 350.00);

INSERT INTO SPACE (SPACE_ID, COWORKING_ID, НАЗВАНИЕ_МЕСТА, ТИП, ЦЕНА_ЗА_ЧАС) 
VALUES (3, 2, 'Переговорка Бета', 'переговорка', 2000.00);

INSERT INTO SPACE (SPACE_ID, COWORKING_ID, НАЗВАНИЕ_МЕСТА, ТИП, ЦЕНА_ЗА_ЧАС) 
VALUES (4, 3, 'Стол №12', 'рабочее место', 280.00);

-- Пользователи
INSERT INTO USERS (USER_ID, ИМЯ, EMAIL, ТЕЛЕФОН, ДАТА_РЕГИСТРАЦИИ, IS_ADMIN) 
VALUES (1, 'Иван', 'ivan@example.com', '+7 (999) 111-22-33', '2026-05-01', TRUE);

INSERT INTO USERS (USER_ID, ИМЯ, EMAIL, ТЕЛЕФОН, ДАТА_РЕГИСТРАЦИИ, IS_ADMIN) 
VALUES (2, 'Мария', 'maria@example.com', '+7 (999) 444-55-66', '2026-05-01', FALSE);

INSERT INTO USERS (USER_ID, ИМЯ, EMAIL, ТЕЛЕФОН, ДАТА_РЕГИСТРАЦИИ, IS_ADMIN) 
VALUES (3, 'Алексей', 'alex@example.com', '+7 (916) 555-11-22', '2026-05-01', FALSE);

INSERT INTO USERS (USER_ID, ИМЯ, EMAIL, ТЕЛЕФОН, ДАТА_РЕГИСТРАЦИИ, IS_ADMIN) 
VALUES (4, 'Елена', 'elena@example.com', '+7 (915) 777-88-99', '2026-05-01', FALSE);

INSERT INTO USERS (USER_ID, ИМЯ, EMAIL, ТЕЛЕФОН, ДАТА_РЕГИСТРАЦИИ, IS_ADMIN) 
VALUES (5, 'Дмитрий', 'dmitry@example.com', '+7 (903) 444-55-66', '2026-05-01', TRUE);

-- Бронирования
INSERT INTO BOOKING (BOOKING_ID, USER_ID, SPACE_ID, ДАТА_БРОНИРОВАНИЯ, ВРЕМЯ_НАЧАЛА, ВРЕМЯ_КОНЦА, СТАТУС) 
VALUES (1, 2, 1, '2026-05-20', '14:00:00', '15:00:00', 'активно');

INSERT INTO BOOKING (BOOKING_ID, USER_ID, SPACE_ID, ДАТА_БРОНИРОВАНИЯ, ВРЕМЯ_НАЧАЛА, ВРЕМЯ_КОНЦА, СТАТУС) 
VALUES (2, 3, 2, '2026-05-21', '09:00:00', '11:00:00', 'активно');

INSERT INTO BOOKING (BOOKING_ID, USER_ID, SPACE_ID, ДАТА_БРОНИРОВАНИЯ, ВРЕМЯ_НАЧАЛА, ВРЕМЯ_КОНЦА, СТАТУС) 
VALUES (3, 4, 3, '2026-05-22', '15:00:00', '17:00:00', 'активно');

INSERT INTO BOOKING (BOOKING_ID, USER_ID, SPACE_ID, ДАТА_БРОНИРОВАНИЯ, ВРЕМЯ_НАЧАЛА, ВРЕМЯ_КОНЦА, СТАТУС) 
VALUES (4, 2, 4, '2026-05-23', '12:00:00', '13:00:00', 'завершено');