---
name: adonisjs-backend
description: AdonisJS 6 backend development patterns — controllers, models, validators, services, middleware, auth, and testing for production-grade TypeScript APIs.
license: MIT
compatibility: opencode
metadata:
  origin: claude-skills
  type: workflow
---


# AdonisJS 6 Backend Development Patterns

Expert backend developer specializing in AdonisJS 6, Lucid ORM, VineJS validation, and production-grade TypeScript APIs. Inspired by Rails conventions — convention over configuration, MVC architecture, and developer happiness.

## When to Activate

- Building or modifying AdonisJS controllers, models, services, or middleware
- Designing REST API endpoints with AdonisJS router
- Working with Lucid ORM (models, relationships, queries, migrations, seeders)
- Implementing validation with VineJS
- Setting up authentication (access tokens, session, social auth)
- Writing AdonisJS tests (Japa)
- Configuring middleware, guards, or exception handlers
- Background jobs with `@adonisjs/limiter`, `@rlanz/bull-queue`, or similar

## Project Structure (AdonisJS 6)

```
app/
├── controllers/        # HTTP controllers (thin, delegate to services)
├── models/             # Lucid ORM models
├── services/           # Business logic layer
├── validators/         # VineJS validation schemas
├── middleware/          # HTTP middleware
├── exceptions/         # Custom exception classes
├── policies/           # Authorization (Bouncer policies)
├── mails/              # Mail classes
├── events/             # Event listeners
├── jobs/               # Background jobs
config/                 # App configuration
database/
├── migrations/         # Database migrations
├── seeders/            # Database seeders
├── factories/          # Model factories (for testing)
start/
├── routes.ts           # Route definitions
├── kernel.ts           # Middleware registration
├── events.ts           # Event bindings
tests/
├── unit/
├── functional/
```

## Core Principles

1. **Convention over configuration** — follow AdonisJS conventions, don't fight the framework
2. **Thin controllers** — controllers validate input, call services, return responses
3. **Fat models** — keep query scopes, relationships, and computed properties on models
4. **Service layer** — complex business logic lives in services, not controllers
5. **Validate early** — use VineJS validators before any business logic
6. **Type everything** — leverage TypeScript strictly, no `any`

## Router & Controllers

### Route Definitions

```typescript
// start/routes.ts
import router from '@adonisjs/core/services/router'

const UsersController = () => import('#controllers/users_controller')
const PostsController = () => import('#controllers/posts_controller')

// RESTful resource routes (Rails-like)
router.resource('users', UsersController).apiOnly()
router.resource('users.posts', PostsController).apiOnly()

// Grouped routes with middleware
router.group(() => {
  router.get('me', [UsersController, 'me'])
  router.resource('posts', PostsController).apiOnly()
}).prefix('api/v1').middleware(middleware.auth())

// Named routes
router.get('users/:id', [UsersController, 'show']).as('users.show')
```

### Controller Pattern

```typescript
// app/controllers/posts_controller.ts
import type { HttpContext } from '@adonisjs/core/http'
import { createPostValidator, updatePostValidator } from '#validators/post'
import PostService from '#services/post_service'
import { inject } from '@adonisjs/core'

@inject()
export default class PostsController {
  constructor(private postService: PostService) {}

  async index({ request, response }: HttpContext) {
    const page = request.input('page', 1)
    const limit = request.input('limit', 20)

    const posts = await this.postService.list(page, limit)
    return response.ok(posts)
  }

  async store({ request, response, auth }: HttpContext) {
    const data = await request.validateUsing(createPostValidator)
    const post = await this.postService.create(auth.user!, data)
    return response.created(post)
  }

  async show({ params, response }: HttpContext) {
    const post = await this.postService.findOrFail(params.id)
    return response.ok(post)
  }

  async update({ params, request, response, auth, bouncer }: HttpContext) {
    const post = await this.postService.findOrFail(params.id)
    await bouncer.authorize('editPost', post)

    const data = await request.validateUsing(updatePostValidator)
    const updated = await this.postService.update(post, data)
    return response.ok(updated)
  }

  async destroy({ params, response, bouncer }: HttpContext) {
    const post = await this.postService.findOrFail(params.id)
    await bouncer.authorize('deletePost', post)

    await this.postService.delete(post)
    return response.noContent()
  }
}
```

## Lucid ORM Models

### Model Definition

