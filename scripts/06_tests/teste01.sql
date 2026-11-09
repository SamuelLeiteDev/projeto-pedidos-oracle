declare

    vStatus VARCHAR2(100);
    vCodNovo NUMBER;

begin
    PKG_CLIENTE.P_CADASTRAR('Samuel Silva', 'G9H6L5RK000166','email@email.com', vStatus, vCodNovo);

    IF vStatus <> 'OK' THEN
        DBMS_OUTPUT.PUT_LINE(vStatus);
    ELSE
        DBMS_OUTPUT.PUT_LINE('Cliente ID: ' || vCodNovo || ' foi criado com sucesso!');
    END IF;

END;
