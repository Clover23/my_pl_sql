CREATE FUNCTION get_dep_name(p_employee_id IN VARCHAR) RETURN VARCHAR2 IS
v_dep_name departments.department_name%TYPE;
BEGIN
    SELECT d.department_name 
    INTO v_dep_name
    FROM employees E JOIN departments D 
    ON E.department_id = D.department_id 
    WHERE E.employee_id = p_employee_id;
    
    RETURN v_dep_name;
END;
/



SELECT EMPLOYEE_ID, FIRST_NAME, LAST_NAME, EMAIL, 
       PHONE_NUMBER, HIRE_DATE, get_job_title(E.employee_id) AS JOB_TITLE, 
       SALARY, COMMISSION_PCT, MANAGER_ID, get_dep_name(E.employee_id) AS DEPARTMENT
FROM employees E;
