-- ��������� ������ ���� ����������� ������� ���� EMPLOYEES.HIRE_DATE ��� �������� job_id

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


/* ��� ��������� �� ������ ��������� ������� job_id ��� ��������� � ���������� (��������� � employee_id = 150)
� ���������� �� ���� ����� �������� hire_date �� ���������� (��������� hire_date �� ���� ������� �� �������)*/

DECLARE
    v_old_j_id VARCHAR2(50);
    v_new_j_id VARCHAR2(50);
    v_old_hire_date DATE;
    v_new_hire_date DATE;
    v_employee_id NUMBER := 150; -- employee_id ��� ����� ������ ����
BEGIN
    SELECT job_id INTO v_old_j_id FROM employees WHERE employee_id = v_employee_id; -- ������� job_id ��� ����
    SELECT hire_date INTO v_old_hire_date FROM employees WHERE employee_id = v_employee_id; -- ������� ��������� hire_date
    
    UPDATE employees em
    SET em.job_id = 'MK_TST'
    WHERE em.employee_id = v_employee_id;
    COMMIT;
    
    SELECT job_id INTO v_new_j_id FROM employees WHERE employee_id = v_employee_id; -- ������� ���� job_id 
    SELECT hire_date into v_new_hire_date FROM employees WHERE employee_id = v_employee_id; -- ������� ���� hire_date
    
    -- ���������� �� ����������� ���� � ��� �������� ���� ���������
    IF v_new_j_id <> v_old_j_id AND v_old_hire_date <> v_new_hire_date THEN
        dbms_output.put_line('������ ���������');
    ELSE
        dbms_output.put_line('������ �� ���������');
    END IF;
    dbms_output.put_line('��������� ���� �����: '||v_old_hire_date);
    dbms_output.put_line('�������� ���� �����: '||v_new_hire_date);
    dbms_output.put_line('��������� ������������: '||v_old_j_id);
    dbms_output.put_line('���� ������������: '||v_new_j_id);
END;