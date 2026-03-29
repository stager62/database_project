SELECT c.title, t.full_name AS teacher_name
FROM course c
JOIN teacher t ON c.teacher_id = t.teacher_id;

SELECT c.title, COUNT(e.student_id) AS student_count
FROM course c
LEFT JOIN enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id;

SELECT a.title, AVG(s.score) AS avg_score
FROM assignment a
JOIN submission s ON a.assignment_id = s.assignment_id
WHERE s.status = 'reviewed'
GROUP BY a.assignment_id;

SELECT st.full_name, COUNT(s.assignment_id) AS submissions_count
FROM student st
LEFT JOIN submission s ON st.student_id = s.student_id
GROUP BY st.student_id;

SELECT st.full_name
FROM student st
LEFT JOIN enrollment e ON st.student_id = e.student_id
WHERE e.course_id IS NULL;

SELECT c.title
FROM course c
LEFT JOIN enrollment e ON c.course_id = e.course_id
WHERE e.student_id IS NULL;

SELECT DISTINCT st.full_name
FROM student st
JOIN submission s ON st.student_id = s.student_id
WHERE s.status = 'late';

SELECT a.title
FROM assignment a
LEFT JOIN submission s ON a.assignment_id = s.assignment_id
WHERE s.assignment_id IS NULL;

SELECT st.full_name, MAX(s.score) AS max_score
FROM student st
JOIN submission s ON st.student_id = s.student_id
GROUP BY st.student_id;

SELECT c.title, AVG(e.progress_percent) AS avg_progress
FROM course c
JOIN enrollment e ON c.course_id = e.course_id
GROUP BY c.course_id;