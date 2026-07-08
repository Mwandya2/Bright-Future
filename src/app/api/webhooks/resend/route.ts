import { NextResponse } from "next/server";

/**
 * Resend webhook receiver.
 *
 * Configure in Resend → Webhooks with endpoint:
 *   https://brightfuture.best/api/webhooks/resend
 *
 * Resend signs each delivery (Svix headers). If you set a signing secret in
 * Resend, add it as RESEND_WEBHOOK_SECRET and this route verifies it; without
 * a secret set it accepts and logs events (fine for getting started).
 *
 * Handled event types: email.sent, email.delivered, email.delivery_delayed,
 * email.bounced, email.complained, email.opened, email.clicked.
 */
export async function POST(request: Request) {
  const raw = await request.text();

  // Optional signature verification (Svix). Only enforced if a secret is set.
  const secret = process.env.RESEND_WEBHOOK_SECRET;
  if (secret) {
    const id = request.headers.get("svix-id");
    const timestamp = request.headers.get("svix-timestamp");
    const signature = request.headers.get("svix-signature");
    if (!id || !timestamp || !signature) {
      return NextResponse.json({ error: "missing signature headers" }, { status: 401 });
    }
    const ok = await verifySvix(secret, id, timestamp, raw, signature);
    if (!ok) {
      return NextResponse.json({ error: "invalid signature" }, { status: 401 });
    }
  }

  let event: { type?: string; data?: Record<string, unknown> } = {};
  try {
    event = JSON.parse(raw);
  } catch {
    return NextResponse.json({ error: "invalid json" }, { status: 400 });
  }

  const to = (event.data?.to as string[] | string | undefined) ?? "";
  console.log(`[resend webhook] ${event.type ?? "unknown"} →`, Array.isArray(to) ? to.join(", ") : to);

  // Extend here: persist bounces/complaints, suppress addresses, notify admin…
  return NextResponse.json({ received: true });
}

// Svix HMAC-SHA256 verification (what Resend uses under the hood).
async function verifySvix(
  secret: string,
  id: string,
  timestamp: string,
  body: string,
  signatureHeader: string,
): Promise<boolean> {
  try {
    const key = secret.startsWith("whsec_") ? secret.slice(6) : secret;
    const keyBytes = Uint8Array.from(atob(key), (c) => c.charCodeAt(0));
    const enc = new TextEncoder();
    const cryptoKey = await crypto.subtle.importKey(
      "raw",
      keyBytes,
      { name: "HMAC", hash: "SHA-256" },
      false,
      ["sign"],
    );
    const signed = await crypto.subtle.sign(
      "HMAC",
      cryptoKey,
      enc.encode(`${id}.${timestamp}.${body}`),
    );
    const expected = btoa(String.fromCharCode(...new Uint8Array(signed)));
    // Header looks like "v1,<sig> v1,<sig>" — accept if any matches.
    return signatureHeader
      .split(" ")
      .map((p) => p.split(",")[1])
      .some((sig) => sig === expected);
  } catch {
    return false;
  }
}

// Health check / setup verification.
export async function GET() {
  return NextResponse.json({ ok: true, endpoint: "resend-webhook" });
}
