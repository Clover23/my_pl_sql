-- Припускаємо що job_id у таблиці jobs є унікальним і у змінній v_vacancy у нас буде або 1 (якщо посада існує), 
-- або 0 (якщо посада не існує)

create PROCEDURE del_jobs (P_JOB_ID   IN VARCHAR2,
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
            PO_RESULT := 'Посада '||P_JOB_ID||' не існуєю.';
        END IF;
        
    END del_jobs;