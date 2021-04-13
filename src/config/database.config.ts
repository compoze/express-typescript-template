import { PostgresConnectionOptions } from 'typeorm/driver/postgres/PostgresConnectionOptions';

const typeOrmConfig: PostgresConnectionOptions = {
    type: "postgres",
    host: "database",
    port: 5432,
    username: "admin",
    password: "admin",
    database: "myapp",
    synchronize: true,
    entities: ["{dist,src}/**/*.entity{.ts,.js}"],
    logging: false,
};

export { typeOrmConfig };