--MIS 325 HW 6
--Victoria Vu vtv244

--Question 1A/1C
SET SERVEROUTPUT ON;

DECLARE
    count_reservations      NUMBER;
BEGIN 
    SELECT COUNT(distinct reservation_id)
    INTO count_reservations
    FROM  reservation
    WHERE customer_id = '100002';
    IF count_reservations > 15 THEN 
        DBMS_OUTPUT.PUT_LINE('The customer has placed more than 15 reservations.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The customer has placed 15 or fewer reservations.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred');
END;
/
    
--Question 1B/1C
DELETE FROM reservation_details 
        WHERE reservation_id = 318;

DELETE FROM reservation 
        WHERE reservation_id = 318;
        
--Question 1D
ROLLBACK;

--Question 2
SET DEFINE ON;

DECLARE
    customer_id_input          reservation.customer_id%TYPE := &EnterCustomerID;
    count_reservations         NUMBER;
BEGIN 
    SELECT COUNT(reservation_id)
    INTO count_reservations
    FROM  reservation
    WHERE customer_id = customer_id_input;

    IF count_reservations > 15 THEN 
        DBMS_OUTPUT.PUT_LINE('The customers with customer ID: ' || customer_id_input || ', has placed more than 15 reservations.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('The customers with customer ID: ' || customer_id_input || ', has placed 15 or fewer reservations.');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred');
END;
    /

--Question 3
SET SERVEROUTPUT ON;
BEGIN 
    INSERT INTO customer    (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, 
                            ADDRESS_LINE_1, ADDRESS_LINE_2, CITY, STATE, ZIP, BIRTHDATE, 
                            STAY_CREDITS_EARNED, STAY_CREDITS_USED)
    VALUES (CUSTOMER_ID_SEQ.nextval, 'Victoria', 'Vu', 'victoriatvvu@gmail.com', '777-777-7777', 
            '0821 Sushi Cat Ln.', '', 'Austin', 'TX', '11721', '21-AUG-2001', '', '');
    DBMS_OUTPUT.PUT_LINE('1 row inserted.');
COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Row was not inserted. Unexpected exception occurred.');
END;
    /

--Question 4
DECLARE
    TYPE features_table     IS TABLE OF VARCHAR2(40);
    feature_names           features_table;
BEGIN
    SELECT feature_name
    BULK COLLECT INTO feature_names
    FROM features
    WHERE SUBSTR(feature_name,1,1) = 'P'
    ORDER BY feature_name;
    
    FOR i IN 1..feature_names.COUNT LOOP
        DBMS_OUTPUT.PUT_LINE('Hotel feature ' || i || ': ' || feature_names(i));
    END LOOP;
END;
/

--Question 5
SET SERVEROUTPUT ON;
DECLARE
  CURSOR features_cursor IS
    SELECT feature_name, location_name, city
    FROM location l 
    JOIN location_features_linking lf
    ON l.location_id = lf.location_id
    JOIN features f
    ON f.feature_id = lf.feature_id
    ORDER BY location_name, city, feature_name;
    
    feature_row    features%rowtype;

BEGIN
      FOR feature_row IN features_cursor LOOP 
        DBMS_OUTPUT.PUT_LINE(feature_row.location_name || ' ' || 'in' || ' ' || feature_row.city ||
                   ' ' || 'has feature: '  ||  feature_row.feature_name);
  END LOOP;
END;
/


--Question 6
CREATE OR REPLACE PROCEDURE insert_new_customer
(
first_name_param            customer.first_name%TYPE,
last_name_param             customer.last_name%TYPE,
email_param                 customer.email%TYPE,
phone_param                 customer.phone%TYPE,
address_line_1_param        customer.address_line_1%TYPE,
city_param                  customer.city%TYPE,
state_param                 customer.state%TYPE,
zip_param                   customer.zip%TYPE
)
AS
BEGIN 
    INSERT INTO customer (CUSTOMER_ID, FIRST_NAME, LAST_NAME, EMAIL, PHONE, ADDRESS_LINE_1, CITY, STATE, ZIP)
    VALUES (customer_id_seq.NEXTVAL, first_name_param, last_name_param, email_param, phone_param,
            address_line_1_param, city_param, state_param, zip_param);
            
    COMMIT;
DBMS_OUTPUT.PUT_LINE('1 row was inserted into the customer table.');

EXCEPTION
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('Row was not inserted. Unexpected exception occured.');
    ROLLBACK; 
END;
/


CALL insert_customer ('Joseph', 'Lee', 'jo12@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');

BEGIN
Insert_customer ('Mary', 'Lee', 'jo34@yahoo.com', '773-222-3344', 'Happy street', 'Chicago', 'Il', '60602');
END;
/  

--Question 7
CREATE OR REPLACE FUNCTION hold_count
(
    customer_id_param     customer.customer_id%TYPE
)
RETURN NUMBER
AS
    hold_count_var   NUMBER;
BEGIN
    SELECT COUNT(*) 
    INTO hold_count_var
    FROM customer
    WHERE customer_id = customer_id_param;

    RETURN hold_count_var;
END;
/

select customer_id, hold_count(customer_id)  
from reservation
group by customer_id
order by customer_id;
