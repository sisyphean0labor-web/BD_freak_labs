from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from typing import Optional, List
import asyncpg
from contextlib import asynccontextmanager

DB_CONFIG = {
    "host": "localhost",
    "port": 5433,
    "database": "BD",
    "user": "admin",
    "password": "admin123"
}

db_pool = None

class CoworkingCreate(BaseModel):
    coworking_id: int
    название: str
    адрес: str
    телефон: Optional[str] = None

class SpaceCreate(BaseModel):
    space_id: int
    coworking_id: int
    название_места: str
    тип: str
    цена_за_час: float

class BookingCreate(BaseModel):
    booking_id: int
    user_id: int
    space_id: int
    дата_бронирования: str
    время_начала: str
    время_конца: str
    статус: str = "активно"

@asynccontextmanager
async def lifespan(app: FastAPI):
    global db_pool
    db_pool = await asyncpg.create_pool(**DB_CONFIG)
    print("Подключение к базе данных установлено")
    yield
    await db_pool.close()
    print("Подключение к базе данных закрыто")

app = FastAPI(
    title="Coworking Booking API",
    description="API для системы бронирования коворкингов",
    version="1.0.0",
    lifespan=lifespan
)

async def get_db():
    return await db_pool.acquire()

async def release_db(conn):
    await db_pool.release(conn)

# ==================== COWORKINGS ====================
@app.get("/coworkings")
async def get_all_coworkings():
    conn = await get_db()
    try:
        rows = await conn.fetch('SELECT * FROM coworking ORDER BY coworking_id')
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)

@app.get("/coworkings/{coworking_id}")
async def get_coworking_by_id(coworking_id: int):
    conn = await get_db()
    try:
        row = await conn.fetchrow('SELECT * FROM coworking WHERE coworking_id = $1', coworking_id)
        if not row:
            raise HTTPException(status_code=404, detail="Коворкинг не найден")
        return dict(row)
    finally:
        await release_db(conn)

@app.post("/coworkings")
async def create_coworking(data: CoworkingCreate):
    conn = await get_db()
    try:
        await conn.execute(
            'INSERT INTO coworking (coworking_id, название, адрес, телефон) VALUES ($1, $2, $3, $4)',
            data.coworking_id, data.название, data.адрес, data.телефон
        )
        return {"message": "Коворкинг создан", "id": data.coworking_id}
    except asyncpg.UniqueViolationError:
        raise HTTPException(status_code=400, detail="Коворкинг с таким ID уже существует")
    finally:
        await release_db(conn)

@app.put("/coworkings/{coworking_id}")
async def update_coworking(coworking_id: int, data: CoworkingCreate):
    conn = await get_db()
    try:
        result = await conn.execute(
            'UPDATE coworking SET название=$1, адрес=$2, телефон=$3 WHERE coworking_id=$4',
            data.название, data.адрес, data.телефон, coworking_id
        )
        if result == "UPDATE 0":
            raise HTTPException(status_code=404, detail="Коворкинг не найден")
        return {"message": "Коворкинг обновлён"}
    finally:
        await release_db(conn)

@app.delete("/coworkings/{coworking_id}")
async def delete_coworking(coworking_id: int):
    conn = await get_db()
    try:
        result = await conn.execute('DELETE FROM coworking WHERE coworking_id = $1', coworking_id)
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Коворкинг не найден")
        return {"message": "Коворкинг удалён"}
    finally:
        await release_db(conn)

# ==================== SPACES ====================
@app.get("/spaces")
async def get_all_spaces():
    conn = await get_db()
    try:
        rows = await conn.fetch('SELECT * FROM space ORDER BY space_id')
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)

@app.get("/spaces/{space_id}")
async def get_space_by_id(space_id: int):
    conn = await get_db()
    try:
        row = await conn.fetchrow('SELECT * FROM space WHERE space_id = $1', space_id)
        if not row:
            raise HTTPException(status_code=404, detail="Место не найдено")
        return dict(row)
    finally:
        await release_db(conn)

