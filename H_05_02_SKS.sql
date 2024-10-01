-- ��������� VIEW �� �������� �����

CREATE VIEW rep_project_dep_v AS
SELECT ext_fl.project_id, ext_fl.project_name, ext_fl.department_id
FROM EXTERNAL ( ( project_id NUMBER,
                project_name VARCHAR2(100),
                department_id NUMBER )
    TYPE oracle_loader DEFAULT DIRECTORY FILES_FROM_SERVER -- ������� ����� �������� � ��
    ACCESS PARAMETERS ( records delimited BY newline
                        nologfile
                        nobadfile
                        fields terminated BY ','
                        missing field VALUES are NULL )
    LOCATION('PROJECTS.csv') -- ������� ����� �����
    REJECT LIMIT UNLIMITED /*���� �������� ��� ��������� �����*/) ext_fl;


-- ��������� ��� � �������� ����

DECLARE
    file_handle UTL_FILE.FILE_TYPE;
    file_location VARCHAR2(200) := 'FILES_FROM_SERVER'; -- ����� �������� ��������
    file_name VARCHAR2(200) := 'TOTAL_PROJ_INDEX_SKS.csv'; -- ��'� �����, ���� ���� ���������
    file_content VARCHAR2(2000); -- ���� �����
    file_row VARCHAR2(500);
BEGIN
    -- �������� ���� ����� � ���� �����
    /*� ����� �� ����� ������ ������� hr.departments �� hr.employees, �������, 
    ��� ������� ������� ����������� � �� ������� �� ����� ����� hr.employees � ����� �����.
    ������ �� �� �� ���������, ��� �� ���� ������ �� ������� ��������, �� ����*/
    
    file_content := 'DEPARTMENT NAME,NUMBER OF EMPLOYEES,QNIQUE MANAGERS,COMPOUND SALARY'||CHR(10); -- ����� �������� ����
    
    -- ��� ������� ��� � ep_project_dep_v �������� ��� � �������
    FOR cc IN (SELECT v.department_id  AS id
        FROM rep_project_dep_v v)LOOP
        
            SELECT d.department_name||','|| emp.employees||','|| 
            emp.managers||','|| sal.salary INTO file_row from hr.departments d
            JOIN      
                (   
                    SELECT
                    e.department_id,
                    COUNT(e.employee_id) AS employees,
                    COUNT(DISTINCT e.manager_id) AS managers
                    FROM hr.employees e WHERE e.department_id = cc.id GROUP BY e.department_id) emp
                ON d.department_id = emp.department_id
            JOIN
                (SELECT department_id, SUM(salary) AS salary from hr.employees WHERE department_id=cc.id GROUP BY department_id) sal
                ON emp.department_id = sal.department_id;
        
        -- ������ ����� ����� �� ���������� �����
        file_content := file_content || file_row||CHR(10);
   
        END LOOP;
        
    file_handle := UTL_FILE.FOPEN(file_location, file_name, 'W');
    -- �������� ���� ����� � ���� �� ����
    UTL_FILE.PUT_RAW(file_handle, UTL_RAW.CAST_TO_RAW(file_content));
    -- ������� ����
    UTL_FILE.FCLOSE(file_handle);
        EXCEPTION
        WHEN OTHERS THEN
        -- ������� �������, ���� ���������
        RAISE;
END;

