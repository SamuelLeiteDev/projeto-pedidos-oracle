CREATE OR REPLACE PACKAGE BODY PKG_CLIENTE AS

/*
: 1) chama PKG_CLIENTE.CADASTRAR com nome, documento e e-mail; 2)
o sistema valida os campos; 3) o cliente é criado com status ATIVO
*/
PROCEDURE P_CADASTRAR(pNome IN VARCHAR, pDocumento IN VARCHAR, pEmail IN VARCHAR, pStatus OUT VARCHAR) IS
    CURSOR c_documento IS
        SELECT C.ID
        FROM CLIENTE C
        WHERE C.DOCUMENTO = pDocumento;
    
    r_documento cliente%rowtype;
BEGIN
    pStatus := 'OK';

    OPEN c_documento;
    FETCH c_documento INTO r_documento.documento;
    IF c_documento%NOTFOUND then
        INSERT INTO CLIENTE (nome, documento, email) VALUES (pNome, pDocumento, pEmail);
    ELSE
        pStatus := 'Já possui um cliente com o documento ' || pDocumento || ' cadastrado';
        RETURN;
    END IF;
    CLOSE c_documento;

    
END P_CADASTRAR;

END PKG_CLIENTE;