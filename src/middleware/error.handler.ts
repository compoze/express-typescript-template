import {
    Response,
    Request,
    NextFunction,
} from "express";
import { ValidateError } from "tsoa";


const globalErrorHandler = (err: unknown, req: Request, res: Response, next: NextFunction) => {
    console.log(err)
    if (err instanceof ValidateError) {
        console.warn(`Caught Validation Error for ${req.path}:`, err.fields);
        return res.status(422).json({
            message: "Validation Failed",
            details: err?.fields,
        });
    }
    if (err instanceof Error) {
        console.warn(`Internal Server Error ${req.path}:`, err);
        return res.status(500).json({
            message: "Internal Server Error",
        });
    }

    next();
}

export default globalErrorHandler;