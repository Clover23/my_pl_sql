CREATE PACKAGE UTIL AS

TYPE rec_emp_region IS RECORD(region_name VARCHAR2(50), region_employees NUMBER);

TYPE tab_regional_employees IS TABLE OF rec_emp_region;

FUNCTION get_region_cnt_emp(p_department_id IN NUMBER default null) RETURN tab_regional_employees PIPELINED;

END UTIL;





CREATE PACKAGE BODY UTIL AS

FUNCTION get_region_cnt_emp(p_department_id IN NUMBER default null) RETURN tab_regional_employees PIPELINED IS
    out_tab_regemp tab_regional_employees := tab_regional_employees();
    l_cur SYS_REFCURSOR;
BEGIN
    OPEN l_cur FOR
        SELECT r.region_name, COUNT(e.employee_id) AS num_emp
            FROM hr.regions r LEFT JOIN hr.countries c
            ON r.region_id = c.region_id
            LEFT JOIN hr.locations loc
            ON c.country_id = loc.country_id
            LEFT JOIN hr.departments d
            ON loc.location_id = d.location_id
            LEFT JOIN hr.employees e
            ON d.department_id = e.department_id
            WHERE (e.department_id = null or null is null)
            GROUP BY r.region_name;
    BEGIN
        LOOP
            EXIT WHEN l_cur%NOTFOUND;
                FETCH l_cur BULK COLLECT
                INTO out_tab_regemp;
                    FOR i IN 1 .. out_tab_regemp.count LOOP
                        PIPE ROW(out_tab_regemp(i));
        END LOOP;
        END LOOP;
        CLOSE l_cur;
        EXCEPTION
            WHEN OTHERS THEN
                IF (l_cur%ISOPEN) THEN
                    CLOSE l_cur;
                RAISE;
                ELSE
                RAISE;
                END IF;
    END;
END get_region_cnt_emp;

END UTIL;
