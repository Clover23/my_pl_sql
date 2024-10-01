-- ������� ������� hr.employees � ���� �����
CREATE TABLE employees AS SELECT * FROM hr.employees;

-- ������ ���� � �������
INSERT INTO employees 
VALUES (207,'Kate','Shlapatska','CATRINASH8','650.507.5656', '27-AUG-2024', 'IT-QA', 3000, NULL, 101, 10);

-- ��������� ���
DECLARE
    v_emp_id NUMBER := 207; -- ��� ��� ���� �� ��������.  
    v_recipient VARCHAR2(50); -- � �� ����� ��������� ��� ���� � �������
    v_subject VARCHAR2(50) := 'test_subject';
    v_mes VARCHAR2(5000) := '³��� ��������! </br> ��� ��� � ����� ������: </br></br>';
BEGIN

    -- �������� ����� � ������� � ������ ���������� �����
    SELECT e.email INTO v_recipient FROM employees e WHERE e.employee_id = v_emp_id;
    v_recipient := v_recipient||'@gmail.com';
    
    -- ���� �������
    SELECT
    v_mes||'<!DOCTYPE html>
        <html>
            <head>
                <title></title>
                <style> table, th, td {border: 1px solid;}.center{text-align: center;}</style>
            </head>
            <body>
                <table border=1 cellspacing=0 cellpadding=2 rules=GROUPS frame=HSIDES>
                    <thead>
                        <tr align=left>
                            <th>�� ������������</th>
                            <th>ʳ������ �����������</th>
                        </tr>
                    </thead>
                <tbody>
                '|| list_html || '
                </tbody>
                </table>
            </body>
    </html>' AS html_table
    INTO v_mes
    FROM (
        SELECT LISTAGG('<tr align=left>
            <td>' || department_id || '</td>' || '
            <td class=''center''> ' || t.employees_num||'</td>
            </tr>', '<tr>') 
            WITHIN GROUP (ORDER BY t.department_id) AS list_html
    FROM
    (
        SELECT 
        -- � 1 ����������, ���� �� �������� �� ������� ������������ ��� ����� ���� �� ������������ ���� ������
        department_id,
        COUNT(*) AS employees_num
        FROM employees  
        GROUP BY department_id
    ) t);
    v_mes := v_mes || '</br></br> � �������, �';
    sys.sendmail(p_recipient => v_recipient,
    p_subject => v_subject,
    p_message => v_mes || ' ');
END;
