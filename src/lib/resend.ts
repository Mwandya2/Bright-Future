import { Resend } from "resend";

const resend = new Resend(process.env.RESEND_API_KEY);

const FROM = process.env.RESEND_FROM_EMAIL || "Bright Future <onboarding@resend.dev>";

/**
 * Sends a branded welcome / confirmation email after signup.
 * Supabase handles the actual email-verification link; this is an
 * additional friendly confirmation from the Bright Future brand.
 */
export async function sendWelcomeEmail(to: string, name: string) {
  try {
    await resend.emails.send({
      from: FROM,
      to,
      subject: "Welcome to Bright Future Digital Hub 🎓",
      html: welcomeHtml(name),
    });
  } catch (err) {
    // Never block signup on email failure.
    console.error("[resend] welcome email failed:", err);
  }
}

export async function sendBookingConfirmation(
  to: string,
  name: string,
  details: { service: string; date: string; time: string },
) {
  try {
    await resend.emails.send({
      from: FROM,
      to,
      subject: `Booking confirmed — ${details.service}`,
      html: bookingHtml(name, details),
    });
  } catch (err) {
    console.error("[resend] booking email failed:", err);
  }
}

function shell(inner: string) {
  return `
  <div style="font-family:Inter,Helvetica,Arial,sans-serif;background:#f5f5f5;padding:40px 0;color:#0c0a09;">
    <div style="max-width:520px;margin:0 auto;background:#ffffff;border:1px solid #e7e5e4;border-radius:16px;overflow:hidden;">
      <div style="padding:32px 32px 8px;">
        <div style="font-size:12px;letter-spacing:0.96px;font-weight:600;text-transform:uppercase;color:#777169;">Bright Future Digital Hub</div>
      </div>
      <div style="padding:8px 32px 32px;font-size:16px;line-height:1.6;color:#4e4e4e;">
        ${inner}
      </div>
      <div style="padding:20px 32px;border-top:1px solid #f0efed;font-size:13px;color:#a8a29e;">
        Empowering Digital Futures · brightfuture.best
      </div>
    </div>
  </div>`;
}

function welcomeHtml(name: string) {
  return shell(`
    <h1 style="font-family:Georgia,'Times New Roman',serif;font-weight:300;font-size:28px;color:#0c0a09;margin:0 0 16px;">
      Welcome, ${escapeHtml(name || "there")} 👋
    </h1>
    <p style="margin:0 0 16px;">
      Your Bright Future account is being set up. You now have access to ICT courses,
      computer-lab bookings, digital printing, and more — all in one place.
    </p>
    <p style="margin:0 0 24px;">
      If you were asked to verify your email, please click the verification link we sent
      separately to activate your account.
    </p>
    <a href="https://brightfuture.best/dashboard"
       style="display:inline-block;background:#292524;color:#ffffff;text-decoration:none;font-weight:500;font-size:15px;padding:12px 22px;border-radius:9999px;">
      Go to my dashboard
    </a>
    <p style="margin:24px 0 0;color:#a8a29e;font-size:14px;">Learn. Connect. Grow.</p>
  `);
}

function bookingHtml(
  name: string,
  d: { service: string; date: string; time: string },
) {
  return shell(`
    <h1 style="font-family:Georgia,'Times New Roman',serif;font-weight:300;font-size:26px;color:#0c0a09;margin:0 0 16px;">
      Booking confirmed
    </h1>
    <p style="margin:0 0 16px;">Hi ${escapeHtml(name || "there")}, your booking is received:</p>
    <table style="width:100%;border-collapse:collapse;font-size:15px;">
      <tr><td style="padding:8px 0;color:#777169;">Service</td><td style="padding:8px 0;text-align:right;font-weight:500;">${escapeHtml(d.service)}</td></tr>
      <tr><td style="padding:8px 0;color:#777169;">Date</td><td style="padding:8px 0;text-align:right;font-weight:500;">${escapeHtml(d.date)}</td></tr>
      <tr><td style="padding:8px 0;color:#777169;">Time</td><td style="padding:8px 0;text-align:right;font-weight:500;">${escapeHtml(d.time)}</td></tr>
    </table>
  `);
}

function escapeHtml(s: string) {
  return s.replace(/[&<>"']/g, (c) =>
    ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]!,
  );
}
