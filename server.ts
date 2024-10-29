import "dotenv/config";
import { Client } from "pg";
import { backOff } from "exponential-backoff";
import express from "express";
import waitOn from "wait-on";
import onExit from "signal-exit";
import cors from "cors";

// Add your routes here
const setupApp = (client: Client): express.Application => {
  const app: express.Application = express();

  app.use(cors());

  app.use(express.json());

  app.get("/examples", async (_req, res) => {
    const { rows } = await client.query(`SELECT * FROM example_table`);
    res.json(rows);
  });

  app.get("/dimensions/:componentId", async (_req, res) => {
    const { rows } = await client.query(
      `SELECT * FROM dimensions WHERE component_id = $1`,
      [_req.params.componentId]
    );
    res.json(rows);
  });

  app.post("/dimensions/:componentId", async (req, res) => {
    const { componentId } = req.params;
    const { dimensionName, value, metric } = req.body;
    const query = `
			INSERT INTO dimensions (component_id, dimension_name, value, metric)
			VALUES ($1, $2, $3, $4)
			ON CONFLICT (component_id, dimension_name) 
			DO UPDATE SET 
    		value = EXCLUDED.value,
    		metric = EXCLUDED.metric
			RETURNING *
		`;

    const result = await client.query(query, [
      componentId,
      dimensionName,
      value,
      metric,
    ]);
    res.json(result);
  });
  return app;
};

// Waits for the database to start and connects
const connect = async (): Promise<Client> => {
  console.log("Connecting");
  const resource = `tcp:${process.env.PGHOST}:${process.env.PGPORT}`;
  console.log(`Waiting for ${resource}`);
  await waitOn({ resources: [resource] });
  console.log("Initializing client");
  const client = new Client();
  await client.connect();
  console.log("Connected to database");

  // Ensure the client disconnects on exit
  onExit(async () => {
    console.log("onExit: closing client");
    await client.end();
  });

  return client;
};

const main = async () => {
  const client = await connect();
  const app = setupApp(client);
  const port = parseInt(process.env.SERVER_PORT);
  app.listen(port, () => {
    console.log(
      `Draftbit Coding Challenge is running at http://localhost:${port}/`
    );
  });
};

main();
