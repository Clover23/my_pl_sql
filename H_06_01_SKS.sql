--SET DEFINE OFF;

-- ��������� ������� interbank_index_ua_history � �� �� ��������� ������ JSON ���������

CREATE TABLE interbank_index_ua_history (dt DATE,
                              id_api VARCHAR2(50),
                              value NUMBER,
                              special VARCHAR2(1));


/* ��������� view interbank_index_ua_v �� ����� ������� API ����� ������� SYS.GET_NBU
��� ������� ������ ������� JSON ��������� � ����� ��������� ��������� ����� �����.
*/

CREATE VIEW interbank_index_ua_v AS
    SELECT TO_DATE(tt.dt, 'dd.mm.yyyy') AS dt, tt.id_api, tt.value, tt.special
        FROM (SELECT SYS.GET_NBU(p_url => 'https://bank.gov.ua/NBU_uonia?id_api=UONIA_UnsecLoansDepo&json') AS json_value
        FROM dual) 
        CROSS JOIN json_table
            (
            json_value, '$[*]'
            COLUMNS
            (
                dt  VARCHAR2(100)        PATH   '$.dt',
                id_api   VARCHAR2(100) PATH   '$.id_api',
                value  NUMBER        PATH   '$.value',
                special   VARCHAR2(100) PATH   '$.special'
                )
        ) TT;


/* ��������� ��������� download_ibank_index_ua, ��� ������� ��������� ��� � view
interbank_index_ua_v �������� interbank_index_ua_history*/

CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS
BEGIN
    INSERT INTO interbank_index_ua_history
    SELECT * FROM interbank_index_ua_v;
END;


/*��������� download_ibank_index_ua ������� �� ������� � ���������� ����� ���� � 9 �����*/

BEGIN
    sys.dbms_scheduler.create_job(job_name => 'daily_ibank_index',
                                    job_type => 'PLSQL_BLOCK',
                                    job_action => 'begin download_ibank_index_ua; end;',
                                    start_date => SYSDATE,
                                    repeat_interval => 'FREQ=DAILY; BYHOUR=9',
                                    end_date => TO_DATE(NULL),
                                    job_class => 'DEFAULT_JOB_CLASS',
                                    enabled => TRUE,
                                    auto_drop => FALSE,
                                    comments => '��������� ������� ������������ ������ ��������');
END;
