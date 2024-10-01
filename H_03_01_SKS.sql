-- ���������� �� job_id � ������� jobs � ��������� � � ����� v_vacancy � ��� ���� ��� 1 (���� ������ ����), 
-- ��� 0 (���� ������ �� ����)

create PROCEDURE del_jobs (P_JOB_ID   IN VARCHAR2,
                           PO_RESULT  OUT VARCHAR2) IS
    v_vacancy NUMBER;
    
    BEGIN

        SELECT COUNT(*) INTO v_vacancy
        FROM JOBS J 
        WHERE J.job_id = P_JOB_ID;
        
        IF v_vacancy > 0 THEN    
            DELETE FROM JOBS J WHERE J.job_id = P_JOB_ID;
            PO_RESULT := '������ '||P_JOB_ID||' ������ ��������.';     
        ELSE
            PO_RESULT := '������ '||P_JOB_ID||' �� �����.';
        END IF;
        
    END del_jobs;