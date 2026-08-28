import { apiClient } from "@/lib/api-client";
import { requireProfile } from "@/lib/auth";
import { Card } from "@/components/ui";
import type { ContactMessage } from "@/lib/types";

export const metadata = { title: "Messages" };

export default async function AdminMessagesPage() {
  await requireProfile({ admin: true });
  const res = await apiClient.get<ContactMessage[]>("/contact");
  const messages = res.data ?? [];

  return (
    <div className="mx-auto max-w-4xl">
      <h1 className="font-display text-2xl sm:text-3xl md:text-4xl">Contact messages</h1>
      <p className="mt-2 text-[14px] sm:text-[15px] text-[var(--color-body)]">
        Enquiries submitted through the public contact form.
      </p>

      {messages.length === 0 ? (
        <Card className="mt-6 sm:mt-8 p-8 sm:p-10 text-center">
          <p className="text-[14px] sm:text-[15px] text-[var(--color-body)]">No messages yet.</p>
        </Card>
      ) : (
        <div className="mt-6 sm:mt-8 space-y-4">
          {messages.map((m) => (
            <Card key={m.id} className="p-5 sm:p-6">
              <div className="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1">
                <div className="min-w-0">
                  <span className="text-[14px] sm:text-[15px] font-medium text-[var(--color-ink)]">{m.name}</span>
                  <a href={`mailto:${m.email}`} className="ml-2 break-all text-[12px] sm:text-[13px] text-[var(--color-muted)] hover:underline">
                    {m.email}
                  </a>
                </div>
                <span className="shrink-0 text-[11px] sm:text-[12px] text-[var(--color-muted)]">
                  {new Date(m.created_at).toLocaleString()}
                </span>
              </div>
              {m.subject && (
                <div className="mt-2 break-words text-[13px] sm:text-[14px] font-medium text-[var(--color-body-strong)]">
                  {m.subject}
                </div>
              )}
              <p className="mt-2 whitespace-pre-wrap break-words text-[14px] sm:text-[15px] text-[var(--color-body)]">
                {m.message}
              </p>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
