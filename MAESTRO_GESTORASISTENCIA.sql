CREATE TABLE assistance_manager (
    id int  NOT NULL,
    name varchar2(50)  NOT NULL,
    last_name varchar2(50)  NOT NULL,
    type_document char(3)  NOT NULL,
    number_document varchar2(50)  NOT NULL,
    email varchar2(60),
    cellphone char(9)  NOT NULL,
    assistance_manager_date DATE,
    state char(1)  DEFAULT('1') CHECK(State IN('1', '0')),
    Ubigeo_id int  NOT NULL,
    Director_id int  NOT NULL,
    CONSTRAINT assistance_manager_pk PRIMARY KEY (id)
) ;


----
CREATE TABLE Ubigeo (
    id integer  NOT NULL,
    Numberubigeo char(3)  NOT NULL,
    Department varchar2(60)  NOT NULL,
    Province varchar2(60)  NOT NULL,
    District varchar2(40)  NOT NULL,
    CONSTRAINT Ubigeo_pk PRIMARY KEY (id)
) ;

----
CREATE TABLE Director (
    id integer  NOT NULL,
    name varchar2(50)  NOT NULL,
    last_name varchar2(50)  NOT NULL,
    type_document char(3)  NOT NULL,
    number_document varchar2(50)  NOT NULL,
    email varchar2(60)  NOT NULL,
    cellphone char(9)  NOT NULL,
    CONSTRAINT Director_pk PRIMARY KEY (id)
) ;

-----
INSERT INTO assistance_manager (id, name, last_name, type_document, number_document, email, cellphone, assistance_manager_date, Ubigeo_id, Director_id)
VALUES ('001', 'Martin', 'Campos','DNI','72506861', 'Marcospalomino@gmail.com', '948372294', TRUNC(SYSDATE), '1','1');

----
INSERT INTO Ubigeo (id, Numberubigeo, Department, Province, District)
VALUES ('1', '57', 'Amazonas','Chachapoyas','la jalca');

----
INSERT INTO Director (id, name, last_name, type_document, number_document, email, cellphone)
VALUES ('1', 'Jose', 'Martin','DNI','23293842', 'Jose@gmail.com', '948372294');


    
--Procedimientos Almacenados:
-- Procedimiento 1
CREATE OR REPLACE PROCEDURE sp_insert_assistance_manager (
   p_name VARCHAR2,
    p_last_name VARCHAR2,
    p_type_document CHAR,
    p_number_document VARCHAR2,
    p_email VARCHAR2,
    p_cellphone CHAR,
    p_assistance_date DATE,
    p_state CHAR,
    p_ubigeo_id INT,
    p_director_id INT
) AS
BEGIN
    -- Código de inserción aquí

    INSERT INTO assistance_manager (
        id,
        name,
        last_name,
        type_document,
        number_document,
        email,
        cellphone,
        assistance_manager_date,
        state,
        Ubigeo_id,
        Director_id
    ) VALUES (
        SEQ_assistance_manager.NEXTVAL,
        p_name,
        p_last_name,
        p_type_document,
        p_number_document,
        p_email,
        p_cellphone,
        p_assistance_date,
        p_state,
        p_ubigeo_id,
        p_director_id
    );
    COMMIT;
END sp_insert_assistance_manager;



-- Procedimiento 2 (ejemplo)
CREATE OR REPLACE PROCEDURE sp_update_assistance_manager_email (
    p_manager_id INT,
    p_new_email VARCHAR2
) AS
BEGIN
    UPDATE ASSISTANCE_MANAGER
    SET EMAIL = p_new_email
    WHERE ID = p_manager_id;
    COMMIT;
END sp_update_assistance_manager_email;








--Funciones de Usuario o Personalizadas:
-- Función 1
CREATE OR REPLACE FUNCTION fn_get_manager_full_name (
    p_manager_id INT
) RETURN VARCHAR2 AS
    v_full_name VARCHAR2(100);
BEGIN
    SELECT NAME || ' ' || LAST_NAME
    INTO v_full_name
    FROM ASSISTANCE_MANAGER
    WHERE ID = p_manager_id;

    RETURN v_full_name;
END fn_get_manager_full_name;










-- Función 2 (ejemplo)
CREATE OR REPLACE FUNCTION fn_check_director_permission (
    p_manager_id INT
) RETURN NUMBER AS
    v_permission NUMBER := 0; -- Inicializado como falso (0)
BEGIN
    SELECT COUNT(*)
    INTO v_permission
    FROM ASSISTANCE_MANAGER
    WHERE DIRECTOR_ID = p_manager_id;

    RETURN v_permission; -- Retorna 1 si hay coincidencia, 0 si no hay coincidencia
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 0; -- En caso de no encontrar datos, devuelve 0 (falso)
END fn_check_director_permission;




