import { typeOrmConfig } from './config/database.config';
import * as express from 'express'
import { Application } from 'express'
import { createConnection } from 'typeorm';
const cors = require('cors');

class App {
    public app: Application
    public port: number

    constructor(appInit: { port: number; middleWares: any; controllers: any; }) {
        this.app = express();
        this.port = appInit.port;
        
        this.middlewares(appInit.middleWares);
        this.routes(appInit.controllers);
        this.template();
        this.configureDatabase();
    }

    private middlewares(middleWares: { forEach: (arg0: (middleWare: any) => void) => void; }) {
        middleWares.forEach(middleWare => {
            this.app.use(middleWare)
        })
    }

    private routes(controllers: { forEach: (arg0: (controller: any) => void) => void; }) {
        controllers.forEach(controller => {
            this.app.use('/', controller.router)
        })
    }

    private template() {
        this.app.set('view engine', 'pug')
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

        //add cors
        this.app.use(cors());
        this.app.listen(this.port, () => {
            console.log(`App listening on the http://localhost:${this.port}`)
        })
    }
}

export default App