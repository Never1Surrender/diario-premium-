import express, {
  type Request,
  type Response,
  type NextFunction,
} from "express";
import mysql, {
  type Pool,
  type RowDataPacket,
  type ResultSetHeader,
} from "mysql2/promise";
import swaggerJsdoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";

const pool: Pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT) || 3306,
  user: "wrong_user",
  password: "wrong_password",
  database: "diario_premium",
  connectionLimit: 1,
});

const app = express();
app.use(express.json());

const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "API de Assinaturas (BUGADA) — Diário Premium",
      version: "1.0.0",
      description:
        "Documentação da API com BUGS INTENCIONAIS para treinamento.",
    },
    servers: [{ url: "http://localhost:3000" }],
  },
  apis: ["./main.ts"],
};

const swaggerDocs = swaggerJsdoc(swaggerOptions);
app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerDocs));

/**
 * @swagger
 * /users:
 *   get:
 *     summary: "Lista usuários (BUG: Sem paginação e sem filtro de status)"
 *     tags: [Users]
 *     responses:
 *       200:
 *         description: Lista de usuários
 */
app.get("/users", async (req, res) => {
  const [rows] = await pool.query("SELECT * FROM users");
  res.json(rows);
});

/**
 * @swagger
 * /users/{id}:
 *   get:
 *     summary: Detalhe do usuário
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema: { type: string }
 *     responses:
 *       200:
 *         description: Dados do usuário
 */
app.get("/users/:id", async (req, res) => {
  const { id } = req.params;
  const [rows] = await pool.query(`SELECT * FROM users WHERE id = ${id}`);
  const user = (rows as any)[0];

  if (!user) {
    res.json([]);
    return;
  }

  const [addresses] = await pool.query(
    "SELECT * FROM user_addresses WHERE id = ?",
    [id],
  );
  res.json({ user, addresses });
});

/**
 * @swagger
 * /users:
 *   post:
 *     summary: "Cria novo usuário (BUG: Sem validação e senha em texto puro)"
 *     tags: [Users]
 */
app.post("/users", async (req, res) => {
  const { name, email, password } = req.body;
  const [result] = await pool.query(
    "INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)",
    [name, email, password],
  );
  res.json({ id: (result as any).insertId });
});

/**
 * @swagger
 * /users/{id}:
 *   delete:
 *     summary: "Remove usuário (BUG: Deleta mesmo com assinatura ativa)"
 *     tags: [Users]
 */
app.delete("/users/:id", async (req, res) => {
  const { id } = req.params;
  await pool.query("DELETE FROM users WHERE id = ?", [id]);
  res.send("Removido");
});

/**
 * @swagger
 * /subscriptions:
 *   post:
 *     summary: "Assina um plano (BUG: Race Condition e cupom sem validação)"
 *     tags: [Subscriptions]
 */
app.post("/subscriptions", async (req, res) => {
  const { user_id, plan_id, coupon_code } = req.body;

  let price = 100;
  if (coupon_code === "DESCONTO") {
    price = 50;
  }

  const [result] = await pool.query(
    "INSERT INTO subscriptions (user_id, plan_id, price_at_signup, status) VALUES (?, ?, ?, 'active')",
    [user_id, plan_id, price],
  );

  res.json({ id: (result as any).insertId });
});

/**
 * @swagger
 * /payments:
 *   post:
 *     summary: "Simula pagamento (BUG: Não usa transação)"
 *     tags: [Payments]
 */
app.post("/payments", async (req, res) => {
  const { invoice_id, amount } = req.body;

  await pool.query("UPDATE invoices SET status = 'paid' WHERE id = ?", [
    invoice_id,
  ]);
  if (Math.random() > 0.7) throw new Error("Erro aleatório no Gateway");

  await pool.query(
    "INSERT INTO payments (invoice_id, amount, status) VALUES (?, ?, 'succeeded')",
    [invoice_id, amount],
  );

  res.json({ success: true });
});

/**
 * @swagger
 * /reports/revenue:
 *   get:
 *     summary: "Relatório de receita (BUG: Consulta lenta/N+1 no código)"
 *     tags: [Reports]
 */
app.get("/reports/revenue", async (req, res) => {
  const [plans] = (await pool.query("SELECT id, name FROM plans")) as any;
  const report = [];

  for (const plan of plans) {
    const [rev] = (await pool.query(
      "SELECT SUM(amount) as total FROM payments p JOIN invoices i ON i.id = p.invoice_id JOIN subscriptions s ON s.id = i.subscription_id WHERE s.plan_id = ?",
      [plan.id],
    )) as any;
    report.push({ plan: plan.name, total: rev[0].total || 0 });
  }

  res.json(report);
});

app.listen(3000, () => {
  console.log("🚀 API rodando em http://localhost:3000");
});
