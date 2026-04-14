# Test Patterns

## Unit Test Pattern

```typescript
describe("Button Component", () => {
  it("renders text", () => {
    render(<Button>Click me</Button>)
    expect(screen.getByText("Click me")).toBeInTheDocument()
  })
})
```

## API Integration Pattern

```typescript
describe("GET /api/markets", () => {
  it("returns markets successfully", async () => {
    const request = new NextRequest("http://localhost/api/markets")
    const response = await GET(request)
    expect(response.status).toBe(200)
  })
})
```

## E2E Pattern

```typescript
test("user can search and filter markets", async ({ page }) => {
  await page.goto("/")
  await page.click('a[href="/markets"]')
  await page.fill('input[placeholder="Search markets"]', "election")
  await expect(page.locator('[data-testid="market-card"]')).toHaveCount(5)
})
```

## File Organization

```text
src/components/Button/Button.test.tsx
src/app/api/markets/route.test.ts
e2e/markets.spec.ts
```

## Selector Guidance

- prefer semantic queries and roles
- use `data-testid` for fragile surfaces
- avoid styling-only selectors in E2E when possible
