-- SEQUENCES
CREATE SEQUENCE seq_moveestoque START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_pedido      START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_itempedido  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_contareceber  START WITH 1 INCREMENT BY 1 NOCACHE;
CREATE SEQUENCE seq_logauditoria  START WITH 1 INCREMENT BY 1 NOCACHE;

CREATE TABLE pedido (
    id            NUMBER DEFAULT seq_pedido.NEXTVAL NOT NULL,
    cliente_id    NUMBER NOT NULL,
    status        VARCHAR2(15) NOT NULL,
    data_criacao  DATE DEFAULT SYSDATE NOT NULL,
    data_fechamento     DATE,
    valor_bruto         NUMBER(12,2) NOT NULL,
    valor_desconto      NUMBER(12,2) NOT NULL,
    valor_total         NUMBER(12,2) NOT NULL,
    CONSTRAINT pk_pedido         PRIMARY KEY (id),
    CONSTRAINT fk_pedido_cliente FOREIGN KEY (cliente_id) REFERENCES cliente (id),
    CONSTRAINT ck_pedido_fechamento CHECK (
        (status = 'ABERTO'  AND data_fechamento IS NULL) OR
        (status = 'FECHADO' AND data_fechamento IS NOT NULL) OR
        (status = 'CANCELADO')
    ),
    CONSTRAINT ck_pedido_valores  CHECK (valor_bruto >= 0 AND valor_desconto >= 0 AND valor_total >= 0),
    CONSTRAINT ck_pedido_total    CHECK (valor_total = valor_bruto - valor_desconto)
);

CREATE INDEX ix_pedido_cliente ON pedido (cliente_id, data_criacao);

COMMENT ON TABLE  pedido IS 'Pedidos de venda';
COMMENT ON COLUMN pedido.status          IS 'ABERTO, FECHADO ou CANCELADO';
COMMENT ON COLUMN pedido.data_fechamento IS 'Preenchida apenas quando o pedido é fechado';
COMMENT ON COLUMN pedido.valor_bruto     IS 'Soma dos itens, antes do desconto';
COMMENT ON COLUMN pedido.valor_desconto  IS 'Desconto calculado no fechamento';
COMMENT ON COLUMN pedido.valor_total     IS 'Valor bruto menos desconto';

-- MOVE ESTOQUE -> Movimentações do estoque
CREATE TABLE move_estoque (
    id            NUMBER        DEFAULT seq_moveestoque.NEXTVAL NOT NULL,
    produto_id    NUMBER        NOT NULL,
    tipo          VARCHAR2(10)  NOT NULL,
    quantidade    NUMBER        NOT NULL,
    motivo        VARCHAR2(15)  NOT NULL,
    pedido_id     NUMBER,
    data_mov      DATE          DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_movestoque         PRIMARY KEY (id),
    CONSTRAINT fk_movestoque_produto FOREIGN KEY (produto_id) REFERENCES produto (id),
    CONSTRAINT ck_movestoque_tipo    CHECK (tipo IN ('ENTRADA', 'SAIDA')),
    CONSTRAINT ck_movestoque_qtd     CHECK (quantidade > 0),
    CONSTRAINT ck_movestoque_motivo  CHECK (motivo IN ('REPOSICAO', 'VENDA', 'ESTORNO')),   
    CONSTRAINT ck_movestoque         CHECK (
        (motivo = 'VENDA' AND tipo = 'SAIDA') OR
        (motivo IN ('REPOSICAO', 'ESTORNO') AND tipo = 'ENTRADA')
    ),
    CONSTRAINT fk_movestoque_pedido  FOREIGN KEY (pedido_id) REFERENCES pedido (id)    
);

CREATE INDEX ix_movestoque_produto ON move_estoque (produto_id);
CREATE INDEX ix_movestoque_pedido  ON move_estoque (pedido_id);

COMMENT ON TABLE  move_estoque IS 'Movimentações de entrada e saída de estoque';
COMMENT ON COLUMN move_estoque.tipo      IS 'ENTRADA soma ao saldo, SAIDA subtrai';
COMMENT ON COLUMN move_estoque.motivo    IS 'REPOSICAO, VENDA ou ESTORNO';
COMMENT ON COLUMN move_estoque.pedido_id IS 'Pedido que originou a movimentação, quando houver';

-- ITEN PEDIDO -> Itens do Pedido
CREATE TABLE ITEM_PEDIDO (
    id            NUMBER        DEFAULT seq_itempedido.NEXTVAL NOT NULL,
    pedido_id     NUMBER        NOT NULL,
    produto_id    NUMBER        NOT NULL,
    quantidade    NUMBER(12, 2)     NOT NULL,
    preco_unitario NUMBER(12,2)     NOT NULL,
    valor_item     NUMBER(12,2)     NOT NULL,
    CONSTRAINT pk_itempedido        PRIMARY KEY (id),
    CONSTRAINT fk_itempedido_pedido  FOREIGN KEY (pedido_id) REFERENCES pedido (id),
    CONSTRAINT fk_itempedido_produto FOREIGN KEY (produto_id) REFERENCES produto (id),
    CONSTRAINT ck_itempedido_qtd     CHECK (quantidade > 0),
    CONSTRAINT ck_valor              CHECK (preco_unitario > 0 AND valor_item > 0)
);

CREATE INDEX ix_itempedido_produto ON item_pedido (produto_id);
CREATE INDEX ix_itempedido_pedido  ON item_pedido (pedido_id);

COMMENT ON TABLE  item_pedido IS 'Itens detalhado do pedido (tabela filho da tabela pedido)';
COMMENT ON COLUMN item_pedido.valor_item      IS 'Valor Item = preco_unitario * quantidade';

CREATE TABLE CONTA_RECEBER (
    id              NUMBER DEFAULT seq_contareceber.NEXTVAL NOT NULL,
    pedido_id       NUMBER NOT NULL,
    parcela         NUMBER NOT NULL,
    vencimento      DATE NOT NULL,
    valor           NUMBER(12,2) NOT NULL,
    status          VARCHAR2(15) NOT NULL,
    data_pagamento  DATE,
    valor_pago      NUMBER(12, 2),
    CONSTRAINT pk_contareceber        PRIMARY KEY (id),
    CONSTRAINT fk_contareceber_pedido  FOREIGN KEY (pedido_id) REFERENCES pedido (id),
    CONSTRAINT ck_valor_contareceb     CHECK (valor > 0),
    CONSTRAINT ck_status_contareceb    CHECK (status IN ('ABERTA', 'PAGA', 'ATRASADA', 'CANCELADA'))
);

CREATE INDEX ix_contareceb_pedido  ON conta_receber (pedido_id);

CREATE TABLE LOG_AUDITORIA (
    id                  NUMBER DEFAULT seq_logauditoria.NEXTVAL NOT NULL,
    operacao            VARCHAR2(1) NOT NULL,
    chave_registro      VARCHAR2(100) NOT NULL,
    valor_anterior      VARCHAR2(1000) NOT NULL,
    valor_posterior     VARCHAR2(1000) NOT NULL,
    audit_user          VARCHAR2(20) NOT NULL,
    audit_date          DATE NOT NULL,
    CONSTRAINT pk_logauditoria PRIMARY KEY (id),
    CONSTRAINT ck_operacao_audit     CHECK (operacao IN ('I', 'U', 'D'))
);

