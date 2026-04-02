--Представление 1. Информация по курсам: преподаватель, количество студентов, количество заданий и средний прогресс
CREATE VIEW view_course_stats AS
SELECT
    c.course_id,
    c.title AS course_title,
    t.full_name AS teacher_name,
    COUNT(DISTINCT e.student_id) AS student_count,
    COUNT(DISTINCT a.assignment_id) AS assignment_count,
    ROUND(AVG(e.progress_percent), 2) AS avg_progress
FROM course c
JOIN teacher t ON c.teacher_id = t.teacher_id
LEFT JOIN enrollment e ON c.course_id = e.course_id
LEFT JOIN assignment a ON c.course_id = a.course_id
GROUP BY c.course_id, c.title, t.full_name;

--Представление 2. Информация по заданиям: курс, количество сдач по статусам и средний балл
CREATE VIEW view_submission_stats AS
SELECT
    a.assignment_id,
    a.title AS assignment_title,
    c.title AS course_title,
    COUNT(s.student_id) AS total_submissions,
    SUM(CASE WHEN s.status = 'reviewed' THEN 1 ELSE 0 END) AS reviewed_count,
    SUM(CASE WHEN s.status = 'submitted' THEN 1 ELSE 0 END) AS submitted_count,
    SUM(CASE WHEN s.status = 'late' THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN s.status = 'missing' THEN 1 ELSE 0 END) AS missing_count,
    ROUND(AVG(CASE WHEN s.status = 'reviewed' THEN s.score END), 2) AS avg_reviewed_score
FROM assignment a
JOIN course c ON a.course_id = c.course_id
LEFT JOIN submission s ON a.assignment_id = s.assignment_id
GROUP BY a.assignment_id, a.title, c.title;