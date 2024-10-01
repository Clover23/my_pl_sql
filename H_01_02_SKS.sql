
DECLARE
    v_date DATE := TO_DATE('7/11/2024', 'MM/DD/YYYY');
    v_day NUMBER;
BEGIN
    v_day := TO_NUMBER(TO_CHAR(v_date, 'DD'));
    IF v_day = TO_NUMBER(TO_CHAR(last_day(trunc(SYSDATE)), 'DD')) THEN
        dbms_output.put_line('Âèïëàòà çàðïëàòè');
    ELSIF v_day = 15 THEN
        dbms_output.Put_line('Âèïëàòà àâàíñó');
    ELSIF v_day < 15 THEN
        dbms_output.put_line('×åêàºìî íà àâàíñ');
    ELSIF v_day > 15 THEN
        dbms_output.put_line('×åêàºìî íà çàðïëàòó');
    END IF;
END;
/
