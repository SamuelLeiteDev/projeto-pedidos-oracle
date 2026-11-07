-- Sequences (geram os ids automaticamente)
CREATE SEQUENCE seq_cliente START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_produto START WITH 1 INCREMENT BY 1 NOCACHE;

-- CLIENTE
CREATE TABLE cliente (
    id            NUMBER        DEFAULT seq_cliente.NEXTVAL NOT NULL,
    nome          VARCHAR2(100) NOT NULL,
    documento     VARCHAR2(20)  NOT NULL,
    email         VARCHAR2(120),
    status        VARCHAR2(12)  DEFAULT 'ATIVO' NOT NULL,
    data_cadastro DATE          DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_cliente           PRIMARY KEY (id),
    CONSTRAINT uk_cliente_documento UNIQUE (documento),
    CONSTRAINT ck_cliente_status    CHECK (status IN ('ATIVO', 'INATIVO', 'INADIMPLENTE'))
);

-- PRODUTO
CREATE TABLE produto (
    id          NUMBER        DEFAULT seq_produto.NEXTVAL NOT NULL,
    codigo      VARCHAR2(30)  NOT NULL,
    descricao   VARCHAR2(150) NOT NULL,
    preco_venda NUMBER(12,2)  NOT NULL,
    ativo       CHAR(1)       DEFAULT 'S' NOT NULL,
    CONSTRAINT pk_produto        PRIMARY KEY (id),
    CONSTRAINT uk_produto_codigo UNIQUE (codigo),
    CONSTRAINT ck_produto_ativo  CHECK (ativo IN ('S', 'N')),
    CONSTRAINT ck_produto_preco  CHECK (preco_venda > 0)
);

-- ESTOQUE (uma linha por produto)
CREATE TABLE estoque (
    produto_id        NUMBER      NOT NULL,
    saldo             NUMBER(10)  DEFAULT 0 NOT NULL,
    data_atualizacao  DATE        DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_estoque         PRIMARY KEY (produto_id),
    CONSTRAINT fk_estoque_produto FOREIGN KEY (produto_id) REFERENCES produto (id),
    CONSTRAINT ck_estoque_saldo   CHECK (saldo >= 0)
);