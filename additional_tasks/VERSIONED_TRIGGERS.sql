--Таблица истории студентов
CREATE TABLE student_version (
    version_id INTEGER PRIMARY KEY AUTOINCREMENT,
    student_id INT NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    registration_date DATE NOT NULL,
    status VARCHAR(10) NOT NULL,
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP,
    is_current INTEGER NOT NULL CHECK (is_current IN (0, 1)),
    version_num INT NOT NULL,
    FOREIGN KEY (student_id) REFERENCES student(student_id)
);
INSERT INTO student_version (
    student_id,
    full_name,
    email,
    registration_date,
    status,
    valid_from,
    valid_to,
    is_current,
    version_num
)
SELECT
    student_id,
    full_name,
    email,
    registration_date,
    status,
    CURRENT_TIMESTAMP,
    NULL,
    1,
    1
FROM student;

--Триггер 1. После добавления нового студента автоматически создаёт первую версию в истории
CREATE TRIGGER trg_student_version_after_insert
AFTER INSERT ON student
FOR EACH ROW
BEGIN
    INSERT INTO student_version (
        student_id,
        full_name,
        email,
        registration_date,
        status,
        valid_from,
        valid_to,
        is_current,
        version_num
    )
    VALUES (
        NEW.student_id,
        NEW.full_name,
        NEW.email,
        NEW.registration_date,
        NEW.status,
        CURRENT_TIMESTAMP,
        NULL,
        1,
        1
    );
END;

--Триггер 2. После изменения данных студента закрывает старую версию и создаёт новую
CREATE TRIGGER trg_student_version_after_update
AFTER UPDATE OF full_name, email, registration_date, status ON student
FOR EACH ROW
WHEN
    OLD.full_name <> NEW.full_name OR
    OLD.email <> NEW.email OR
    OLD.registration_date <> NEW.registration_date OR
    OLD.status <> NEW.status
BEGIN
    UPDATE student_version
    SET valid_to = CURRENT_TIMESTAMP,
        is_current = 0
    WHERE student_id = OLD.student_id
      AND is_current = 1;
    INSERT INTO student_version (
        student_id,
        full_name,
        email,
        registration_date,
        status,
        valid_from,
        valid_to,
        is_current,
        version_num
    )
    VALUES (
        NEW.student_id,
        NEW.full_name,
        NEW.email,
        NEW.registration_date,
        NEW.status,
        CURRENT_TIMESTAMP,
        NULL,
        1,
        (
            SELECT COALESCE(MAX(version_num), 0) + 1
            FROM student_version
            WHERE student_id = NEW.student_id
        )
    );
END;