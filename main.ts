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
import cors from "cors";
import "dotenv/config";

const pool: Pool = mysql.createPool({
  host: process.env.DB_HOST || "localhost",
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || "root",
  password: process.env.DB_PASSWORD || "root",
  database: process.env.DB_NAME || "diario_premium",
  connectionLimit: 1,
});

const app = express();
app.use(cors());
app.use(express.json());

const swaggerOptions = {
  definition: {
    openapi: "3.0.0",
    info: {
      title: "API de Assinaturas",
      version: "1.0.0",
      description: "Documentação da API de Assinaturas.",
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
 *     summary: "Lista usuários"
 *     tags: [Users]
 *     parameters:
 *       - in: query
 *         name: name
 *         schema:
 *           type: string
 *         description: Filtra usuários pelo nome
 *     responses:
 *       200:
 *         description: Lista de usuários
 */
app.get("/users", async (req, res) => {
  const { name } = req.query;
  try {
    let query = "SELECT id, name, email, status, created_at FROM users";
    const params: any[] = [];

    if (name) {
      query += " WHERE name LIKE ?";
      params.push(`%${name}%`);
    }

    const [rows] = await pool.query(query, params);
    res.json(rows);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erro ao buscar usuários" });
  }
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
  try {
    const [rows] = await pool.query("SELECT * FROM users WHERE id = ?", [id]);
    const user = (rows as any)[0];

    if (!user) {
      res.status(404).json({ message: "Usuário não encontrado" });
      return;
    }

    const [addresses] = await pool.query(
      "SELECT * FROM user_addresses WHERE user_id = ?",
      [id],
    );
    res.json({ user, addresses });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erro ao buscar usuário" });
  }
});

/**
 * @swagger
 * /plans:
 *   get:
 *     summary: "Lista planos disponíveis"
 *     tags: [Plans]
 *     responses:
 *       200:
 *         description: Lista de planos
 */
app.get("/plans", async (req, res) => {
  const [rows] = await pool.query(
    "SELECT * FROM plans WHERE status = 'active'",
  );
  res.json(rows);
});

/**
 * @swagger
 * /users:
 *   post:
 *     summary: "Cria novo usuário"
 *     tags: [Users]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               cpf:
 *                 type: string
 *               phone:
 *                 type: string
 *           example:
 *             name: "João Silva"
 *             email: "joao@example.com"
 *             password: "senha_segura"
 *             cpf: "123.456.789-00"
 *             phone: "(11) 99999-9999"
 *     responses:
 *       200:
 *         description: Usuário criado com sucesso
 *         content:
 *           application/json:
 *             example:
 *               id: 1
 */
app.post("/users", async (req, res) => {
  const { name, email, password, cpf, phone } = req.body;

  if (!name || !email || !password) {
    res
      .status(400)
      .json({ error: "Dados obrigatórios ausentes (name, email, password)" });
    return;
  }

  try {
    const [result] = await pool.query(
      "INSERT INTO users (name, email, password_hash, cpf, phone) VALUES (?, ?, ?, ?, ?)",
      [name, email, password, cpf || null, phone || null],
    );
    res.status(201).json({
      message: "Usuário cadastrado com sucesso",
      id: (result as any).insertId,
    });
  } catch (error: any) {
    console.error(error);
    if (error.code === "ER_DUP_ENTRY") {
      res.status(409).json({ error: "Email ou CPF já cadastrado" });
    } else {
      res.status(500).json({ error: "Erro ao cadastrar usuário" });
    }
  }
});

/**
 * @swagger
 * /users/{id}:
 *   delete:
 *     summary: "Remove usuário"
 *     tags: [Users]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *         description: ID do usuário a ser removido
 *     responses:
 *       200:
 *         description: Usuário removido
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
 *     summary: "Assina um plano"
 *     tags: [Subscriptions]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - user_id
 *               - plan_id
 *             properties:
 *               user_id:
 *                 type: integer
 *               plan_id:
 *                 type: integer
 *               coupon_code:
 *                 type: string
 *           example:
 *             user_id: 1
 *             plan_id: 2
 *             coupon_code: "DESCONTO"
 *     responses:
 *       200:
 *         description: Assinatura criada
 *         content:
 *           application/json:
 *             example:
 *               id: 123
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
 *     summary: "Simula pagamento"
 *     tags: [Payments]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - invoice_id
 *               - amount
 *             properties:
 *               invoice_id:
 *                 type: integer
 *               amount:
 *                 type: number
 *           example:
 *             invoice_id: 45
 *             amount: 50.00
 *     responses:
 *       200:
 *         description: Pagamento processado
 *         content:
 *           application/json:
 *             example:
 *               success: true
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
 *     summary: "Relatório de receita"
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
