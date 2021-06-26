import * as express from 'express'
import Blog from './post.interface'
import {
    Body,
    Controller,
    Get,
    Path,
    Post,
    Route,
    Response,
    SuccessResponse,
} from "tsoa";
/**
 * Example Express Controller. This demonstrates POST, GET, and GET :id
 */
interface ValidateErrorJSON {
    message: "Validation failed";
    details: { [name: string]: unknown };
}

@Route("posts")
export class PostsController extends Controller {
    public path = '/posts'
    public router = express.Router()

    private posts: Blog[] = [
        {
            id: 1,
            author: 'compoze',
            content: 'This is an post for the endpoints',
            title: 'Hello world!'
        }
    ]

    @Get("{id}")
    public async getPost(@Path() id: number): Promise<Blog> {

        let result: Blog = this.posts.find(post => post.id == id)

        if (!result) {
            this.setStatus(404);
            return;
        }

        return result;
    }

    @Get()
    public async getAllPosts(): Promise<Blog[]> {

        return this.posts;
    }

    @Response<ValidateErrorJSON>(422, "Validation Failed")
    @SuccessResponse("201", "Created") // Custom success response
    @Post()
    public async createPost(@Body() blog: Blog): Promise<Blog[]> {

        console.log('hhelo');
        this.posts.push(blog);

        this.setStatus(201);
        return this.posts;
    }
}