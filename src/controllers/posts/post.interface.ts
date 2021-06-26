/**
 * Blog post
 **/

interface Blog {
    /**
     *  id The blogs unique identifier
     **/

    id: number
    /**
     * author Name of blog author
     */
    author: string
    /**
     * content Content of blog
     */
    content: string
    /**
     * title Title of blog
     */
    title: string
}

export default Blog