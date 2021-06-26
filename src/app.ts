import { typeOrmConfig } from './config/database.config';
import * as express from 'express'
import { Application } from 'express'
import { createConnection } from 'typeorm';
import { RegisterRoutes } from "./openapi/routes";
import * as swaggerConfig from './openapi/swagger.json';

import { generateHTML, serve } from "swagger-ui-express";
const cors = require('cors');

class App {
    public app: Application
    public port: number

    constructor(appInit: { port: number; middleWares }) {
        this.app = express();
        this.port = appInit.port;

        this.middlewares(appInit.middleWares);
        this.routes();
        this.template();
        this.documentation()
        this.configureDatabase();
    }

    private middlewares(middleWares: { forEach: (arg0: (middleWare: any) => void) => void; }) {
        middleWares.forEach(middleWare => {
            this.app.use(middleWare)
        })
    }

    private routes() {
        RegisterRoutes(this.app);

    }

    private template() {
        this.app.set('view engine', 'pug')
    }

    private async documentation() {
        this.app.use("/swagger-ui", serve, async (_req: express.Request, res: express.Response) => {
            return res.send(
                generateHTML(swaggerConfig)
            );
        });
        this.app.use("/api-docs", (req, res) => {
            res.send(swaggerConfig);
        })
    }

    private async configureDatabase() {
        const conn = await createConnection(typeOrmConfig);
        console.log('PG connected.');

        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        // App's main content. This could be an Express or Koa web server for example, or even just a Node console app.
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        // Closing the TypeORM db connection at the end of the app prevents the process from hanging at the end (ex when you
        // use ctrl-c to stop the process in your console, or when Docker sends the signal to terminate the process).
        await conn.close();
        console.log('PG connection closed.');
    };

    public listen() {
        //create basic health check
        this.app.get('/health', function (req, res) {
            res.send('OK');
        });

        //handle not found paths
        this.app.use(function notFoundHandler(_req, res) {
            res.status(404).send({
                message: "Not Found",
            });
        });
        //add cors
        this.app.use(cors());
        this.app.listen(this.port, () => {
            console.log(`App listening on the http://localhost:${this.port}`)
        })
    }
}

export default App
