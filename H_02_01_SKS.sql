DECLARE
    v_employee_id hr.employees.employee_id%TYPE := 150;
    v_job_id hr.employees.job_id%TYPE;
    v_job_title hr.jobs.job_title%TYPE;
BEGIN
    SELECT E.job_id INTO v_job_id FROM hr.employees E WHERE E.employee_id = v_employee_id;
    SELECT J.job_title INTO v_job_title FROM hr.jobs J WHERE J.job_id = v_job_id;
    dbms_output.put_line(v_job_title);
END;
/