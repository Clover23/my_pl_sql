

FUNCTION get_region_cnt_emp(p_department_id IN NUMBER default null) RETURN tab_regemp PIPELINED IS
    
BEGIN
    NULL;
END;


SELECT * FROM hr.regions;
SELECT * FROM hr.departments;
SELECT * FROM hr.employees e;
select * from hr.locations;

SELECT d.department_id, COUNT(e.employee_id) AS num_emp 
FROM hr.departments d
JOIN hr.employees e
ON d.department_id = e.department_id
GROUP BY d.department_id;

-- working select
SELECT r.region_name, COUNT(e.employee_id) AS num_emp 
FROM hr.regions r LEFT JOIN hr.countries c
ON r.region_id = c.region_id
LEFT JOIN hr.locations loc 
ON c.country_id = loc.country_id
LEFT JOIN hr.departments d
ON loc.location_id = d.location_id
LEFT JOIN hr.employees e
ON d.department_id = e.department_id
WHERE d.department_id = 80
GROUP BY r.region_name;

SELECT r.region_name, COUNT(c.country_id)
FROM hr.regions r JOIN hr.countries c
ON r.region_id = c.region_id
GROUP BY r.region_name;

SELECT COUNT(e.employee_id) FROM hr.employees e;








SELECT r.region_name, d.department_name 
FROM hr.regions r LEFT JOIN hr.countries c
ON r.region_id = c.region_id
LEFT JOIN hr.locations loc 
ON c.country_id = loc.country_id
LEFT JOIN hr.departments d
ON loc.location_id = d.location_id
ORDER BY r.region_name, d.department_name;