Excepciones y Manejo de Errores:
CREATE OR REPLACE PROCEDURE sp_insert_assistance_manager (
    p_name VARCHAR2,
    p_last_name VARCHAR2,
    p_type_document CHAR,
    p_number_document VARCHAR2,
    p_email VARCHAR2,
    p_cellphone CHAR,
    p_assistance_date DATE,
    p_state CHAR,
    p_ubigeo_id INT,
    p_director_id INT
) AS
    v_error_code NUMBER;
    v_error_msg VARCHAR2(200);
BEGIN
    SAVEPOINT start_transaction; -- Guarda un punto de guardado para la transacción

    -- Código de inserción aquí

    COMMIT; -- Confirma los cambios si no hay errores

EXCEPTION
    WHEN OTHERS THEN
        v_error_code := SQLCODE;
        v_error_msg := SQLERRM;
        DBMS_OUTPUT.PUT_LINE('Error (' || v_error_code || '): ' || v_error_msg);
        ROLLBACK TO start_transaction; -- Deshace los cambios hasta el punto de guardado
        RAISE; -- Re-lanza la excepción para ser manejada externamente
END sp_insert_assistance_manager;
/








-- Excepción 2 (ejemplo)
CREATE OR REPLACE PROCEDURE sp_update_assistance_manager_email (
    p_new_email VARCHAR2,
    p_manager_id INT
) AS
    v_custom_exception EXCEPTION;
BEGIN
    IF LENGTH(p_new_email) > 60 THEN
        RAISE v_custom_exception;
    ELSE
        UPDATE ASSISTANCE_MANAGER
        SET EMAIL = p_new_email
        WHERE ID = p_manager_id;
        COMMIT;
    END IF;

EXCEPTION
    WHEN v_custom_exception THEN
        DBMS_OUTPUT.PUT_LINE('Error: El correo electrónico debe tener máximo 60 caracteres.');
        ROLLBACK;
END sp_update_assistance_manager_email;
/



CREATE OR REPLACE PACKAGE manager_pkg AS
    PROCEDURE sp_insert_assistance_manager (
        p_name VARCHAR2,
        p_last_name VARCHAR2
        -- Otros parámetros aquí
    );

    PROCEDURE sp_update_assistance_manager_email (
        p_new_email VARCHAR2,
        p_manager_id INT
    );

    FUNCTION fn_get_manager_full_name (
        p_manager_id INT
    ) RETURN VARCHAR2;

    FUNCTION fn_check_director_permission (
        p_manager_id INT
    ) RETURN BOOLEAN;
END manager_pkg;
/






-- Package 2 (ejemplo)
CREATE OR REPLACE PACKAGE ubigeo_pkg AS
    FUNCTION fn_get_ubigeo_description (
        p_ubigeo_id INT
    ) RETURN VARCHAR2;
END ubigeo_pkg;
/



-- Implementación del Package 1
CREATE OR REPLACE PACKAGE BODY manager_pkg AS
    PROCEDURE sp_insert_assistance_manager (
        p_name VARCHAR2,
        p_last_name VARCHAR2
        -- Otros parámetros aquí
    ) AS
    BEGIN
        -- Código de inserción aquí
        NULL; -- Placeholder para el código de inserción
    END sp_insert_assistance_manager;

    PROCEDURE sp_update_assistance_manager_email (
        p_new_email VARCHAR2,
        p_manager_id INT
    ) AS
    BEGIN
        -- Código de actualización del email aquí
        NULL; -- Placeholder para el código de actualización
    END sp_update_assistance_manager_email;

    FUNCTION fn_get_manager_full_name (
        p_manager_id INT
    ) RETURN VARCHAR2 AS
        v_full_name VARCHAR2(100); -- Declaración de la variable local

    BEGIN
        -- Lógica para obtener el nombre completo aquí
        v_full_name := 'John Doe'; -- Ejemplo de asignación de valor
        RETURN v_full_name;
    END fn_get_manager_full_name;

    FUNCTION fn_check_director_permission (
        p_manager_id INT
    ) RETURN BOOLEAN AS
        v_permission BOOLEAN := FALSE; -- Declaración e inicialización de la variable local

    BEGIN
        -- Lógica para comprobar permisos aquí
        RETURN v_permission;
    END fn_check_director_permission;

END manager_pkg;
/



Triggers:
-- Trigger 1
CREATE OR REPLACE TRIGGER trg_before_insert_manager
BEFORE INSERT ON ASSISTANCE_MANAGER
FOR EACH ROW
BEGIN
    -- lógica antes de la inserción
    :NEW.NAME := UPPER(:NEW.NAME);
    :NEW.LAST_NAME := UPPER(:NEW.LAST_NAME);
END trg_before_insert_manager;
/




-- Trigger 2 (ejemplo)
CREATE OR REPLACE TRIGGER trg_after_update_state
AFTER UPDATE OF STATE ON ASSISTANCE_MANAGER
FOR EACH ROW
BEGIN
    -- lógica después de la actualización del estado
    DBMS_OUTPUT.PUT_LINE('¡Se actualizó el estado del asistente!');
END trg_after_update_state;
/