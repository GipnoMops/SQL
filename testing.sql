# 1
# Вывести студентов, которые сдавали дисциплину «Основы баз данных», указать дату попытки и результат.
# Информацию вывести по убыванию результатов тестирования.

SELECT name_student, date_attempt, result
FROM subject 
    inner join attempt ON subject.subject_id = attempt.subject_id
    INNER JOIN student ON attempt.student_id = student.student_id
WHERE name_subject = 'Основы баз данных'
ORDER BY result DESC


# 2
# Вывести, сколько попыток сделали студенты по каждой дисциплине, а также средний результат попыток, 
# который округлить до 2 знаков после запятой. Под результатом попытки понимается процент правильных 
# ответов на вопросы теста, который занесен в столбец result.  В результат включить название дисциплины, 
# а также вычисляемые столбцы Количество и Среднее. Информацию вывести по убыванию средних результатов.

SELECT name_subject, COUNT(result) AS Количество,  ROUND(SUM(result) / COUNT(result), 2) AS Среднее
FROM subject LEFT JOIN attempt USING (subject_id)
GROUP BY name_subject 
ORDER BY Среднее DESC


# 3
# Вывести студентов (различных студентов), имеющих максимальные результаты попыток. 
# Информацию отсортировать в алфавитном порядке по фамилии студента.

SELECT name_student, result
FROM attempt INNER JOIN student USING(student_id)
WHERE result = (
     SELECT MAX(result) AS max_res
     FROM attempt INNER JOIN student USING(student_id)
     GROUP BY name_student 
     ORDER BY max_res DESC
     LIMIT 1
    )
ORDER BY name_student ASC


# 4
# Если студент совершал несколько попыток по одной и той же дисциплине, то вывести разницу в днях между первой и 
# последней попыткой. В результат включить фамилию и имя студента, название дисциплины и вычисляемый столбец Интервал. 
# Информацию вывести по возрастанию разницы. Студентов, сделавших одну попытку по дисциплине, не учитывать. 

SELECT name_student, name_subject, DATEDIFF(MAX(date_attempt), MIN(date_attempt)) AS Интервал
FROM subject
        INNER JOIN attempt USING(subject_id)
        INNER JOIN student USING(student_id)
GROUP BY name_student, name_subject
HAVING COUNT(date_attempt) > 1
ORDER BY Интервал ASC


# 5
# Студенты могут тестироваться по одной или нескольким дисциплинам (не обязательно по всем). 
# Вывести дисциплину и количество уникальных студентов (столбец назвать Количество), которые по ней проходили тестирование. 
# Информацию отсортировать сначала по убыванию количества, а потом по названию дисциплины. В результат включить и дисциплины,
# тестирование по которым студенты не проходили, в этом случае указать количество студентов 0.

SELECT name_subject, COUNT(DISTINCT(student_id)) AS Количество
FROM subject LEFT JOIN attempt USING(subject_id)
GROUP BY name_subject
ORDER BY Количество DESC, name_subject ASC


# 6 
# Случайным образом отберите 3 вопроса по дисциплине «Основы баз данных». В результат включите столбцы question_id и name_question.

SELECT question_id, name_question
FROM subject INNER JOIN question USING(subject_id)
WHERE name_subject = 'Основы баз данных'
ORDER BY RAND()
LIMIT 3


# 7
# Вывести вопросы, которые были включены в тест для Семенова Ивана по дисциплине «Основы SQL» 2020-05-17  
# (значение attempt_id для этой попытки равно 7). Указать, какой ответ дал студент и правильный он или нет (вывести Верно или Неверно). 
# В результат включить вопрос, ответ и вычисляемый столбец  Результат.

SELECT name_question, name_answer, IF(is_correct = 1, 'Верно', 'Неверно') AS Результат
FROM question
    inner join testing USING(question_id)
    INNER JOIN answer USING(answer_id)
WHERE attempt_id = 7 


# 8 
# Посчитать результаты тестирования. Результат попытки вычислить как количество правильных ответов,
# деленное на 3 (количество вопросов в каждой попытке) и умноженное на 100. Результат округлить до двух знаков после запятой.
# Вывести фамилию студента, название предмета, дату и результат. Последний столбец назвать Результат. 
# Информацию отсортировать сначала по фамилии студента, потом по убыванию даты попытки.

SELECT name_student, name_subject, date_attempt, ROUND(SUM(is_correct)/3 * 100, 2) AS Результат
#SELECT name_subject, date_attempt, name_student
FROM subject
    inner join attempt USING(subject_id)
    inner join testing USING(attempt_id)
    inner join student USING(student_id)
    inner join answer USING(answer_id)
GROUP BY attempt_id
ORDER BY name_student, date_attempt DESC


# 9 
# Для каждого вопроса вывести процент успешных решений, то есть отношение количества верных ответов к общему количеству ответов,
# значение округлить до 2-х знаков после запятой. Также вывести название предмета, к которому относится вопрос,
# и общее количество ответов на этот вопрос. В результат включить название дисциплины, вопросы по ней (столбец назвать Вопрос),
# а также два вычисляемых столбца Всего_ответов и Успешность. Информацию отсортировать сначала по названию дисциплины,
# потом по убыванию успешности, а потом по тексту вопроса в алфавитном порядке.
# Поскольку тексты вопросов могут быть длинными, обрезать их 30 символов и добавить многоточие "...".

SELECT name_subject, concat((SUBSTRING(name_question, 1, 30)) , '...') AS Вопрос, COUNT(name_answer) AS
Всего_ответов, ROUND(SUM(is_correct)/COUNT(is_correct) * 100, 2) AS Успешность
FROM testing
    JOIN question USING(question_id)
    JOIN answer USING(answer_id)
    JOIN subject USING(subject_id)
GROUP BY testing.question_id
ORDER BY name_subject, Успешность DESC, name_question
