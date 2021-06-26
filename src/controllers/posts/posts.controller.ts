import * as express from 'express'
import IPost from './post.interface'
import {
    Body,
    Controller,
    Get,
    Path,
    Post,
    Route,
    SuccessResponse,
} from "tsoa";
/**
 * Example Express Controller. This demonstrates POST, GET, and GET :id
 */
@Route("posts")
export class PostsController extends Controller {
    public path = '/posts'
    public router = express.Router()

    private posts: IPost[] = [
        {
            id: 1,
            author: 'compoze',
            content: 'This is an post for the endpoints',
            title: 'Hello world!'
        }
    ]

    @Get("{id}")
    public async getPost(@Path() id: number): Promise<IPost> {

        let result: IPost = this.posts.find(post => post.id == id)

        if (!result) {
            this.setStatus(404);
            return;
        }

        return result;
    }

    @Get()
    public async getAllPosts(): Promise<IPost[]> {

        return this.posts;
    }

    @SuccessResponse("201", "Created") // Custom success response
    @Post()
    public async createPost(@Body() post: IPost): Promise<IPost[]> {

        this.posts.push(post);
        return this.posts;
    }
}