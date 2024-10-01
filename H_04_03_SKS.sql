
CREATE OR REPLACE PACKAGE UTIL AS

PROCEDURE add_new_jobs(p_job_id IN VARCHAR2,
                                p_job_title IN VARCHAR2,
                                p_min_salary IN NUMBER,
                                p_max_salary IN NUMBER DEFAULT NULL,
                                po_err OUT VARCHAR2);
                                
PROCEDURE del_jobs (P_JOB_ID   IN VARCHAR2,
                           PO_RESULT  OUT VARCHAR2);

FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER;
                    
END UTIL;
/

CREATE OR REPLACE PACKAGE BODY UTIL AS

c_percent_of_min_salary CONSTANT NUMBER := 1.5;

PROCEDURE check_work_time AS
v_is_weekend EXCEPTION;
    BEGIN   
    
    IF TO_CHAR(SYSDATE, 'DY', 'NLS_DATE_LANGUAGE = AMERICAN') IN ('SAT', 'SUN') THEN
        raise v_is_weekend;
        END IF;
        
    EXCEPTION
        WHEN v_is_weekend THEN
            raise_application_error(-20205, 'Ви можете вносити зміни лише у робочі дні');
            
    END check_work_time;



PROCEDURE add_new_jobs(p_job_id     IN VARCHAR2,
					   p_job_title  IN VARCHAR2,
					   p_min_salary IN NUMBER,
					   p_max_salary IN NUMBER DEFAULT NULL,
					   po_err       OUT VARCHAR2) IS
        v_max_salary jobs.max_salarY%TYPE;
        salary_err   EXCEPTION;
BEGIN
	
    check_work_time;
    
	IF p_max_salary IS NULL THEN
		v_max_salary := p_min_salary * c_percent_of_min_salary;
	ELSE
		v_max_salary := p_max_salary;
	END IF;
		BEGIN
			IF (p_min_salary < 2000 OR p_max_salary < 2000) THEN
				RAISE salary_err;
			END IF;
            
		INSERT INTO jobs(job_id, job_title, min_salary, max_salary)
			VALUES (p_job_id, p_job_title, p_min_salary, v_max_salary);
		po_err := 'Посада '||p_job_id||' успішно додана';
        
        EXCEPTION
        WHEN salary_err THEN
            raise_application_error(-20001, 'Передана зарплата менша за 2000');
        WHEN dup_val_on_index THEN
            raise_application_error(-20002, 'Посада '||p_job_id||' вже існує');
        WHEN OTHERS THEN
            raise_application_error(-20003, 'Виникла помилка при додаванні нової посади. '|| SQLERRM);
        END;
	--COMMIT;
END add_new_jobs;


PROCEDURE del_jobs (P_JOB_ID   IN VARCHAR2,
                           PO_RESULT  OUT VARCHAR2) IS
    v_delete_no_data_found EXCEPTION;
    
    BEGIN
        check_work_time;
        DELETE FROM JOBS J WHERE J.job_id = P_JOB_ID;
        IF SQL%ROWCOUNT = 0 THEN
            RAISE v_delete_no_data_found;
        ELSE
            PO_RESULT := 'Посада '||P_JOB_ID||' успішно видалена.';
        END IF;
        
        EXCEPTION
            WHEN v_delete_no_data_found THEN
                raise_application_error(-20004,'Посада '||P_JOB_ID||' не існує.' );
        
        
    END del_jobs;
    
FUNCTION get_sum_price_sales(p_table IN VARCHAR2) RETURN NUMBER IS
    p_sum NUMBER;
    v_message VARCHAR2(500);
    v_sql_code VARCHAR2(500);
    BEGIN
        IF p_table IN ('products', 'products_old') THEN
            v_sql_code := 'SELECT SUM(price_sales) from hr.'||p_table;
            EXECUTE IMMEDIATE v_sql_code INTO p_sum;
            RETURN p_sum;
        ELSE
            v_message := 'Неприпустиме значення! Очікується products або products_old';
            -- Припускаємо що процедура to_log існує
            to_log(p_appl_proc => 'util.get_sum_price_sales', p_message => v_message);
            raise_application_error(-20001, v_message);
        END IF;
               
    END;


END UTIL;
/

