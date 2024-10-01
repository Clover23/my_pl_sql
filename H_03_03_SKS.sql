-- Створюємо пакет та оголошуємо специфікацію
CREATE PACKAGE UTIL AS

FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR;
FUNCTION get_dep_name(p_employee_id IN VARCHAR) RETURN VARCHAR2;

PROCEDURE DEL_JOBS (P_JOB_ID   IN VARCHAR2,
                    PO_RESULT  OUT VARCHAR2);
                    
END UTIL;
/

-- Створюємо тіло пакета
CREATE PACKAGE BODY UTIL AS

FUNCTION get_job_title(p_employee_id IN NUMBER) RETURN VARCHAR IS
v_job_title jobs.job_title%TYPE;
BEGIN
    SELECT j.job_title
    INTO v_job_title
    FROM employees em
    JOIN jobs j
    ON em.job_id = j.job_id
    WHERE em.employee_id = p_employee_id;
    RETURN v_job_title;
END get_job_title;


FUNCTION get_dep_name(p_employee_id IN VARCHAR) RETURN VARCHAR2 IS
v_dep_name departments.department_name%TYPE;
BEGIN
    SELECT d.department_name 
    INTO v_dep_name
    FROM employees E JOIN departments D 
    ON E.department_id = D.department_id 
    WHERE E.employee_id = p_employee_id;

    RETURN v_dep_name;
END get_dep_name;


PROCEDURE DEL_JOBS (P_JOB_ID   IN VARCHAR2,
                    PO_RESULT  OUT VARCHAR2) IS
    v_vacancy NUMBER;
    
    BEGIN

    SELECT COUNT(*) INTO v_vacancy
    FROM JOBS J 
    WHERE J.job_id = P_JOB_ID;
    IF v_vacancy > 0 THEN    
        DELETE FROM JOBS J WHERE J.job_id = P_JOB_ID;
        PO_RESULT := 'Посада '||P_JOB_ID||' успішно видалена.';     
    ELSE
		PO_RESULT := 'Посада '||P_JOB_ID||' не існує.';
    END IF;
END DEL_JOBS;


END UTIL;
/


-- Видаляємо процедуру на функції з кореня пакета

DROP PROCEDURE del_jobs;
DROP FUNCTION get_dep_name;
DROP FUNCTION get_job_title;

-- Викликаємо процедури та функції з пакета

DECLARE
    v_job_title VARCHAR2(100);
    v_dep_name VARCHAR2(100);
    v_deleted VARCHAR2(100);
BEGIN
    v_job_title := util.get_job_title(p_employee_id => 150);
    v_dep_name := util.get_dep_name(p_employee_id => 150);
    util.del_jobs(p_job_id => 'AA_AA', PO_RESULT => v_deleted);

    dbms_output.put_line('Job title is '||v_job_title);
    dbms_output.put_line('Department name is '||v_dep_name);
    dbms_output.put_line(v_deleted);
END;
/

-- Викликаємо функцію через селект
SELECT util.get_dep_name(150) FROM dual;
