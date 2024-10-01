-- створюємо тригер який автоматично оновлює поле EMPLOYEES.HIRE_DATE при оновленні job_id

CREATE OR REPLACE TRIGGER hire_date_update
BEFORE UPDATE ON employees
FOR EACH ROW
DECLARE 
    PRAGMA autonomous_transaction;
BEGIN
    IF :OLD.job_id != :NEW.job_id THEN
        :NEW.hire_date := TRUNC(SYSDATE);
    END IF;
    COMMIT;
END hire_date_update;


/* щоб перевірити чи тригер спрацьовує змінюємо job_id для котрогось з працівників (наприклад з employee_id = 150)
і перевіряємо чи після цього змінилася hire_date на сьогоднішню (початкова hire_date має бути відмінною від сьогодні)*/

DECLARE
    v_old_j_id VARCHAR2(50);
    v_new_j_id VARCHAR2(50);
    v_old_hire_date DATE;
    v_new_hire_date DATE;
    v_employee_id NUMBER := 150; -- employee_id для якого робимо зміни
BEGIN
    SELECT job_id INTO v_old_j_id FROM employees WHERE employee_id = v_employee_id; -- фіксуємо job_id яка була
    SELECT hire_date INTO v_old_hire_date FROM employees WHERE employee_id = v_employee_id; -- фіксуємо попередню hire_date
    
    UPDATE employees em
    SET em.job_id = 'MK_TST'
    WHERE em.employee_id = v_employee_id;
    COMMIT;
    
    SELECT job_id INTO v_new_j_id FROM employees WHERE employee_id = v_employee_id; -- фіксуємо нову job_id 
    SELECT hire_date into v_new_hire_date FROM employees WHERE employee_id = v_employee_id; -- фіксуємо нову hire_date
    
    -- перевіряємо чи відрізняються старі і нові значення обох показників
    IF v_new_j_id <> v_old_j_id AND v_old_hire_date <> v_new_hire_date THEN
        dbms_output.put_line('Тригер спрацював');
    ELSE
        dbms_output.put_line('Тригер не спрацював');
    END IF;
    dbms_output.put_line('Початкова дата найму: '||v_old_hire_date);
    dbms_output.put_line('Оновлена дата найму: '||v_new_hire_date);
    dbms_output.put_line('Початкова спеціалізація: '||v_old_j_id);
    dbms_output.put_line('Нова спеціалізація: '||v_new_j_id);
END;