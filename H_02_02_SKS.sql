DECLARE
    v_def_percent VARCHAR(30);
    v_percent VARCHAR(5);
BEGIN

    FOR cc IN (SELECT (E.first_name || ' ' || E.last_name) AS name, 
        (commission_pct * 100) AS percent_of_salary, 
        E.manager_id 
        FROM hr.employees E 
        WHERE department_id = 80 ORDER BY name) LOOP
        
        IF cc.manager_id = 100 THEN
            dbms_output.put_line('Співробітник - '||cc.name||', процент до зарплати на зараз заборонений');
            CONTINUE;
        END IF;
            
        IF cc.percent_of_salary >= 10 AND cc.percent_of_salary <= 20 THEN
            v_def_percent := 'мінімальний';
        END IF;
        
        IF cc.percent_of_salary >= 25 AND cc.percent_of_salary <= 30 THEN
            v_def_percent := 'середній';
        END IF;
        
        IF cc.percent_of_salary >= 35 AND cc.percent_of_salary <= 40 THEN
            v_def_percent := 'максимальний';
        END IF;
        
        v_percent := CONCAT(cc.percent_of_salary, '%');
        
        dbms_output.put_line('Співробітник - '||cc.name||'; процент до зарплати - '|| v_percent|| '; опис процента - '||v_def_percent);
        
        END LOOP;
END;
/