@app.post("/spaces")
async def create_space(data: SpaceCreate):
    conn = await get_db()
    try:
        await conn.execute(
            'INSERT INTO space (space_id, coworking_id, название_места, тип, цена_за_час) VALUES ($1, $2, $3, $4, $5)',
            data.space_id, data.coworking_id, data.название_места, data.тип, data.цена_за_час
        )
        return {"message": "Место создано", "id": data.space_id}
    except asyncpg.UniqueViolationError:
        raise HTTPException(status_code=400, detail="Место с таким ID уже существует")
    except asyncpg.ForeignKeyViolationError:
        raise HTTPException(status_code=400, detail="Коворкинг с таким ID не существует")
    finally:
        await release_db(conn)

@app.delete("/spaces/{space_id}")
async def delete_space(space_id: int):
    conn = await get_db()
    try:
        result = await conn.execute('DELETE FROM space WHERE space_id = $1', space_id)
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Место не найдено")
        return {"message": "Место удалено"}
    finally:
        await release_db(conn)

# ==================== BOOKINGS ====================
@app.get("/bookings")
async def get_all_bookings(
    page: int = Query(1, ge=1),
    limit: int = Query(10, ge=1, le=100),
    user_id: Optional[int] = None,
    status: Optional[str] = None
):
    conn = await get_db()
    try:
        offset = (page - 1) * limit
        query = 'SELECT * FROM booking'
        params = []
        conditions = []
        
        if user_id:
            conditions.append(f"user_id = ${len(params)+1}")
            params.append(user_id)
        if status:
            conditions.append(f"статус = ${len(params)+1}")
            params.append(status)
        
        if conditions:
            query += " WHERE " + " AND ".join(conditions)
        
        query += f' ORDER BY booking_id LIMIT ${len(params)+1} OFFSET ${len(params)+2}'
        params.append(limit)
        params.append(offset)
        
        rows = await conn.fetch(query, *params)
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)

@app.get("/bookings/{booking_id}")
async def get_booking_by_id(booking_id: int):
    conn = await get_db()
    try:
        row = await conn.fetchrow('SELECT * FROM booking WHERE booking_id = $1', booking_id)
        if not row:
            raise HTTPException(status_code=404, detail="Бронирование не найдено")
        return dict(row)
    finally:
        await release_db(conn)

@app.post("/bookings")
async def create_booking(data: BookingCreate):
    conn = await get_db()
    try:
        await conn.execute(
            'INSERT INTO booking (booking_id, user_id, space_id, дата_бронирования, время_начала, время_конца, статус) VALUES ($1, $2, $3, $4, $5, $6, $7)',
            data.booking_id, data.user_id, data.space_id, data.дата_бронирования, data.время_начала, data.время_конца, data.статус
        )
        return {"message": "Бронирование создано", "id": data.booking_id}
    except asyncpg.UniqueViolationError:
        raise HTTPException(status_code=400, detail="Бронирование с таким ID уже существует")
    except asyncpg.ForeignKeyViolationError as e:
        if "user_id" in str(e):
            raise HTTPException(status_code=400, detail="Пользователь с таким ID не существует")
        if "space_id" in str(e):
            raise HTTPException(status_code=400, detail="Место с таким ID не существует")
        raise HTTPException(status_code=400, detail="Ошибка внешнего ключа")
    except asyncpg.CheckViolationError:
        raise HTTPException(status_code=400, detail="Время начала должно быть меньше времени конца")
    finally:
        await release_db(conn)

@app.put("/bookings/{booking_id}")
async def update_booking_status(booking_id: int, status: str):
    conn = await get_db()
    try:
        if status not in ['активно', 'завершено', 'отменено']:
            raise HTTPException(status_code=400, detail="Неверный статус. Допустимые: активно, завершено, отменено")
        
        result = await conn.execute(
            'UPDATE booking SET статус = $1 WHERE booking_id = $2',
            status, booking_id
        )
        if result == "UPDATE 0":
            raise HTTPException(status_code=404, detail="Бронирование не найдено")
        return {"message": "Статус обновлён", "status": status}
    finally:
        await release_db(conn)

