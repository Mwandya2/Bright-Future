# Backend add-ons

These files are **not** part of your existing backend. Nothing under
`backend/` has been modified. Copy a file in only when you want to switch that
feature on.

| File | Enables | Endpoint |
|---|---|---|
| `PaymentController.java` | Card payments for paid courses | `POST /api/payments/intent` |
| `PrintAttachmentController.java` | Attaching a file to a print order | `POST /api/orders/{id}/attachment` |

Until you add them, the app degrades gracefully:

* **Payments** - the checkout screen detects the missing endpoint and offers
  "reserve my place, pay at the hub" instead.
* **Attachments** - the print order is still created; the app tells the user the
  file could not be uploaded and to bring it on a flash drive.

---

## 1. Payments (`PaymentController.java`)

**Where it goes:** `backend/src/main/java/com/brightfuture/controller/PaymentController.java`

**Add to `backend/pom.xml`:**

```xml
<dependency>
    <groupId>com.stripe</groupId>
    <artifactId>stripe-java</artifactId>
    <version>28.0.0</version>
</dependency>
```

**Add to `backend/src/main/resources/application.yml`:**

```yaml
app:
  stripe:
    secret-key: ${STRIPE_SECRET_KEY:}
```

The **secret** key lives only on the server. The app is built with the
**publishable** key, which is safe to ship.

---

## 2. Print attachments (`PrintAttachmentController.java`)

**Where it goes:** `backend/src/main/java/com/brightfuture/controller/PrintAttachmentController.java`

You also need a column to store the file reference. Add to
`PrintOrder.java`:

```java
@Column(name = "attachment_url")
private String attachmentUrl;
// plus getter/setter, and add it to PrintOrderDto + fromEntity
```

The sample controller writes uploads to a local `uploads/` directory. For a
real deployment, swap the `store(...)` method for Supabase Storage or S3 - the
rest of the controller stays the same.

**Add to `application.yml`:**

```yaml
spring:
  servlet:
    multipart:
      max-file-size: 25MB
      max-request-size: 25MB

app:
  uploads:
    directory: ${UPLOAD_DIR:uploads}
```
