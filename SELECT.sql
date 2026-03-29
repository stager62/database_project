--1. Выводит курсы, преподавателей и количество студентов на курсе
SELECT c.course_id,
       c.title,
       t.full_name AS teacher_name,
       COUNT(e.student_id) AS student_count
FROM course c
         JOIN teacher t ON c.teacher_id = t.teacher_id
         LEFT JOIN enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id, c.title, t.full_name
ORDER BY student_count DESC, c.course_id;

--2. Выводит студентов и количество курсов, на которые они записаны
SELECT s.student_id,
       s.full_name,
       COUNT(e.course_id) AS course_count
FROM student s
         LEFT JOIN enrollment e ON s.student_id = e.student_id
GROUP BY s.student_id, s.full_name
ORDER BY course_count DESC, s.student_id;

--3. Выводит средний балл по каждому заданию для проверенных работ
SELECT a.title,
       AVG(s.score) AS avg_score
FROM assignment a
         JOIN submission s ON a.assignment_id = s.assignment_id
WHERE s.status = 'reviewed'
GROUP BY a.assignment_id, a.title
ORDER BY avg_score DESC, a.assignment_id;

--4. Выводит преподавателей и количество курсов, которые они ведут
SELECT t.teacher_id,
       t.full_name,
       COUNT(c.course_id) AS course_count
FROM teacher t
         LEFT JOIN course c ON t.teacher_id = c.teacher_id
GROUP BY t.teacher_id, t.full_name
ORDER BY course_count DESC, t.teacher_id;

--5. Выводит курсы у которых средний прогресс выше среднего прогресса enrollment
SELECT q.course_id,
       q.title,
       q.avg_progress
FROM (
         SELECT c.course_id,
                c.title,
                AVG(e.progress_percent) AS avg_progress
         FROM course c
                  JOIN enrollment e ON c.course_id = e.course_id
         GROUP BY c.course_id, c.title
     ) q
WHERE q.avg_progress > (SELECT AVG(progress_percent) FROM enrollment)
ORDER BY q.avg_progress DESC, q.course_id;

--6. Выводит студентов, у которых есть просроченная работа
SELECT DISTINCT st.full_name
FROM student st
         JOIN submission s ON st.student_id = s.student_id
WHERE s.status = 'late'
ORDER BY st.full_name;

--7. Выводит задания, количество сдач по ним и средний балл по проверенным работам
SELECT a.assignment_id,
       a.title,
       COUNT(s.student_id) AS submission_count,
       AVG(CASE
               WHEN s.status = 'reviewed' THEN s.score
           END) AS avg_reviewed_score
FROM assignment a
         LEFT JOIN submission s ON a.assignment_id = s.assignment_id
GROUP BY a.assignment_id, a.title
ORDER BY submission_count DESC, a.assignment_id;

--8. Выводит студентов, у которых максимальный балл выше среднего максимального балла всех студентов
SELECT q.student_id,
       q.full_name,
       q.max_score
FROM (
         SELECT st.student_id,
                st.full_name,
                MAX(s.score) AS max_score
         FROM student st
                  JOIN submission s ON st.student_id = s.student_id
         GROUP BY st.student_id, st.full_name
     ) q
WHERE q.max_score > (
    SELECT AVG(x.student_max_score)
    FROM (
             SELECT MAX(score) AS student_max_score
             FROM submission
             GROUP BY student_id
         ) x
)
ORDER BY q.max_score DESC, q.student_id;

--9. Выводит студентов и их максимальный балл
SELECT st.full_name,
       MAX(s.score) AS max_score
FROM student st
         JOIN submission s ON st.student_id = s.student_id
GROUP BY st.student_id, st.full_name
ORDER BY max_score DESC, st.student_id;

--10. Выводит студентов, количество их сдач и средний балл по проверенным работам
SELECT st.student_id,
       st.full_name,
       COUNT(s.assignment_id) AS submissions_count,
       AVG(CASE
               WHEN s.status = 'reviewed' THEN s.score
           END) AS avg_reviewed_score
FROM student st
         LEFT JOIN submission s ON st.student_id = s.student_id
GROUP BY st.student_id, st.full_name
ORDER BY submissions_count DESC, avg_reviewed_score DESC, st.student_id;