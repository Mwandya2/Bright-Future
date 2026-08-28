# Bright Future Digital Hub

A modern, full-stack digital empowerment ecosystem decoupled into:
1. **Frontend**: Next.js 16 + React 19 + TypeScript + Tailwind CSS 4 (`frontend/`)
2. **Backend**: Spring Boot 3.4 + Java 21/26 + Maven + Spring Security JWT + JPA (`backend/`)

---

## 🏗 Project Architecture

```
brightfuture/
├── frontend/                     # Next.js 16 (TypeScript, Tailwind CSS 4, Lucide Icons)
│   ├── src/
│   │   ├── app/                  # App Router pages & server actions
│   │   ├── components/           # UI components, MobileNav drawer, Dashboard shells
│   │   ├── lib/                  # Spring Boot REST API client, auth session helpers, types
│   │   └── services/             # Client/Server API services
│   ├── package.json
│   └── .env.local
│
└── backend/                      # Spring Boot 3.4 REST API (Java 21/26, Maven)
    ├── pom.xml
    └── src/
        ├── main/
        │   ├── java/com/brightfuture/
        │   │   ├── config/       # SecurityConfig, JwtTokenProvider, CorsConfig, SwaggerConfig, DataInitializer
        │   │   ├── controller/   # Auth, Courses, Enrollments, Bookings, PrintOrders, Contact, Admin
        │   │   ├── dto/          # Typed Request & Response DTOs
        │   │   ├── entity/       # User, Course, Enrollment, LabBooking, PrintOrder, ContactMessage
        │   │   ├── exception/    # GlobalExceptionHandler
        │   │   ├── repository/   # Spring Data JPA Repositories
        │   │   └── service/      # Business logic services
        │   └── resources/
        │       └── application.yml
        └── test/
```

---

## 🚀 Quick Start Guide

### 1. Start the Spring Boot Backend (Port 8080)

From the project root:
```bash
npm run dev:backend
# or: mvn spring-boot:run -f backend/pom.xml
```

The Spring Boot backend will start at `http://localhost:8080/api`.

- **Swagger / OpenAPI 3 UI**: `http://localhost:8080/swagger-ui.html`
- **H2 Database Console**: `http://localhost:8080/h2-console` (JDBC URL: `jdbc:h2:mem:brightfuture`)

#### Default Seed Accounts
- **Admin Account**: `admin@brightfuture.best.com` / `Admin@BrightFuture2026!`
- **Demo Student Account**: `student@brightfuture.best.com` / `Student@123!`

---

### 2. Start the Next.js Frontend (Port 3000)

In a separate terminal:
```bash
npm run dev:frontend
# or: cd frontend && npm run dev
```

Visit `http://localhost:3000` in your browser.

---

## 📱 Device Responsiveness Features

- **Mobile Navigation Drawer**: Sliding sheet menu on mobile devices (< 768px) with backdrop blur and touch targets (≥ 44px).
- **Responsive Dashboard & Admin Shells**: Collapsible sidebar navigation on tablets and mobile with a top bar toggle.
- **Adaptive Data Tables**: Horizontal scrolling containers with card-style wrapping for small screens.
- **Fluid Layouts**: Tailwind responsive utilities (`sm:`, `md:`, `lg:`, `xl:`) across all marketing, course, booking, and printing pages.

---

## 🔐 REST API Endpoints Overview

| Category | Method | Endpoint | Description | Access |
|---|---|---|---|---|
| **Auth** | `POST` | `/api/auth/signup` | Register student account | Public |
| **Auth** | `POST` | `/api/auth/login` | Authenticate user & receive JWT | Public |
| **Auth** | `POST` | `/api/auth/admin-login` | Admin authentication with email guard | Public |
| **Auth** | `GET` | `/api/auth/me` | Current user profile | Authenticated |
| **Courses** | `GET` | `/api/courses` | List published courses | Public |
| **Courses** | `GET` | `/api/courses/{slugOrId}` | Get single course | Public |
| **Courses** | `POST` | `/api/courses` | Create new course | Admin |
| **Courses** | `PATCH` | `/api/courses/{id}/publish` | Toggle publish state | Admin |
| **Courses** | `DELETE` | `/api/courses/{id}` | Delete course | Admin |
| **Enrollments** | `GET` | `/api/enrollments/my` | Get current user's enrolled courses | Authenticated |
| **Enrollments** | `POST` | `/api/enrollments` | Enroll current user | Authenticated |
| **Bookings** | `GET` | `/api/bookings/my` | Get current user's lab bookings | Authenticated |
| **Bookings** | `POST` | `/api/bookings` | Create workstation reservation | Authenticated |
| **Bookings** | `PATCH` | `/api/bookings/{id}/cancel` | Cancel own booking | Authenticated |
| **Bookings** | `GET` | `/api/bookings` | List all bookings | Admin |
| **Bookings** | `PATCH` | `/api/bookings/{id}/status` | Update booking status | Admin |
| **Print Orders** | `GET` | `/api/orders/my` | Get user's print orders | Authenticated |
| **Print Orders** | `POST` | `/api/orders` | Create print order with auto-pricing | Authenticated |
| **Print Orders** | `GET` | `/api/orders` | List all print orders | Admin |
| **Print Orders** | `PATCH` | `/api/orders/{id}/status` | Update print order status | Admin |
| **Contact** | `POST` | `/api/contact` | Submit contact enquiry | Public |
| **Contact** | `GET` | `/api/contact` | View contact submissions | Admin |
| **Admin Stats**| `GET` | `/api/admin/stats` | Platform metrics & counts | Admin |
| **Admin Users**| `GET` | `/api/admin/users` | List registered users | Admin |
| **Admin Users**| `PATCH`| `/api/admin/users/{id}/role` | Update user role | Admin |
