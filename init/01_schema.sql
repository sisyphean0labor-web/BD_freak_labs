-- ========================================
-- 2. Создаём таблицы
-- ========================================
CREATE TABLE COWORKING (
    COWORKING_ID INT PRIMARY KEY,
    НАЗВАНИЕ VARCHAR(100) NOT NULL,
    АДРЕС VARCHAR(200) NOT NULL,
    ТЕЛЕФОН VARCHAR(20)
);

CREATE TABLE SPACE (
    SPACE_ID INT PRIMARY KEY,
    COWORKING_ID INT NOT NULL,
    НАЗВАНИЕ_МЕСТА VARCHAR(50) NOT NULL,
    ТИП VARCHAR(30) CHECK (ТИП IN ('рабочее место', 'переговорка')),
    ЦЕНА_ЗА_ЧАС DECIMAL(10,2) NOT NULL CHECK (ЦЕНА_ЗА_ЧАС >= 0),
    FOREIGN KEY (COWORKING_ID) REFERENCES COWORKING(COWORKING_ID)
);

CREATE TABLE USERS (
    USER_ID INT PRIMARY KEY,
    ИМЯ VARCHAR(50) NOT NULL,
    EMAIL VARCHAR(100) UNIQUE NOT NULL,
    ТЕЛЕФОН VARCHAR(20),
    ДАТА_РЕГИСТРАЦИИ DATE DEFAULT '2026-05-01',
    IS_ADMIN BOOLEAN DEFAULT FALSE
);

CREATE TABLE BOOKING (
    BOOKING_ID INT PRIMARY KEY,
    USER_ID INT NOT NULL,
    SPACE_ID INT NOT NULL,
    ДАТА_БРОНИРОВАНИЯ DATE NOT NULL,
    ВРЕМЯ_НАЧАЛА TIME NOT NULL,
    ВРЕМЯ_КОНЦА TIME NOT NULL,
    СТАТУС VARCHAR(30) DEFAULT 'активно' CHECK (СТАТУС IN ('активно', 'завершено', 'отменено')),
    FOREIGN KEY (USER_ID) REFERENCES USERS(USER_ID),
    FOREIGN KEY (SPACE_ID) REFERENCES SPACE(SPACE_ID),
    CHECK (ВРЕМЯ_НАЧАЛА < ВРЕМЯ_КОНЦА)
);