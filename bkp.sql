-- ============================================================
--  Sistema de Assinaturas Online — Schema + Seed para MariaDB
-- ============================================================

SET NAMES utf8mb4;
SET foreign_key_checks = 0;

CREATE DATABASE IF NOT EXISTS diario_premium;
USE diario_premium;

-- ------------------------------------------------------------
-- 1. IDENTIDADE
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS users (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(120)        NOT NULL,
    email           VARCHAR(180)        NOT NULL UNIQUE,
    phone           VARCHAR(20),
    cpf             VARCHAR(14)         UNIQUE,
    password_hash   VARCHAR(255)        NOT NULL,
    status          ENUM('active','inactive','blocked') NOT NULL DEFAULT 'active',
    email_verified_at DATETIME,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_addresses (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED        NOT NULL,
    label       VARCHAR(40)         NOT NULL DEFAULT 'Principal',
    street      VARCHAR(150)        NOT NULL,
    number      VARCHAR(20)         NOT NULL,
    complement  VARCHAR(60),
    district    VARCHAR(80)         NOT NULL,
    city        VARCHAR(80)         NOT NULL,
    state       CHAR(2)             NOT NULL,
    zip_code    VARCHAR(9)          NOT NULL,
    is_default  TINYINT(1)          NOT NULL DEFAULT 0,
    created_at  DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS user_sessions (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id     INT UNSIGNED        NOT NULL,
    token       VARCHAR(255)        NOT NULL UNIQUE,
    ip_address  VARCHAR(45),
    user_agent  VARCHAR(255),
    last_activity DATETIME          NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at  DATETIME            NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 2. CATÁLOGO DE PLANOS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS features (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100)        NOT NULL,
    slug        VARCHAR(100)        NOT NULL UNIQUE,
    description TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS plans (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(80)         NOT NULL,
    slug            VARCHAR(80)         NOT NULL UNIQUE,
    description     TEXT,
    price_monthly   DECIMAL(10,2)       NOT NULL,
    price_yearly    DECIMAL(10,2)       NOT NULL,
    trial_days      TINYINT UNSIGNED    NOT NULL DEFAULT 0,
    status          ENUM('active','inactive','archived') NOT NULL DEFAULT 'active',
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS plan_features (
    plan_id     INT UNSIGNED        NOT NULL,
    feature_id  INT UNSIGNED        NOT NULL,
    value       VARCHAR(100)        NOT NULL DEFAULT 'true',
    PRIMARY KEY (plan_id, feature_id),
    FOREIGN KEY (plan_id)    REFERENCES plans(id)    ON DELETE CASCADE,
    FOREIGN KEY (feature_id) REFERENCES features(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS coupons (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    code            VARCHAR(30)         NOT NULL UNIQUE,
    description     VARCHAR(120),
    discount_type   ENUM('percent','fixed') NOT NULL,
    discount_value  DECIMAL(10,2)       NOT NULL,
    applies_to      ENUM('monthly','yearly','both') NOT NULL DEFAULT 'both',
    max_uses        INT UNSIGNED,
    current_uses    INT UNSIGNED        NOT NULL DEFAULT 0,
    expires_at      DATE,
    is_active       TINYINT(1)          NOT NULL DEFAULT 1,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 3. ASSINATURAS
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS subscriptions (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED        NOT NULL,
    plan_id         INT UNSIGNED        NOT NULL,
    coupon_id       INT UNSIGNED,
    status          ENUM('trialing','active','past_due','cancelled','expired') NOT NULL DEFAULT 'trialing',
    billing_cycle   ENUM('monthly','yearly') NOT NULL DEFAULT 'monthly',
    price_at_signup DECIMAL(10,2)       NOT NULL,
    starts_at       DATE                NOT NULL,
    trial_ends_at   DATE,
    current_period_start DATE           NOT NULL,
    current_period_end   DATE           NOT NULL,
    ends_at         DATE,
    cancelled_at    DATETIME,
    cancellation_reason VARCHAR(255),
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id)   REFERENCES users(id)    ON DELETE RESTRICT,
    FOREIGN KEY (plan_id)   REFERENCES plans(id)    ON DELETE RESTRICT,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id)  ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS subscription_history (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT UNSIGNED        NOT NULL,
    event           VARCHAR(60)         NOT NULL,
    from_plan_id    INT UNSIGNED,
    to_plan_id      INT UNSIGNED,
    from_status     VARCHAR(30),
    to_status       VARCHAR(30),
    notes           TEXT,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ------------------------------------------------------------
-- 4. FINANCEIRO
-- ------------------------------------------------------------

CREATE TABLE IF NOT EXISTS payment_methods (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id         INT UNSIGNED        NOT NULL,
    type            ENUM('credit_card','debit_card','pix','boleto') NOT NULL,
    provider        VARCHAR(50),
    holder_name     VARCHAR(120),
    last_digits     CHAR(4),
    brand           VARCHAR(20),
    expires_at      DATE,
    gateway_token   VARCHAR(255),
    is_default      TINYINT(1)          NOT NULL DEFAULT 0,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS invoices (
    id              INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    subscription_id INT UNSIGNED        NOT NULL,
    invoice_number  VARCHAR(30)         NOT NULL UNIQUE,
    amount          DECIMAL(10,2)       NOT NULL,
    discount_amount DECIMAL(10,2)       NOT NULL DEFAULT 0.00,
    tax_amount      DECIMAL(10,2)       NOT NULL DEFAULT 0.00,
    status          ENUM('draft','open','paid','overdue','void','uncollectible') NOT NULL DEFAULT 'open',
    due_date        DATE                NOT NULL,
    paid_at         DATETIME,
    period_start    DATE                NOT NULL,
    period_end      DATE                NOT NULL,
    notes           TEXT,
    created_at      DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS payments (
    id                  INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    invoice_id          INT UNSIGNED        NOT NULL,
    payment_method_id   INT UNSIGNED,
    amount              DECIMAL(10,2)       NOT NULL,
    status              ENUM('pending','processing','succeeded','failed','refunded') NOT NULL DEFAULT 'pending',
    method              ENUM('credit_card','debit_card','pix','boleto') NOT NULL,
    gateway             VARCHAR(40),
    gateway_id          VARCHAR(120),
    gateway_response    JSON,
    paid_at             DATETIME,
    created_at          DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at          DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invoice_id)        REFERENCES invoices(id)         ON DELETE RESTRICT,
    FOREIGN KEY (payment_method_id) REFERENCES payment_methods(id)  ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS refunds (
    id          INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_id  INT UNSIGNED        NOT NULL,
    amount      DECIMAL(10,2)       NOT NULL,
    reason      ENUM('duplicate','fraudulent','requested_by_customer','other') NOT NULL,
    notes       TEXT,
    status      ENUM('pending','succeeded','failed') NOT NULL DEFAULT 'pending',
    gateway_id  VARCHAR(120),
    created_at  DATETIME            NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (payment_id) REFERENCES payments(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

SET foreign_key_checks = 1;

-- ============================================================
--  DADOS DE SEED
-- ============================================================

-- Features disponíveis
INSERT INTO features (name, slug, description) VALUES
('Acesso a todo o conteúdo', 'full-content',     'Leitura ilimitada de matérias e reportagens'),
('Sem anúncios',             'no-ads',            'Navegação sem publicidade'),
('Newsletter exclusiva',     'newsletter',         'Boletim semanal com curadoria editorial'),
('Download de PDF',          'pdf-download',       'Exportar matérias em PDF'),
('Acesso ao aplicativo',     'app-access',         'Apps iOS e Android incluídos'),
('Conteúdo em áudio',        'audio-content',      'Matérias narradas em podcast interno'),
('Arquivo histórico',        'archive-access',     'Acesso ao acervo desde 1990'),
('Suporte prioritário',      'priority-support',   'Atendimento via chat e e-mail prioritário');

-- Planos
INSERT INTO plans (name, slug, description, price_monthly, price_yearly, trial_days, status) VALUES
('Básico',    'basico',    'Acesso essencial ao conteúdo digital.',         19.90,  199.00, 7,  'active'),
('Premium',   'premium',   'Experiência completa sem anúncios.',            39.90,  399.00, 14, 'active'),
('Ilimitado', 'ilimitado', 'Tudo que o Premium oferece mais arquivo e áudio.', 69.90, 699.00, 14, 'active');

-- Relacionamento plano × feature
INSERT INTO plan_features (plan_id, feature_id, value) VALUES
(1,1,'true'), (1,5,'true'),                             -- Básico
(2,1,'true'), (2,2,'true'), (2,3,'true'),
(2,4,'true'), (2,5,'true'),                             -- Premium
(3,1,'true'), (3,2,'true'), (3,3,'true'),
(3,4,'true'), (3,5,'true'), (3,6,'true'),
(3,7,'true'), (3,8,'true');                             -- Ilimitado

-- Cupons
INSERT INTO coupons (code, description, discount_type, discount_value, applies_to, max_uses, expires_at) VALUES
('BEMVINDO10', 'Desconto de boas-vindas',    'percent', 10.00, 'monthly',  500, '2025-12-31'),
('ANUAL20',    '20% no plano anual',          'percent', 20.00, 'yearly',   200, '2025-12-31'),
('PROMO50',    'R$50 de desconto fixo',        'fixed',   50.00, 'yearly',    50, '2025-06-30'),
('BLACK30',    'Black Friday 30%',             'percent', 30.00, 'both',     1000, '2025-11-30'),
('FIDELIDADE', 'Desconto para renovação',      'percent', 15.00, 'both',      NULL, NULL);

-- Usuários
INSERT INTO users (name, email, phone, cpf, password_hash, status, email_verified_at) VALUES
('Ana Beatriz Costa',      'ana.beatriz@email.com',    '(17) 99101-2345', '123.456.789-00', '$2b$12$hash1', 'active',   '2024-01-10 09:00:00'),
('Carlos Eduardo Mendes',  'carlos.mendes@email.com',  '(17) 98201-3456', '234.567.890-11', '$2b$12$hash2', 'active',   '2024-02-14 10:30:00'),
('Fernanda Lima',          'fernanda.lima@email.com',  '(11) 97301-4567', '345.678.901-22', '$2b$12$hash3', 'active',   '2024-03-05 14:00:00'),
('Rafael Oliveira',        'rafael.oliveira@email.com','(11) 96401-5678', '456.789.012-33', '$2b$12$hash4', 'active',   '2024-04-20 08:45:00'),
('Juliana Santos',         'juliana.santos@email.com', '(21) 95501-6789', '567.890.123-44', '$2b$12$hash5', 'inactive', NULL),
('Marcos Vinícius Souza',  'marcos.souza@email.com',   '(21) 94601-7890', '678.901.234-55', '$2b$12$hash6', 'active',   '2024-05-15 11:00:00'),
('Patrícia Alves',         'patricia.alves@email.com', '(31) 93701-8901', '789.012.345-66', '$2b$12$hash7', 'active',   '2024-06-01 16:20:00'),
('Lucas Ferreira',         'lucas.ferreira@email.com', '(31) 92801-9012', '890.123.456-77', '$2b$12$hash8', 'blocked',  '2024-07-10 09:50:00'),
('Isabela Rocha',          'isabela.rocha@email.com',  '(41) 91901-0123', '901.234.567-88', '$2b$12$hash9', 'active',   '2024-08-25 13:30:00'),
('Thiago Nascimento',      'thiago.nascimento@email.com','(41)90001-1234','012.345.678-99', '$2b$12$hasha', 'active',   '2024-09-30 07:15:00');

-- Endereços
INSERT INTO user_addresses (user_id, label, street, number, district, city, state, zip_code, is_default) VALUES
(1, 'Casa',      'Rua das Acácias',        '123', 'Jardim Paulista',    'São José do Rio Preto', 'SP', '15020-000', 1),
(2, 'Casa',      'Av. Bady Bassitt',       '456', 'Centro',             'São José do Rio Preto', 'SP', '15010-100', 1),
(3, 'Trabalho',  'Rua da Consolação',      '789', 'Consolação',         'São Paulo',             'SP', '01301-000', 1),
(4, 'Casa',      'Rua Augusta',            '321', 'Cerqueira César',    'São Paulo',             'SP', '01305-000', 1),
(5, 'Casa',      'Av. Atlântica',          '654', 'Copacabana',         'Rio de Janeiro',        'RJ', '22010-000', 1),
(6, 'Casa',      'Rua Voluntários da Pátria','987','Botafogo',          'Rio de Janeiro',        'RJ', '22270-000', 1),
(7, 'Casa',      'Av. do Contorno',        '159', 'Savassi',            'Belo Horizonte',        'MG', '30110-000', 1),
(8, 'Casa',      'Rua da Bahia',           '753', 'Centro',             'Belo Horizonte',        'MG', '30160-000', 1),
(9, 'Casa',      'Rua XV de Novembro',     '246', 'Centro',             'Curitiba',              'PR', '80020-000', 1),
(10,'Casa',      'Av. Sete de Setembro',   '864', 'Batel',              'Curitiba',              'PR', '80230-000', 1);

-- Métodos de pagamento
INSERT INTO payment_methods (user_id, type, provider, holder_name, last_digits, brand, expires_at, is_default) VALUES
(1,  'credit_card', 'stripe',     'Ana Beatriz Costa',      '4321', 'Visa',       '2027-08-01', 1),
(2,  'credit_card', 'stripe',     'Carlos Eduardo Mendes',  '8765', 'Mastercard', '2026-05-01', 1),
(3,  'pix',         NULL,          NULL,                      NULL,   NULL,         NULL,         1),
(4,  'credit_card', 'pagarme',    'Rafael Oliveira',         '2109', 'Elo',        '2025-11-01', 1),
(5,  'boleto',      NULL,          NULL,                      NULL,   NULL,         NULL,         1),
(6,  'credit_card', 'stripe',     'Marcos V. Souza',         '5544', 'Visa',       '2028-02-01', 1),
(7,  'credit_card', 'pagarme',    'Patrícia Alves',          '3322', 'Mastercard', '2026-09-01', 1),
(8,  'pix',         NULL,          NULL,                      NULL,   NULL,         NULL,         1),
(9,  'credit_card', 'stripe',     'Isabela Rocha',           '7788', 'Visa',       '2027-03-01', 1),
(10, 'credit_card', 'pagarme',    'Thiago Nascimento',       '9900', 'Amex',       '2026-12-01', 1);

-- Assinaturas
INSERT INTO subscriptions (user_id, plan_id, coupon_id, status, billing_cycle, price_at_signup, starts_at, trial_ends_at, current_period_start, current_period_end) VALUES
(1,  2, 1, 'active',    'monthly', 35.91, '2024-01-10', '2024-01-17', '2025-01-10', '2025-02-10'),  -- Premium c/ cupom
(2,  3, NULL,'active',  'yearly',  699.00,'2024-02-14', '2024-02-28', '2024-02-14', '2025-02-14'),  -- Ilimitado anual
(3,  1, NULL,'active',  'monthly', 19.90, '2024-03-05', '2024-03-12', '2025-03-05', '2025-04-05'),  -- Básico
(4,  2, 2, 'active',    'yearly',  319.20,'2024-04-20', '2024-05-04', '2024-04-20', '2025-04-20'),  -- Premium anual c/ cupom
(5,  1, NULL,'cancelled',         'monthly',19.90,'2024-05-01','2024-05-08','2024-10-01','2024-11-01'),
(6,  3, 3, 'active',    'yearly',  649.00,'2024-05-15', '2024-05-29', '2024-05-15', '2025-05-15'),  -- Ilimitado c/ cupom fixo
(7,  2, NULL,'active',  'monthly', 39.90, '2024-06-01', '2024-06-15', '2025-06-01', '2025-07-01'),  -- Premium mensal
(8,  1, NULL,'expired', 'monthly', 19.90, '2024-01-01', NULL,          '2024-06-01', '2024-07-01'),  -- Básico expirado
(9,  3, 4, 'active',    'monthly', 48.93, '2024-08-25', '2024-09-08', '2025-02-25', '2025-03-25'),  -- Ilimitado c/ cupom
(10, 2, NULL,'trialing','monthly', 39.90, '2025-01-15', '2025-01-29', '2025-01-15', '2025-02-15'); -- Premium em trial

-- Atualizar assinatura cancelada
UPDATE subscriptions SET cancelled_at = '2024-10-15 14:30:00', cancellation_reason = 'Usuário solicitou cancelamento', ends_at = '2024-11-01' WHERE id = 5;
UPDATE subscriptions SET ends_at = '2024-07-01' WHERE id = 8;

-- Histórico de assinaturas
INSERT INTO subscription_history (subscription_id, event, from_status, to_status, notes) VALUES
(1, 'created',   NULL,       'trialing', 'Assinatura criada com cupom BEMVINDO10'),
(1, 'activated', 'trialing', 'active',   'Trial encerrado, primeiro pagamento confirmado'),
(2, 'created',   NULL,       'trialing', 'Assinatura anual criada'),
(2, 'activated', 'trialing', 'active',   'Trial encerrado'),
(5, 'created',   NULL,       'trialing', 'Assinatura criada'),
(5, 'activated', 'trialing', 'active',   'Trial encerrado'),
(5, 'cancelled', 'active',   'cancelled','Cancelamento solicitado pelo usuário via painel'),
(8, 'created',   NULL,       'active',   'Assinatura criada'),
(8, 'expired',   'active',   'expired',  'Fatura vencida sem pagamento'),
(10,'created',   NULL,       'trialing', 'Assinatura criada em período de trial');

-- Faturas
INSERT INTO invoices (subscription_id, invoice_number, amount, discount_amount, status, due_date, paid_at, period_start, period_end) VALUES
-- Ana (sub 1) - mensal
(1, 'INV-2024-0001', 35.91, 3.99, 'paid',    '2024-02-10', '2024-02-08 10:12:00', '2024-02-10', '2024-03-10'),
(1, 'INV-2024-0002', 39.90,  0,   'paid',    '2024-03-10', '2024-03-09 09:30:00', '2024-03-10', '2024-04-10'),
(1, 'INV-2024-0003', 39.90,  0,   'paid',    '2024-04-10', '2024-04-10 08:00:00', '2024-04-10', '2024-05-10'),
(1, 'INV-2025-0001', 39.90,  0,   'paid',    '2025-01-10', '2025-01-09 11:00:00', '2025-01-10', '2025-02-10'),
-- Carlos (sub 2) - anual
(2, 'INV-2024-0010', 699.00, 0,   'paid',    '2024-03-14', '2024-03-12 14:00:00', '2024-02-14', '2025-02-14'),
-- Fernanda (sub 3) - mensal
(3, 'INV-2024-0020', 19.90,  0,   'paid',    '2024-04-05', '2024-04-04 10:00:00', '2024-04-05', '2024-05-05'),
(3, 'INV-2024-0021', 19.90,  0,   'paid',    '2024-05-05', '2024-05-05 09:15:00', '2024-05-05', '2024-06-05'),
(3, 'INV-2025-0010', 19.90,  0,   'open',    '2025-03-05', NULL,                  '2025-03-05', '2025-04-05'),
-- Rafael (sub 4) - anual
(4, 'INV-2024-0030', 319.20, 79.80,'paid',   '2024-05-20', '2024-05-18 16:30:00', '2024-04-20', '2025-04-20'),
-- Juliana (sub 5) - cancelada
(5, 'INV-2024-0040', 19.90,  0,   'paid',    '2024-06-01', '2024-06-01 08:00:00', '2024-06-01', '2024-07-01'),
(5, 'INV-2024-0041', 19.90,  0,   'paid',    '2024-07-01', '2024-07-01 08:00:00', '2024-07-01', '2024-08-01'),
(5, 'INV-2024-0042', 19.90,  0,   'void',    '2024-11-01', NULL,                  '2024-10-01', '2024-11-01'),
-- Marcos (sub 6) - anual
(6, 'INV-2024-0050', 649.00, 50.00,'paid',   '2024-06-15', '2024-06-14 10:00:00', '2024-05-15', '2025-05-15'),
-- Patrícia (sub 7) - mensal
(7, 'INV-2024-0060', 39.90,  0,   'paid',    '2024-07-01', '2024-07-01 07:00:00', '2024-07-01', '2024-08-01'),
(7, 'INV-2024-0061', 39.90,  0,   'overdue', '2025-01-01', NULL,                  '2025-01-01', '2025-02-01'),
-- Lucas (sub 8) - expirada
(8, 'INV-2024-0070', 19.90,  0,   'paid',    '2024-02-01', '2024-01-31 12:00:00', '2024-02-01', '2024-03-01'),
(8, 'INV-2024-0071', 19.90,  0,   'uncollectible','2024-07-01',NULL,              '2024-07-01', '2024-08-01'),
-- Isabela (sub 9) - mensal
(9, 'INV-2024-0080', 48.93,  20.97,'paid',   '2024-10-08', '2024-10-07 09:00:00', '2024-10-08', '2024-11-08'),
(9, 'INV-2025-0020', 69.90,  0,   'paid',    '2025-02-25', '2025-02-24 11:00:00', '2025-02-25', '2025-03-25');

-- Pagamentos
INSERT INTO payments (invoice_id, payment_method_id, amount, status, method, gateway, gateway_id, paid_at) VALUES
(1,  1,  35.91, 'succeeded',  'credit_card', 'stripe',  'ch_stripe_001', '2024-02-08 10:12:00'),
(2,  1,  39.90, 'succeeded',  'credit_card', 'stripe',  'ch_stripe_002', '2024-03-09 09:30:00'),
(3,  1,  39.90, 'succeeded',  'credit_card', 'stripe',  'ch_stripe_003', '2024-04-10 08:00:00'),
(4,  1,  39.90, 'succeeded',  'credit_card', 'stripe',  'ch_stripe_004', '2025-01-09 11:00:00'),
(5,  2,  699.00,'succeeded',  'credit_card', 'stripe',  'ch_stripe_005', '2024-03-12 14:00:00'),
(6,  3,  19.90, 'succeeded',  'pix',         'gerencianet','pix_001',    '2024-04-04 10:00:00'),
(7,  3,  19.90, 'succeeded',  'pix',         'gerencianet','pix_002',    '2024-05-05 09:15:00'),
(9,  4,  319.20,'succeeded',  'credit_card', 'pagarme', 'pg_001',        '2024-05-18 16:30:00'),
(10, 5,  19.90, 'succeeded',  'boleto',      'pagarme', 'bol_001',       '2024-06-01 08:00:00'),
(11, 5,  19.90, 'succeeded',  'boleto',      'pagarme', 'bol_002',       '2024-07-01 08:00:00'),
(13, 6,  649.00,'succeeded',  'credit_card', 'stripe',  'ch_stripe_006', '2024-06-14 10:00:00'),
(14, 7,  39.90, 'succeeded',  'credit_card', 'pagarme', 'pg_002',        '2024-07-01 07:00:00'),
(16, 8,  19.90, 'succeeded',  'pix',         'gerencianet','pix_003',    '2024-01-31 12:00:00'),
(18, 9,  48.93, 'succeeded',  'credit_card', 'stripe',  'ch_stripe_007', '2024-10-07 09:00:00'),
(19, 9,  69.90, 'succeeded',  'credit_card', 'stripe',  'ch_stripe_008', '2025-02-24 11:00:00');

-- Reembolso (exemplo)
INSERT INTO refunds (payment_id, amount, reason, notes, status, gateway_id) VALUES
(2, 39.90, 'requested_by_customer', 'Cliente solicitou reembolso da fatura de março alegando cobrança indevida. Estornado após análise.', 'succeeded', 'refund_stripe_001');
