-- Створюємо VIEW із заданого файла

CREATE VIEW rep_project_dep_v AS
SELECT ext_fl.project_id, ext_fl.project_name, ext_fl.department_id
FROM EXTERNAL ( ( project_id NUMBER,
                project_name VARCHAR2(100),
                department_id NUMBER )
    TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER -- вказуємо назву директорії в БД
    ACCESS PARAMETERS ( records delimited BY newline
                        nologfile
                        nobadfile
                        fields terminated BY ','
                        missing field VALUES are NULL )
    LOCATION('PROJECTS.csv') -- вказуємо назву файлу
    REJECT LIMIT UNLIMITED /*немає обмежень для відкидання рядків*/) ext_fl;


-- Створюємо звіт і записуємо файл

DECLARE
    file_handle UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200) := 'FILES_FROM_SERVER'; -- Назва створеної директорії
    file_name VARCHAR2(200) := 'TOTAL_PROJ_INDEX_SKS.csv'; -- Ім'я файлу, який буде записаний
    file_content VARCHAR2(2000); -- Вміст файлу
    file_row VARCHAR2(500);
BEGIN
    -- Отримати вміст файлу з бази даних
    /*Я роблю це через джойни таблиць hr.departments та hr.employees, причому, 
    щоб вибрати кількість співробітників і їх сумарну ЗП роблю джойн hr.employees з самою собою.
    Розумію що це не елегантно, але не дуже розумію як зробити красивіше, на жаль*/
    
    file_content := 'DEPARTMENT NAME,NUMBER OF EMPLOYEES,QNIQUE MANAGERS,COMPOUND SALARY'||CHR(10); -- назви стовпців звіту
    
    -- Для кожного айді з ep_project_dep_v вибираємо дані з таблиць
    FOR cc IN (SELECT v.department_id  AS id
        FROM rep_project_dep_v v)LOOP
        
            SELECT d.department_name||','|| emp.employees||','|| 
            emp.managers||','|| sal.salary INTO file_row from hr.departments d
            JOIN      
                (   
                    SELECT
                    e.department_id,
                    COUNT(e.employee_id) AS employees,
                    COUNT(DISTINCT e.manager_id) AS managers
                    FROM hr.employees e WHERE e.department_id = cc.id GROUP BY e.department_id) emp
                ON d.department_id = emp.department_id
            JOIN
                (SELECT department_id, SUM(salary) AS salary from hr.employees WHERE department_id=cc.id GROUP BY department_id) sal
                ON emp.department_id = sal.department_id;
        
        -- додаємо новий рядок до загального змісту
        file_content := file_content || file_row||CHR(10);
   
        END LOOP;
        
    file_handle := UTL_FILE.FOPEN(file_location, file_name, 'W');
    -- Записати вміст файлу в файл на диск
    UTL_FILE.PUT_RAW(file_handle, UTL_RAW.CAST_TO_RAW(file_content));
    -- Закрити файл
    UTL_FILE.FCLOSE(file_handle);
        EXCEPTION
        WHEN OTHERS THEN
        -- Обробка помилок, якщо необхідно
        RAISE;
END;

