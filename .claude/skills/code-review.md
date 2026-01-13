---
name: code-review
description: |
  Code review skill for analyzing and improving code quality.
  Use when reviewing PRs, refactoring code, or identifying issues.
  Covers TypeScript, Dart/Flutter, and React patterns.
---

# Code Review Skill

## Review Checklist

### Security
- [ ] No hardcoded secrets or API keys
- [ ] Input validation on all user inputs
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (proper escaping)
- [ ] Authentication checks on protected routes
- [ ] Rate limiting on sensitive endpoints

### Performance
- [ ] No N+1 query problems
- [ ] Proper indexing for frequent queries
- [ ] Pagination for list endpoints
- [ ] Caching where appropriate
- [ ] No unnecessary re-renders (React/Flutter)

### Code Quality
- [ ] Single responsibility principle
- [ ] DRY (Don't Repeat Yourself)
- [ ] Proper error handling
- [ ] Meaningful variable/function names
- [ ] Appropriate comments (why, not what)

### TypeScript/NestJS
- [ ] Proper typing (no `any`)
- [ ] DTOs with class-validator decorators
- [ ] Guards for authorization
- [ ] Swagger documentation

### Flutter/Dart
- [ ] Proper state management (Riverpod)
- [ ] Widget decomposition
- [ ] Const constructors where possible
- [ ] Dispose of controllers/streams

## Common Issues

### N+1 Query Problem
```typescript
// BAD: N+1 queries
const users = await prisma.user.findMany();
for (const user of users) {
  const wallet = await prisma.wallet.findUnique({ where: { userId: user.id } });
}

// GOOD: Include in single query
const users = await prisma.user.findMany({
  include: { wallet: true }
});
```

### Missing Error Handling
```typescript
// BAD
const user = await prisma.user.findUnique({ where: { id } });
return user.email; // Crashes if user is null

// GOOD
const user = await prisma.user.findUnique({ where: { id } });
if (!user) {
  throw new NotFoundException('User not found');
}
return user.email;
```

### Uncontrolled State Updates (Flutter)
```dart
// BAD: Updating state in build
@override
Widget build(BuildContext context) {
  ref.read(counterProvider.notifier).increment(); // Side effect in build!
  return Text('...');
}

// GOOD: Use callbacks or effects
@override
Widget build(BuildContext context) {
  return ElevatedButton(
    onPressed: () => ref.read(counterProvider.notifier).increment(),
    child: Text('Increment'),
  );
}
```

### Missing Validation
```typescript
// BAD: No validation
@Post()
async create(@Body() dto: CreateUserDto) {
  return this.service.create(dto);
}

// GOOD: Validation pipe
@Post()
@UsePipes(new ValidationPipe({ whitelist: true }))
async create(@Body() dto: CreateUserDto) {
  return this.service.create(dto);
}
```

## Review Response Format

```markdown
## Summary
Brief overview of the changes

## Strengths
- What's done well

## Issues
### Critical
- Security or correctness issues

### Major
- Performance or maintainability issues

### Minor
- Style or nitpick suggestions

## Suggestions
- Optional improvements
```
