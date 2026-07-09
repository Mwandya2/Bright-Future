import { createAdminClient } from "@/lib/supabase/admin";
import { Card } from "@/components/ui";

export const metadata = { title: "Messages" };

type Message = {
  id: string;
  name: string;
  email: string;
  subject: string | null;
  message: string;
  created_at: string;
};

export default async function AdminMessagesPage() {
  const supabase = createAdminClient();
  const { data } = await supabase
    .from("contact_messages")
    .select("*")
    .order("created_at", { ascending: false });
  const messages = (data ?? []) as Message[];

  return (
    <div className="mx-auto max-w-4xl">
      <h1 className="font-display text-3xl md:text-4xl">Contact messages</h1>
      <p className="mt-2 text-[15px] text-[var(--color-body)]">
        Enquiries submitted through the public contact form.
      </p>

      {messages.length === 0 ? (
        <Card className="mt-8 p-10 text-center">
          <p className="text-[15px] text-[var(--color-body)]">No messages yet.</p>
        </Card>
      ) : (
        <div className="mt-8 space-y-4">
          {messages.map((m) => (
            <Card key={m.id} className="p-6">
              <div className="flex flex-wrap items-baseline justify-between gap-x-3 gap-y-1">
                <div className="min-w-0">
                  <span className="text-[15px] font-medium text-[var(--color-ink)]">{m.name}</span>
                  <a href={`mailto:${m.email}`} className="ml-2 break-all text-[13px] text-[var(--color-muted)] hover:underline">
                    {m.email}
                  </a>
                </div>
                <span className="shrink-0 text-[12px] text-[var(--color-muted)]">
                  {new Date(m.created_at).toLocaleString()}
                </span>
              </div>
              {m.subject && (
                <div className="mt-2 break-words text-[14px] font-medium text-[var(--color-body-strong)]">
                  {m.subject}
                </div>
              )}
              <p className="mt-2 whitespace-pre-wrap break-words text-[15px] text-[var(--color-body)]">
                {m.message}
              </p>
            </Card>
          ))}
        </div>
      )}
    </div>
  );
}
