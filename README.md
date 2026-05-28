cd ~/Projects/BD/bd_4

# Пересоздать базу с нуля (очистить всё)
sudo docker-compose down -v
sudo docker-compose up -d

# Войти в докер(выйти ctr+D)
sudo docker exec -it coworking_postgres psql -U admin -d BD
SELECT COUNT(*) FROM BOOKING;
\q
\dt --all bd

--4 лаба
\timing on --включить замер времени

Seq Scan	Читает всю таблицу подряд от первой до последней строки	❌ Плохо для больших таблиц

Index Scan	Идёт по индексу (как по оглавлению) и находит нужные строки	✅ Хорошо

Index Only Scan	Все нужные данные есть в индексе, таблицу даже не читает	✅✅ Отлично!

Bitmap Index Scan	Сначала находит позиции строк в индексе, потом читает их пачкой	✅ Хорошо для большого количества строк

Parallel Seq Scan	Читает таблицу в несколько потоков одновременно	🤷 Нормально, если таблица огромная


-- 5 lab
# Из папки api (там где main.py) 
cd ~/Projects/BD/bd_4/api
python3 -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
sudo kill -9 67893 67895
http://localhost:8000/docs

Ctrl + C   -- остановочка

--все ковроки
http://localhost:8000/coworkings
--все места
http://localhost:8000/spaces

http://localhost:8000/bookings?page=1&limit=10
http://localhost:8000/bookings?limit=10&СТАТУС=активно&ВРЕМЯ_НАЧАЛА>=2026-05-20