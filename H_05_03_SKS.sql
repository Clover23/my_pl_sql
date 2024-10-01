-- Копіюємо таблицю hr.employees в свою схему
CREATE TABLE employees AS SELECT * FROM hr.employees;

-- Додаємо себе в таблицю
INSERT INTO employees 
VALUES (207,'Kate','Shlapatska','CATRINASH8','650.507.5656', '27-AUG-2024', 'IT-QA', 3000, NULL, 101, 10);

-- Створюємо звіт
DECLARE
    v_emp_id NUMBER := 207; -- Наш айді який ми створили.  
    v_recipient VARCHAR2(50); -- В цю змінну збережемо свій мейл з таблиці
    v_subject VARCHAR2(50) := 'test_subject';
    v_mes VARCHAR2(5000) := 'Вітаю шановний! </br> Ось звіт з нашою компанії: </br></br>';
BEGIN

    -- Вибираємо пошту з таблиці й додаємо розширення пошти
    SELECT e.email INTO v_recipient FROM employees e WHERE e.employee_id = v_emp_id;
    v_recipient := v_recipient||'@gmail.com';
    
    -- Опис таблиці
    SELECT
    v_mes||'<!DOCTYPE html>
        <html>
            <head>
                <title></title>
                <style> table, th, td {border: 1px solid;}.center{text-align: center;}</style>
            </head>
            <body>
                <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
                    <thead>
                        <tr align=left>
                            <th>Ід департаменту</th>
                            <th>Кількість співробітників</th>
                        </tr>
                    </thead>
                <tbody>
                '|| list_html || '
                </tbody>
                </table>
            </body>
    </html>' AS html_table
    INTO v_mes
    FROM (
        SELECT LISTAGG('<tr align=left>
            <td>' || department_id || '</td>' || '
            <td class=''center''> ' || t.employees_num||'</td>
            </tr>', '<tr>') 
            WITHIN GROUP (ORDER BY t.department_id) AS list_html
    FROM
    (
        SELECT 
        -- Є 1 співробітник, який не належить до жодного департаменту для нього поле Ід департаменту буде порожнє
        department_id,
        COUNT(*) AS employees_num
        FROM employees  
        GROUP BY department_id
    ) t);
    v_mes := v_mes || '</br></br> З повагою, К';
    sys.sendmail(p_recipient => v_recipient,
    p_subject => v_subject,
    p_message => v_mes || ' ');
END;
