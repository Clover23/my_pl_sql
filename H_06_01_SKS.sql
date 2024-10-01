--SET DEFINE OFF;

-- створюємо таблицю interbank_index_ua_history в БД під структуру відповіді JSON структури

CREATE TABLE interbank_index_ua_history (dt DATE,
                              id_api VARCHAR2(50),
                              value NUMBER,
                              special VARCHAR2(1));


/* створюємо view interbank_index_ua_v на основі виклику API через функцію SYS.GET_NBU
яка повинна відразу парсити JSON структуру в окремі стовпчики зпотрібним типом даних.
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


/* створюємо процедуру download_ibank_index_ua, яка повинна вставляти дані з view
interbank_index_ua_v втаблицю interbank_index_ua_history*/

CREATE OR REPLACE PROCEDURE download_ibank_index_ua IS
BEGIN
    INSERT INTO interbank_index_ua_history
    SELECT * FROM interbank_index_ua_v;
END;


/*процедуру download_ibank_index_ua ставимо на шедулер з інтервалом кожен день в 9 ранку*/

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
                                    comments => 'Оновлення індекса міжбанківських ставок овернайт');
END;
