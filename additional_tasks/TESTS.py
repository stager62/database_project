import sqlite3
import sys

DB_PATH = "база данных.db"
if len(sys.argv) > 1:
    DB_PATH = sys.argv[1]

def ok(message: str) -> None:
    print(f"[OK] {message}")

def fail(message: str) -> None:
    print(f"[FAIL] {message}")

def main() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON;")
    cur = conn.cursor()
    test_student_id = 100
    duplicate_email_student_id = 101
    bad_status_student_id = 102
    try:
        print(f"Using database: {DB_PATH}")
        cur.execute("DELETE FROM student_version WHERE student_id IN (?, ?, ?);", (test_student_id, duplicate_email_student_id, bad_status_student_id))
        cur.execute("DELETE FROM student WHERE student_id IN (?, ?, ?);", (test_student_id, duplicate_email_student_id, bad_status_student_id))
        conn.commit()
        #Тест 1. После INSERT в student автоматически создаётся первая версия в student_version
        cur.execute("""INSERT INTO student (student_id, full_name, email, registration_date, status) VALUES (?, ?, ?, ?, ?);""", (test_student_id, "Тест Тестов", "test100@gmail.com", "2026-03-21", "active"))
        conn.commit()
        cur.execute("""SELECT COUNT(*) FROM student_version WHERE student_id = ?;""", (test_student_id,))
        version_count = cur.fetchone()[0]
        if version_count == 1:
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 2. Первая версия помечена как текущая и имеет номер 1
        cur.execute("""SELECT is_current, version_num, status FROM student_version WHERE student_id = ?;""", (test_student_id,))
        row = cur.fetchone()
        if row == (1, 1, "active"):
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 3. UPDATE закрывает старую версию и создаёт новую
        cur.execute("""UPDATE student SET status = ?, email = ? WHERE student_id = ?;""", ("inactive", "test100_new@gmail.com", test_student_id))
        conn.commit()
        cur.execute("""SELECT COUNT(*) FROM student_version WHERE student_id = ?;""", (test_student_id,))
        version_count_after_update = cur.fetchone()[0]
        if version_count_after_update == 2:
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 4. Старая версия закрыта, а новая является текущей
        cur.execute("""SELECT COUNT(*) FROM student_version WHERE student_id = ? AND is_current = 1;""", (test_student_id,))
        current_count = cur.fetchone()[0]
        cur.execute("""SELECT COUNT(*) FROM student_version WHERE student_id = ? AND valid_to IS NOT NULL;""", (test_student_id,))
        closed_count = cur.fetchone()[0]
        if current_count == 1 and closed_count == 1:
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 5. Новая версия имеет номер 2 и обновлённые данные
        cur.execute("""SELECT version_num, status, email FROM student_version WHERE student_id = ? AND is_current = 1;""", (test_student_id,))
        current_version = cur.fetchone()
        if current_version == (2, "inactive", "test100_new@gmail.com"):
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 6. UPDATE без реального изменения не должен создавать новую версию
        cur.execute("""UPDATE student SET status = status WHERE student_id = ?;""", (test_student_id,))
        conn.commit()
        cur.execute("""SELECT COUNT(*) FROM student_version WHERE student_id = ?;""", (test_student_id,))
        final_count = cur.fetchone()[0]
        if final_count == 2:
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 7. Вставка студента с уже существующим email должна завершиться ошибкой
        try:
            cur.execute("""INSERT INTO student (student_id, full_name, email, registration_date, status) VALUES (?, ?, ?, ?, ?);""", (duplicate_email_student_id, "Дубликат Почты", "student1@gmail.com", "2026-03-22", "active"))
            conn.commit()
            fail("ошибка")
        except sqlite3.IntegrityError:
            ok("успешно")
            conn.rollback()
        #Тест 8. Вставка студента с недопустимым status должна завершиться ошибкой
        try:
            cur.execute("""INSERT INTO student (student_id, full_name, email, registration_date, status) VALUES (?, ?, ?, ?, ?);""", (bad_status_student_id, "Неверный Статус", "badstatus@gmail.com", "2026-03-22", "blocked"))
            conn.commit()
            fail("ошибка")
        except sqlite3.IntegrityError:
            ok("успешно")
            conn.rollback()
        #Тест 9. Изменение только одного поля должно создать новую версию
        cur.execute("""UPDATE student SET full_name = ? WHERE student_id = ?;""", ("Тест Новый", test_student_id))
        conn.commit()
        cur.execute("""SELECT COUNT(*) FROM student_version WHERE student_id = ?;""", (test_student_id,))
        count_after_name_update = cur.fetchone()[0]
        if count_after_name_update == 3:
            ok("успешно")
        else:
            fail("ошибка")
        #Тест 10. Новая текущая версия после последнего обновления имеет номер 3
        cur.execute("""SELECT version_num, full_name, is_current FROM student_version WHERE student_id = ? AND is_current = 1;""", (test_student_id,))
        last_row = cur.fetchone()
        if last_row == (3, "Тест Новый", 1):
            ok("успешно")
        else:
            fail("ошибка")
    except Exception as e:
        fail(f"ошибки: {e}")
    finally:
        try:
            cur.execute("DELETE FROM student_version WHERE student_id IN (?, ?, ?);", (test_student_id, duplicate_email_student_id, bad_status_student_id))
            cur.execute("DELETE FROM student WHERE student_id IN (?, ?, ?);", (test_student_id, duplicate_email_student_id, bad_status_student_id))
            conn.commit()
        except Exception:
            pass
        conn.close()

if __name__ == "__main__":
    main()