```typescript
// app/models/post.ts
import { DateTime } from 'luxon'
import { BaseModel, column, belongsTo, hasMany, scope } from '@adonisjs/lucid/orm'
import type { BelongsTo, HasMany } from '@adonisjs/lucid/types/relations'
import User from '#models/user'
import Comment from '#models/comment'

export default class Post extends BaseModel {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare title: string

  @column()
  declare content: string

  @column()
  declare userId: number

  @column()
  declare isPublished: boolean

  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime

  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime

  // Relationships
  @belongsTo(() => User)
  declare user: BelongsTo<typeof User>

  @hasMany(() => Comment)
  declare comments: HasMany<typeof Comment>

  // Query scopes
  static published = scope((query) => {
    query.where('isPublished', true)
  })

  static recent = scope((query, days: number = 7) => {
    query.where('createdAt', '>=', DateTime.now().minus({ days }).toSQL())
  })

  // Computed / serialization
  serialize() {
    return {
      id: this.id,
      title: this.title,
      content: this.content,
      author: this.$preloaded.user ? this.user.serialize() : undefined,
      commentsCount: this.$extras.comments_count,
      createdAt: this.createdAt.toISO(),
    }
  }
}
```

### Querying with Lucid

```typescript
// Eager loading (avoid N+1)
const posts = await Post.query()
  .withScopes((s) => s.published())
  .preload('user')
  .preload('comments', (query) => query.limit(5))
  .withCount('comments')
  .orderBy('createdAt', 'desc')
  .paginate(page, limit)

// Efficient updates
await Post.query().where('userId', userId).update({ isPublished: false })

// Transactions
import db from '@adonisjs/lucid/services/db'

await db.transaction(async (trx) => {
  const post = new Post()
  post.useTransaction(trx)
  post.fill({ title, content, userId })
  await post.save()

  const tags = tagIds.map((tagId) => ({ postId: post.id, tagId }))
  await trx.table('post_tags').multiInsert(tags)
})
```

## VineJS Validation

```typescript
// app/validators/post.ts
import vine from '@vinejs/vine'

export const createPostValidator = vine.compile(
  vine.object({
    title: vine.string().trim().minLength(3).maxLength(255),
    content: vine.string().trim().minLength(10),
    tagIds: vine.array(vine.number().positive()).optional(),
    isPublished: vine.boolean().optional(),
  })
)

export const updatePostValidator = vine.compile(
  vine.object({
    title: vine.string().trim().minLength(3).maxLength(255).optional(),
    content: vine.string().trim().minLength(10).optional(),
    isPublished: vine.boolean().optional(),
  })
)

// Unique validation rule (custom)
export const createUserValidator = vine.compile(
  vine.object({
    email: vine.string().email().unique({ table: 'users', column: 'email' }),
    username: vine.string().alphaNumeric().minLength(3).maxLength(30)
      .unique({ table: 'users', column: 'username' }),
    password: vine.string().minLength(8).confirmed(),
  })
)
```

## Service Layer

```typescript
// app/services/post_service.ts
import Post from '#models/post'
import type User from '#models/user'
import { inject } from '@adonisjs/core'
import { ModelPaginatorContract } from '@adonisjs/lucid/types/model'

@inject()
export default class PostService {
  async list(page: number, limit: number): Promise<ModelPaginatorContract<Post>> {
    return Post.query()
      .withScopes((s) => s.published())
      .preload('user')
      .withCount('comments')
      .orderBy('createdAt', 'desc')
      .paginate(page, limit)
  }

  async findOrFail(id: number): Promise<Post> {
    return Post.findOrFail(id)
  }

  async create(user: User, data: { title: string; content: string; tagIds?: number[] }): Promise<Post> {
    const post = await Post.create({
      title: data.title,
      content: data.content,
      userId: user.id,
    })

    if (data.tagIds?.length) {
      await post.related('tags').attach(data.tagIds)
    }

    return post
  }

  async update(post: Post, data: Partial<{ title: string; content: string; isPublished: boolean }>): Promise<Post> {
    post.merge(data)
    await post.save()
    return post
  }

  async delete(post: Post): Promise<void> {
    await post.delete()
  }
}
```

## Middleware

```typescript
// app/middleware/rate_limit_middleware.ts
import type { HttpContext } from '@adonisjs/core/http'
import type { NextFn } from '@adonisjs/core/types/http'
import limiter from '@adonisjs/limiter/services/main'

export default class RateLimitMiddleware {
  async handle(ctx: HttpContext, next: NextFn) {
    const throttle = limiter.use({
      requests: 100,
      duration: '1 minute',
      blockDuration: '5 minutes',
    })

    const key = ctx.auth.user?.id?.toString() ?? ctx.request.ip()
    await throttle.penalize(key)

    return next()
  }
}
```