@app.delete("/bookings/{booking_id}")
async def delete_booking(booking_id: int):
    conn = await get_db()
    try:
        result = await conn.execute('DELETE FROM booking WHERE booking_id = $1', booking_id)
        if result == "DELETE 0":
            raise HTTPException(status_code=404, detail="Бронирование не найдено")
        return {"message": "Бронирование удалено"}
    finally:
        await release_db(conn)

# ==================== VIEWS ====================
@app.get("/views/active_bookings")
async def get_active_bookings():
    conn = await get_db()
    try:
        rows = await conn.fetch("""
            SELECT 
                b.booking_id,
                u."ИМЯ" as user_name,
                s."НАЗВАНИЕ_МЕСТА" as space_name,
                b."ДАТА_БРОНИРОВАНИЯ",
                b."ВРЕМЯ_НАЧАЛА",
                b."ВРЕМЯ_КОНЦА",
                b."СТАТУС"
            FROM booking b
            JOIN users u ON b.user_id = u.user_id
            JOIN space s ON b.space_id = s.space_id
            WHERE b."СТАТУС" = 'активно'
            ORDER BY b."ДАТА_БРОНИРОВАНИЯ"
        """)
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)

@app.get("/views/user_bookings_count")
async def get_user_bookings_count():
    conn = await get_db()
    try:
        rows = await conn.fetch("""
            SELECT 
                u.user_id,
                u."ИМЯ",
                COUNT(b.booking_id) as total_bookings
            FROM users u
            LEFT JOIN booking b ON u.user_id = b.user_id
            GROUP BY u.user_id, u."ИМЯ"
            ORDER BY total_bookings DESC
        """)
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)

# ==================== REPORTS ====================
@app.get("/reports/booking_stats")
async def get_booking_stats():
    conn = await get_db()
    try:
        row = await conn.fetchrow("""
            SELECT 
                COUNT(*) as total_bookings,
                COUNT(CASE WHEN "СТАТУС" = 'активно' THEN 1 END) as active_bookings,
                COUNT(CASE WHEN "СТАТУС" = 'завершено' THEN 1 END) as completed_bookings,
                COUNT(CASE WHEN "СТАТУС" = 'отменено' THEN 1 END) as cancelled_bookings
            FROM booking
        """)
        return dict(row)
    finally:
        await release_db(conn)

@app.get("/reports/spaces_stats")
async def get_spaces_stats():
    conn = await get_db()
    try:
        rows = await conn.fetch("""
            SELECT 
                s."НАЗВАНИЕ_МЕСТА",
                s."ТИП",
                s."ЦЕНА_ЗА_ЧАС",
                COUNT(b.booking_id) as times_booked
            FROM space s
            LEFT JOIN booking b ON s.space_id = b.space_id
            GROUP BY s.space_id, s."НАЗВАНИЕ_МЕСТА", s."ТИП", s."ЦЕНА_ЗА_ЧАС"
            ORDER BY times_booked DESC
        """)
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)

@app.get("/reports/coworkings_stats")
async def get_coworkings_stats():
    conn = await get_db()
    try:
        rows = await conn.fetch("""
            SELECT 
                c."НАЗВАНИЕ" as coworking_name,
                COUNT(DISTINCT s.space_id) as total_spaces,
                COUNT(b.booking_id) as total_bookings
            FROM coworking c
            LEFT JOIN space s ON c.coworking_id = s.coworking_id
            LEFT JOIN booking b ON s.space_id = b.space_id
            GROUP BY c.coworking_id, c."НАЗВАНИЕ"
            ORDER BY total_bookings DESC
        """)
        return [dict(row) for row in rows]
    finally:
        await release_db(conn)