```typescript
// app/middleware/silent_auth_middleware.ts — try to authenticate, don't fail
import type { HttpContext } from '@adonisjs/core/http'
import type { NextFn } from '@adonisjs/core/types/http'

export default class SilentAuthMiddleware {
  async handle(ctx: HttpContext, next: NextFn) {
    try {
      await ctx.auth.authenticate()
    } catch {}
    return next()
  }
}
```

## Authentication

### Access Token Auth (API)

```typescript
// app/models/user.ts
import { DbAccessTokensProvider } from '@adonisjs/auth/access_tokens'
import { withAuthFinder } from '@adonisjs/auth/mixins/lucid'
import { compose } from '@adonisjs/core/helpers'
import hash from '@adonisjs/core/services/hash'
import { BaseModel, column, hasMany } from '@adonisjs/lucid/orm'

const AuthFinder = withAuthFinder(() => hash.use('scrypt'), {
  uids: ['email'],
  passwordColumnName: 'password',
})

export default class User extends compose(BaseModel, AuthFinder) {
  @column({ isPrimary: true })
  declare id: number

  @column()
  declare email: string

  @column({ serializeAs: null })
  declare password: string

  static accessTokens = DbAccessTokensProvider.forModel(User, {
    expiresIn: '30 days',
    prefix: 'oat_',
  })
}
```

```typescript
// app/controllers/auth_controller.ts
import type { HttpContext } from '@adonisjs/core/http'
import User from '#models/user'
import { loginValidator, registerValidator } from '#validators/auth'

export default class AuthController {
  async register({ request, response }: HttpContext) {
    const data = await request.validateUsing(registerValidator)
    const user = await User.create(data)
    const token = await User.accessTokens.create(user)
    return response.created({ user, token })
  }

  async login({ request, response }: HttpContext) {
    const { email, password } = await request.validateUsing(loginValidator)
    const user = await User.verifyCredentials(email, password)
    const token = await User.accessTokens.create(user)
    return response.ok({ user, token })
  }

  async logout({ auth, response }: HttpContext) {
    const user = auth.user!
    await User.accessTokens.delete(user, user.currentAccessToken.identifier)
    return response.noContent()
  }
}
```

## Authorization (Bouncer)

```typescript
// app/policies/post_policy.ts
import User from '#models/user'
import Post from '#models/post'
import { BasePolicy, allowGuest } from '@adonisjs/bouncer'
import { AuthorizerResponse } from '@adonisjs/bouncer/types'

export default class PostPolicy extends BasePolicy {
  @allowGuest()
  view(_user: User | null, post: Post): AuthorizerResponse {
    return post.isPublished || (_user !== null && post.userId === _user.id)
  }

  edit(user: User, post: Post): AuthorizerResponse {
    return user.id === post.userId || user.role === 'admin'
  }

  delete(user: User, post: Post): AuthorizerResponse {
    return user.id === post.userId || user.role === 'admin'
  }
}
```

## Migrations

```typescript
// database/migrations/xxxx_create_posts_table.ts
import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  protected tableName = 'posts'

  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments('id')
      table.integer('user_id').unsigned().references('id').inTable('users').onDelete('CASCADE')
      table.string('title', 255).notNullable()
      table.text('content').notNullable()
      table.boolean('is_published').defaultTo(false)
      table.timestamp('created_at').notNullable()
      table.timestamp('updated_at').notNullable()

      // Indexes
      table.index(['user_id'])
      table.index(['is_published', 'created_at'])
    })
  }

  async down() {
    this.schema.dropTable(this.tableName)
  }
}
```

## Database Seeders & Factories

```typescript
// database/factories/post_factory.ts
import Post from '#models/post'
import factory from '@adonisjs/lucid/factories'

export const PostFactory = factory
  .define(Post, ({ faker }) => ({
    title: faker.lorem.sentence(),
    content: faker.lorem.paragraphs(3),
    isPublished: faker.datatype.boolean(),
  }))
  .relation('user', () => UserFactory)
  .relation('comments', () => CommentFactory)
  .build()
```

```typescript
// database/seeders/post_seeder.ts
import { BaseSeeder } from '@adonisjs/lucid/seeders'
import { PostFactory } from '#database/factories/post_factory'

export default class extends BaseSeeder {
  async run() {
    await PostFactory.with('user').with('comments', 3).createMany(20)
  }
}
```

## Exception Handling

```typescript
// app/exceptions/handler.ts
import { ExceptionHandler, HttpContext } from '@adonisjs/core/http'
import app from '@adonisjs/core/services/app'

export default class HttpExceptionHandler extends ExceptionHandler {
  protected debug = !app.inProduction

  async handle(error: unknown, ctx: HttpContext) {
    // Custom handling for specific errors
    if (error instanceof E_AUTHORIZATION_FAILURE) {
      return ctx.response.forbidden({ error: 'You are not authorized' })
    }

    return super.handle(error, ctx)
  }

  async report(error: unknown, ctx: HttpContext) {
    // Report to external service (Sentry, etc.)
    if (!this.shouldReport(error as any)) return
    // sentry.captureException(error)
  }
}
```

```typescript
// app/exceptions/resource_not_found_exception.ts
import { Exception } from '@adonisjs/core/exceptions'

export default class ResourceNotFoundException extends Exception {
  static status = 404
  static code = 'E_RESOURCE_NOT_FOUND'
  static message = 'The requested resource was not found'
}
```

## Testing (Japa)

```typescript
// tests/functional/posts/list.spec.ts
import { test } from '@japa/runner'
import { UserFactory } from '#database/factories/user_factory'
import { PostFactory } from '#database/factories/post_factory'

test.group('Posts | List', (group) => {
  group.each.setup(() => testUtils.db().withGlobalTransaction())

  test('returns paginated published posts', async ({ client }) => {
    await PostFactory.merge({ isPublished: true }).createMany(5)
    await PostFactory.merge({ isPublished: false }).createMany(3)

    const response = await client.get('/api/v1/posts')

    response.assertStatus(200)
    response.assertBodyContains({ meta: { total: 5 } })
  })

  test('requires auth to create a post', async ({ client }) => {
    const response = await client.post('/api/v1/posts').json({
      title: 'Test Post',
      content: 'Some content here',
    })

    response.assertStatus(401)
  })

  test('authenticated user can create a post', async ({ client }) => {
    const user = await UserFactory.create()

    const response = await client
      .post('/api/v1/posts')
      .json({ title: 'Test Post', content: 'Some content that is long enough' })
      .loginAs(user)

    response.assertStatus(201)
    response.assertBodyContains({ title: 'Test Post' })
  })
})
```

## Events & Listeners

```typescript
// start/events.ts
import emitter from '@adonisjs/core/services/emitter'

const PostCreated = () => import('#events/post_created')
emitter.on('post:created', [PostCreated])

// app/events/post_created.ts
import Post from '#models/post'

export default class PostCreated {
  constructor(public post: Post) {}
}

// Usage in service
import emitter from '@adonisjs/core/services/emitter'
await emitter.emit('post:created', post)
```

## Background Jobs (Bull Queue)

```typescript
// app/jobs/send_notification_job.ts
import { BaseJob } from '@rlanz/bull-queue'

export default class SendNotificationJob extends BaseJob {
  static get queueName() {
    return 'notifications'
  }

  async handle(payload: { userId: number; message: string }) {
    // Send notification logic
  }

  async failed(payload: unknown, error: Error) {
    // Handle failure
  }
}
```

## Anti-Patterns to Avoid

```typescript
// BAD: Business logic in controller
async store({ request }: HttpContext) {
  const data = request.all() // No validation!
  const post = await Post.create(data) // Mass assignment risk
  // 50 more lines of business logic...
}

// GOOD: Thin controller, validated input, service layer
async store({ request, auth }: HttpContext) {
  const data = await request.validateUsing(createPostValidator)
  const post = await this.postService.create(auth.user!, data)
  return response.created(post)
}

// BAD: N+1 queries
const posts = await Post.all()
for (const post of posts) {
  console.log(post.user.name) // Lazy load = N+1
}

// GOOD: Eager loading
const posts = await Post.query().preload('user')

// BAD: Raw strings in queries
await db.rawQuery(`SELECT * FROM users WHERE email = '${email}'`) // SQL injection!

// GOOD: Parameterized queries
await db.rawQuery('SELECT * FROM users WHERE email = ?', [email])
```

## Quick Reference — Common Commands

```bash
# Scaffold
node ace make:controller Post                  # Controller
node ace make:model Post -m -f -c              # Model + migration + factory + controller
node ace make:validator post                   # Validator
node ace make:service post                     # Service
node ace make:middleware rate_limit             # Middleware
node ace make:policy post                      # Bouncer policy
node ace make:exception resource_not_found     # Exception
node ace make:test functional posts/list       # Test

# Database
node ace migration:run                         # Run migrations
node ace migration:rollback                    # Rollback last batch
node ace migration:fresh --seed                # Reset DB + seed
node ace db:seed                               # Run seeders

# Dev
node ace serve --hmr                           # Dev server with HMR
node ace test                                  # Run tests
node ace test --tags "posts"                   # Run tagged tests
node ace repl                                  # Interactive REPL
```

**Remember**: AdonisJS is batteries-included like Rails. Use the framework's conventions and built-in features before reaching for external libraries.
